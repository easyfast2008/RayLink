import Foundation
import os.log

class XrayWrapper {
    private let logger = Logger(subsystem: "com.raylink.app", category: "XrayWrapper")
    private var xrayProcess: Process?
    private var isRunning = false
    private var configPath: String?
    
    // MARK: - Public Interface
    
    var running: Bool {
        return isRunning
    }
    
    func start(with config: XrayConfig, completion: @escaping (Result<Void, Error>) -> Void) {
        logger.info("Starting Xray-core")
        
        do {
            // Create temporary config file
            let configData = try JSONEncoder().encode(config)
            let tempDir = FileManager.default.temporaryDirectory
            let configURL = tempDir.appendingPathComponent("xray_config.json")
            
            try configData.write(to: configURL)
            configPath = configURL.path
            
            // Start Xray process
            startXrayProcess(configPath: configURL.path, completion: completion)
            
        } catch {
            logger.error("Failed to prepare Xray configuration: \(error.localizedDescription)")
            completion(.failure(XrayError.configurationError(error)))
        }
    }
    
    func stop() {
        logger.info("Stopping Xray-core")
        
        xrayProcess?.terminate()
        xrayProcess?.waitUntilExit()
        xrayProcess = nil
        isRunning = false
        
        // Clean up config file
        if let configPath = configPath {
            try? FileManager.default.removeItem(atPath: configPath)
            self.configPath = nil
        }
    }
    
    func forwardPackets(_ packets: [Data], protocols: [NSNumber], completion: @escaping ([Data], [NSNumber]) -> Void) {
        // In a real implementation, this would interface with the Xray-core process
        // to forward packets through the VPN tunnel. For now, we'll pass them through.
        
        // This is where you would implement the actual packet forwarding logic
        // that communicates with Xray-core's API or uses a shared memory interface
        
        DispatchQueue.global(qos: .userInteractive).async {
            // Simulate packet processing
            completion(packets, protocols)
        }
    }
    
    func getStatistics() -> XrayStatistics? {
        // In a real implementation, this would query Xray-core for current statistics
        // via its API endpoint
        
        guard isRunning else { return nil }
        
        return XrayStatistics(
            uplink: 0,
            downlink: 0,
            uplinkTotal: 0,
            downlinkTotal: 0
        )
    }
    
    // MARK: - Private Methods
    
    private func startXrayProcess(configPath: String, completion: @escaping (Result<Void, Error>) -> Void) {
        // Get Xray binary path (this would be bundled with your app)
        guard let xrayBinaryPath = getXrayBinaryPath() else {
            completion(.failure(XrayError.binaryNotFound))
            return
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: xrayBinaryPath)
        process.arguments = ["-c", configPath]
        
        // Set up pipes for output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Monitor output
        outputPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                self?.logger.debug("Xray output: \(output)")
            }
        }
        
        errorPipe.fileHandleForReading.readabilityHandler = { [weak self] handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                self?.logger.error("Xray error: \(output)")
            }
        }
        
        // Set up termination handler
        process.terminationHandler = { [weak self] process in
            self?.logger.info("Xray process terminated with status: \(process.terminationStatus)")
            self?.isRunning = false
            
            // Clean up file handles
            outputPipe.fileHandleForReading.readabilityHandler = nil
            errorPipe.fileHandleForReading.readabilityHandler = nil
        }
        
        do {
            try process.run()
            xrayProcess = process
            isRunning = true
            
            // Give the process a moment to start up
            DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                if process.isRunning {
                    completion(.success(()))
                } else {
                    completion(.failure(XrayError.startupFailed))
                }
            }
            
        } catch {
            logger.error("Failed to start Xray process: \(error.localizedDescription)")
            completion(.failure(XrayError.processStartError(error)))
        }
    }
    
    private func getXrayBinaryPath() -> String? {
        // In a real implementation, you would bundle the Xray binary with your app
        // and return the path to it here. For iOS, this would typically be in the
        // app bundle or a framework.
        
        // This is a placeholder - you would need to:
        // 1. Include Xray-core binary in your app bundle
        // 2. Handle code signing requirements
        // 3. Deal with iOS restrictions on executable binaries
        
        if let bundlePath = Bundle.main.path(forResource: "xray", ofType: nil) {
            return bundlePath
        }
        
        // Fallback paths (for development/testing)
        let possiblePaths = [
            "/usr/local/bin/xray",
            "/opt/homebrew/bin/xray",
            Bundle.main.bundlePath + "/xray"
        ]
        
        for path in possiblePaths {
            if FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
}

// MARK: - Supporting Types

enum XrayError: Error, LocalizedError {
    case configurationError(Error)
    case binaryNotFound
    case startupFailed
    case processStartError(Error)
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .configurationError(let error):
            return "Configuration error: \(error.localizedDescription)"
        case .binaryNotFound:
            return "Xray binary not found"
        case .startupFailed:
            return "Xray failed to start"
        case .processStartError(let error):
            return "Process start error: \(error.localizedDescription)"
        case .apiError(let message):
            return "Xray API error: \(message)"
        }
    }
}

struct XrayStatistics: Codable {
    let uplink: UInt64      // Current upload speed (bytes/sec)
    let downlink: UInt64    // Current download speed (bytes/sec)
    let uplinkTotal: UInt64 // Total bytes uploaded
    let downlinkTotal: UInt64 // Total bytes downloaded
}

// MARK: - Xray Configuration Models

struct XrayConfig: Codable {
    let log: XrayLogConfig?
    let dns: XrayDNSConfig?
    let routing: XrayRoutingConfig?
    let inbounds: [XrayInbound]
    let outbounds: [XrayOutbound]
    let transport: XrayTransportConfig?
    
    init(
        log: XrayLogConfig? = XrayLogConfig(),
        dns: XrayDNSConfig? = XrayDNSConfig(),
        routing: XrayRoutingConfig? = XrayRoutingConfig(),
        inbounds: [XrayInbound],
        outbounds: [XrayOutbound],
        transport: XrayTransportConfig? = nil
    ) {
        self.log = log
        self.dns = dns
        self.routing = routing
        self.inbounds = inbounds
        self.outbounds = outbounds
        self.transport = transport
    }
}

struct XrayLogConfig: Codable {
    let loglevel: String
    
    init(loglevel: String = "warning") {
        self.loglevel = loglevel
    }
}

struct XrayDNSConfig: Codable {
    let servers: [String]
    
    init(servers: [String] = ["8.8.8.8", "8.8.4.4"]) {
        self.servers = servers
    }
}

struct XrayRoutingConfig: Codable {
    let rules: [XrayRoutingRule]
    
    init(rules: [XrayRoutingRule] = []) {
        self.rules = rules
    }
}

struct XrayRoutingRule: Codable {
    let type: String
    let outboundTag: String
    let domain: [String]?
    let ip: [String]?
    let port: String?
    
    init(type: String = "field", outboundTag: String, domain: [String]? = nil, ip: [String]? = nil, port: String? = nil) {
        self.type = type
        self.outboundTag = outboundTag
        self.domain = domain
        self.ip = ip
        self.port = port
    }
}

struct XrayInbound: Codable {
    let tag: String
    let port: Int
    let protocol: String
    let settings: XrayInboundSettings
    let sniffing: XraySniffingConfig?
    
    init(tag: String, port: Int, protocol: String, settings: XrayInboundSettings, sniffing: XraySniffingConfig? = nil) {
        self.tag = tag
        self.port = port
        self.protocol = protocol
        self.settings = settings
        self.sniffing = sniffing
    }
}

struct XrayInboundSettings: Codable {
    // This would vary based on protocol
    // For now, keeping it flexible with a dictionary approach
    private let storage: [String: AnyCodable]
    
    init(_ dict: [String: Any] = [:]) {
        self.storage = dict.mapValues { AnyCodable($0) }
    }
}

struct XrayOutbound: Codable {
    let tag: String
    let protocol: String
    let settings: XrayOutboundSettings
    let streamSettings: XrayStreamSettings?
    
    init(tag: String, protocol: String, settings: XrayOutboundSettings, streamSettings: XrayStreamSettings? = nil) {
        self.tag = tag
        self.protocol = protocol
        self.settings = settings
        self.streamSettings = streamSettings
    }
}

struct XrayOutboundSettings: Codable {
    // This would vary based on protocol
    private let storage: [String: AnyCodable]
    
    init(_ dict: [String: Any] = [:]) {
        self.storage = dict.mapValues { AnyCodable($0) }
    }
}

struct XrayStreamSettings: Codable {
    let network: String
    let security: String?
    let tlsSettings: XrayTLSSettings?
    let tcpSettings: XrayTCPSettings?
    let wsSettings: XrayWSSettings?
    
    init(network: String, security: String? = nil, tlsSettings: XrayTLSSettings? = nil, tcpSettings: XrayTCPSettings? = nil, wsSettings: XrayWSSettings? = nil) {
        self.network = network
        self.security = security
        self.tlsSettings = tlsSettings
        self.tcpSettings = tcpSettings
        self.wsSettings = wsSettings
    }
}

struct XrayTLSSettings: Codable {
    let allowInsecure: Bool
    let serverName: String?
    
    init(allowInsecure: Bool = false, serverName: String? = nil) {
        self.allowInsecure = allowInsecure
        self.serverName = serverName
    }
}

struct XrayTCPSettings: Codable {
    let header: XrayTCPHeader?
    
    init(header: XrayTCPHeader? = nil) {
        self.header = header
    }
}

struct XrayTCPHeader: Codable {
    let type: String
    
    init(type: String = "none") {
        self.type = type
    }
}

struct XrayWSSettings: Codable {
    let path: String
    let headers: [String: String]?
    
    init(path: String = "/", headers: [String: String]? = nil) {
        self.path = path
        self.headers = headers
    }
}

struct XraySniffingConfig: Codable {
    let enabled: Bool
    let destOverride: [String]
    
    init(enabled: Bool = true, destOverride: [String] = ["http", "tls"]) {
        self.enabled = enabled
        self.destOverride = destOverride
    }
}

struct XrayTransportConfig: Codable {
    // Transport-level configurations
    let tcpSettings: XrayTCPSettings?
    let wsSettings: XrayWSSettings?
    
    init(tcpSettings: XrayTCPSettings? = nil, wsSettings: XrayWSSettings? = nil) {
        self.tcpSettings = tcpSettings
        self.wsSettings = wsSettings
    }
}

// Helper for encoding arbitrary values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else {
            throw DecodingError.typeMismatch(Any.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type"))
        }
    }
}