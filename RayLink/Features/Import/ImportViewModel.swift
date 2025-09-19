import Foundation
// Global types imported via RayLinkTypes
import SwiftUI
import Combine

@MainActor
final class ImportViewModel: ObservableObject {
    @Published var importedServers: [VPNServer] = []
    @Published var isImporting = false
    @Published var importStatus = ""
    @Published var showResult = false
    @Published var resultMessage = ""
    @Published var showError = false
    @Published var errorMessage = ""
    
    private var networkService: NetworkServiceProtocol?
    private var storageManager: StorageManagerProtocol?
    
    func setup(networkService: NetworkServiceProtocol, storageManager: StorageManagerProtocol) {
        self.networkService = networkService
        self.storageManager = storageManager
    }
    
    func importFromSubscription(_ urlString: String) async {
        guard let url = URL(string: urlString),
              let networkService = networkService else {
            showErrorMessage("Invalid URL")
            return
        }
        
        isImporting = true
        importStatus = "Downloading subscription..."
        
        do {
            let data = try await networkService.downloadConfig(from: url)
            await parseConfigurationData(data, source: "Subscription")
        } catch {
            showErrorMessage("Failed to download subscription: \(error.localizedDescription)")
        }
        
        isImporting = false
        importStatus = ""
    }
    
    func importFromFile(_ url: URL) async {
        isImporting = true
        importStatus = "Reading file..."
        
        do {
            let data = try Data(contentsOf: url)
            await parseConfigurationData(data, source: "File")
        } catch {
            showErrorMessage("Failed to read file: \(error.localizedDescription)")
        }
        
        isImporting = false
        importStatus = ""
    }
    
    func importFromClipboard() async {
        guard let clipboardString = UIPasteboard.general.string else {
            showErrorMessage("No text found in clipboard")
            return
        }
        
        isImporting = true
        importStatus = "Processing clipboard content..."
        
        let data = clipboardString.data(using: .utf8) ?? Data()
        await parseConfigurationData(data, source: "Clipboard")
        
        isImporting = false
        importStatus = ""
    }
    
    func importFromQRCode(_ qrContent: String) async {
        isImporting = true
        importStatus = "Processing QR code..."
        
        let data = qrContent.data(using: .utf8) ?? Data()
        await parseConfigurationData(data, source: "QR Code")
        
        isImporting = false
        importStatus = ""
    }
    
    func importAllServers() async {
        guard let storageManager = storageManager else {
            showErrorMessage("Storage manager not available")
            return
        }
        
        isImporting = true
        importStatus = "Saving servers..."
        
        do {
            // Load existing servers
            var existingServers = try storageManager.loadServers()
            
            // Add new servers (avoid duplicates based on address and port)
            var addedCount = 0
            for server in importedServers {
                let isDuplicate = existingServers.contains { existing in
                    existing.address == server.address && existing.port == server.port
                }
                
                if !isDuplicate {
                    existingServers.append(server)
                    addedCount += 1
                }
            }
            
            // Save updated server list
            try storageManager.saveServers(existingServers)
            
            // Clear imported servers
            clearImportedServers()
            
            // Show result
            if addedCount > 0 {
                showResultMessage("Successfully imported \(addedCount) servers")
            } else {
                showResultMessage("No new servers to import (all were duplicates)")
            }
            
        } catch {
            showErrorMessage("Failed to save servers: \(error.localizedDescription)")
        }
        
        isImporting = false
        importStatus = ""
    }
    
    func clearImportedServers() {
        importedServers.removeAll()
    }
    
    func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    private func showResultMessage(_ message: String) {
        resultMessage = message
        showResult = true
    }
    
    private func parseConfigurationData(_ data: Data, source: String) async {
        importStatus = "Parsing configuration..."
        
        guard let content = String(data: data, encoding: .utf8) else {
            showErrorMessage("Invalid file encoding")
            return
        }
        
        var newServers: [VPNServer] = []
        
        // Try different parsing methods
        
        // 1. Try JSON format
        if let jsonServers = try? parseJSONConfiguration(data) {
            newServers.append(contentsOf: jsonServers)
        }
        // 2. Try base64 encoded subscription
        else if let base64Servers = parseBase64Subscription(content) {
            newServers.append(contentsOf: base64Servers)
        }
        // 3. Try individual server URLs
        else if let urlServers = parseServerURLs(content) {
            newServers.append(contentsOf: urlServers)
        }
        // 4. Try YAML format (simplified)
        else if let yamlServers = parseYAMLConfiguration(content) {
            newServers.append(contentsOf: yamlServers)
        }
        else {
            showErrorMessage("Unsupported configuration format")
            return
        }
        
        if newServers.isEmpty {
            showErrorMessage("No valid servers found in \(source.lowercased())")
        } else {
            importedServers = newServers
            showResultMessage("Found \(newServers.count) servers in \(source.lowercased())")
        }
    }
    
    private func parseJSONConfiguration(_ data: Data) throws -> [VPNServer] {
        // Try standard RayLink format
        if let config = try? JSONDecoder().decode(RayLinkConfig.self, from: data) {
            return config.servers
        }
        
        // Try array of servers
        if let servers = try? JSONDecoder().decode([VPNServer].self, from: data) {
            return servers
        }
        
        // Try V2Ray format
        if let v2rayConfig = try? JSONDecoder().decode(V2RayConfig.self, from: data) {
            return parseV2RayConfig(v2rayConfig)
        }
        
        throw ConfigurationError.invalidFormat
    }
    
    private func parseBase64Subscription(_ content: String) -> [VPNServer]? {
        // Handle base64 encoded subscription content
        let lines = content.components(separatedBy: .newlines)
        var servers: [VPNServer] = []
        
        for line in lines {
            let trimmedLine = line.trimmed()
            if trimmedLine.isEmpty { continue }
            
            // Try to decode base64
            if let decodedData = Data(base64Encoded: trimmedLine),
               let decodedString = String(data: decodedData, encoding: .utf8) {
                
                // Parse individual server URLs from decoded content
                let serverLines = decodedString.components(separatedBy: .newlines)
                for serverLine in serverLines {
                    if let server = parseServerURL(serverLine.trimmed()) {
                        servers.append(server)
                    }
                }
            } else {
                // Try parsing as direct server URL
                if let server = parseServerURL(trimmedLine) {
                    servers.append(server)
                }
            }
        }
        
        return servers.isEmpty ? nil : servers
    }
    
    private func parseServerURLs(_ content: String) -> [VPNServer]? {
        let lines = content.components(separatedBy: .newlines)
        var servers: [VPNServer] = []
        
        for line in lines {
            let trimmedLine = line.trimmed()
            if let server = parseServerURL(trimmedLine) {
                servers.append(server)
            }
        }
        
        return servers.isEmpty ? nil : servers
    }
    
    private func parseServerURL(_ urlString: String) -> VPNServer? {
        guard let url = URL(string: urlString) else { return nil }
        
        switch url.scheme?.lowercased() {
        case "ss":
            return parseShadowsocksURL(url)
        case "vmess":
            return parseVMessURL(url)
        case "trojan":
            return parseTrojanURL(url)
        case "vless":
            return parseVLessURL(url)
        default:
            return nil
        }
    }
    
    private func parseShadowsocksURL(_ url: URL) -> VPNServer? {
        // ss://method:password@server:port#name
        guard let host = url.host, let port = url.port else { return nil }
        
        let userInfo = url.user ?? ""
        let components = userInfo.components(separatedBy: ":")
        let method = components.first ?? "chacha20-ietf-poly1305"
        let password = components.count > 1 ? components[1] : ""
        
        let name = url.fragment?.removingPercentEncoding ?? "\(host):\(port)"
        
        return VPNServer(
            id: UUID().uuidString,
            name: name,
            address: host,
            port: port,
            protocol: .shadowsocks,
            password: password,
            encryption: method
        )
    }
    
    private func parseVMessURL(_ url: URL) -> VPNServer? {
        // Simplified VMess URL parsing
        guard let host = url.host, let port = url.port else { return nil }
        
        let name = url.fragment?.removingPercentEncoding ?? "\(host):\(port)"
        let uuid = url.user ?? UUID().uuidString
        
        return VPNServer(
            id: UUID().uuidString,
            name: name,
            address: host,
            port: port,
            protocol: .vmess,
            uuid: uuid
        )
    }
    
    private func parseTrojanURL(_ url: URL) -> VPNServer? {
        // trojan://password@server:port#name
        guard let host = url.host, let port = url.port else { return nil }
        
        let password = url.user ?? ""
        let name = url.fragment?.removingPercentEncoding ?? "\(host):\(port)"
        
        return VPNServer(
            id: UUID().uuidString,
            name: name,
            address: host,
            port: port,
            protocol: .trojan,
            password: password
        )
    }
    
    private func parseVLessURL(_ url: URL) -> VPNServer? {
        // vless://uuid@server:port#name
        guard let host = url.host, let port = url.port else { return nil }
        
        let uuid = url.user ?? UUID().uuidString
        let name = url.fragment?.removingPercentEncoding ?? "\(host):\(port)"
        
        return VPNServer(
            id: UUID().uuidString,
            name: name,
            address: host,
            port: port,
            protocol: .vless,
            uuid: uuid
        )
    }
    
    private func parseYAMLConfiguration(_ content: String) -> [VPNServer]? {
        // Simplified YAML parsing (basic key-value pairs)
        // This is a very basic implementation - a real app would use a proper YAML parser
        let lines = content.components(separatedBy: .newlines)
        var servers: [VPNServer] = []
        var currentServer: [String: String] = [:]
        
        for line in lines {
            let trimmedLine = line.trimmed()
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") { continue }
            
            if trimmedLine.hasPrefix("-") {
                // New server entry
                if !currentServer.isEmpty {
                    if let server = createServerFromDict(currentServer) {
                        servers.append(server)
                    }
                    currentServer.removeAll()
                }
            } else if trimmedLine.contains(":") {
                let components = trimmedLine.components(separatedBy: ":")
                if components.count >= 2 {
                    let key = components[0].trimmed()
                    let value = components.dropFirst().joined(separator: ":").trimmed()
                    currentServer[key] = value
                }
            }
        }
        
        // Add last server if exists
        if !currentServer.isEmpty {
            if let server = createServerFromDict(currentServer) {
                servers.append(server)
            }
        }
        
        return servers.isEmpty ? nil : servers
    }
    
    private func createServerFromDict(_ dict: [String: String]) -> VPNServer? {
        guard let name = dict["name"],
              let address = dict["server"] ?? dict["address"],
              let portString = dict["port"],
              let port = Int(portString),
              let protocolString = dict["protocol"],
              let vpnProtocol = VPNProtocol(rawValue: protocolString.lowercased()) else {
            return nil
        }
        
        return VPNServer(
            id: UUID().uuidString,
            name: name,
            address: address,
            port: port,
            protocol: vpnProtocol,
            username: dict["username"],
            password: dict["password"],
            uuid: dict["uuid"],
            encryption: dict["encryption"] ?? dict["method"]
        )
    }
    
    private func parseV2RayConfig(_ config: V2RayConfig) -> [VPNServer] {
        // Parse V2Ray configuration format
        // This is a simplified implementation
        var servers: [VPNServer] = []
        
        for outbound in config.outbounds ?? [] {
            if let server = parseV2RayOutbound(outbound) {
                servers.append(server)
            }
        }
        
        return servers
    }
    
    private func parseV2RayOutbound(_ outbound: V2RayOutbound) -> VPNServer? {
        guard let settings = outbound.settings,
              let vnext = settings.vnext?.first else {
            return nil
        }
        
        let protocolType = VPNProtocol(rawValue: outbound.protocol?.lowercased() ?? "vmess") ?? .vmess
        let name = outbound.tag ?? "\(vnext.address):\(vnext.port)"
        
        return VPNServer(
            id: UUID().uuidString,
            name: name,
            address: vnext.address,
            port: vnext.port,
            protocol: protocolType,
            uuid: vnext.users?.first?.id
        )
    }
}

// MARK: - Configuration Models

enum ConfigurationError: Error {
    case invalidFormat
    case unsupportedVersion
    case missingRequiredFields
}

struct RayLinkConfig: Codable {
    let version: String?
    let servers: [VPNServer]
}

struct V2RayConfig: Codable {
    let outbounds: [V2RayOutbound]?
}

struct V2RayOutbound: Codable {
    let tag: String?
    let protocol: String?
    let settings: V2RayOutboundSettings?
}

struct V2RayOutboundSettings: Codable {
    let vnext: [V2RayVNext]?
}

struct V2RayVNext: Codable {
    let address: String
    let port: Int
    let users: [V2RayUser]?
}

struct V2RayUser: Codable {
    let id: String
    let alterId: Int?
    let security: String?
}