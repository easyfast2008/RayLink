import Foundation

struct XrayConfigBuilder {
    
    static func buildConfig(for server: VPNServer) throws -> XrayConfig {
        let inbound = createInbound()
        let outbound = try createOutbound(for: server)
        let routing = createRouting()
        let dns = createDNS()
        
        return XrayConfig(
            log: XrayLogConfig(loglevel: "warning"),
            dns: dns,
            routing: routing,
            inbounds: [inbound],
            outbounds: [outbound, createDirectOutbound(), createBlockOutbound()]
        )
    }
    
    // MARK: - Inbound Configuration
    
    private static func createInbound() -> XrayInbound {
        let settings = XrayInboundSettings([
            "auth": "noauth",
            "udp": true,
            "allowTransparent": false
        ])
        
        let sniffing = XraySniffingConfig(
            enabled: true,
            destOverride: ["http", "tls"]
        )
        
        return XrayInbound(
            tag: "socks-in",
            port: 10808,
            protocol: "socks",
            settings: settings,
            sniffing: sniffing
        )
    }
    
    // MARK: - Outbound Configuration
    
    private static func createOutbound(for server: VPNServer) throws -> XrayOutbound {
        switch server.protocol {
        case .vmess:
            return try createVMessOutbound(for: server)
        case .vless:
            return try createVLessOutbound(for: server)
        case .trojan:
            return try createTrojanOutbound(for: server)
        case .shadowsocks:
            return try createShadowsocksOutbound(for: server)
        case .wireguard:
            throw XrayConfigError.unsupportedProtocol("WireGuard not supported in Xray-core")
        case .ikev2:
            throw XrayConfigError.unsupportedProtocol("IKEv2 not supported in Xray-core")
        }
    }
    
    private static func createVMessOutbound(for server: VPNServer) throws -> XrayOutbound {
        guard let uuid = server.uuid else {
            throw XrayConfigError.missingField("UUID is required for VMess")
        }
        
        let user: [String: Any] = [
            "id": uuid,
            "alterId": server.alterId ?? 0,
            "security": server.security ?? "auto"
        ]
        
        let vnext: [String: Any] = [
            "address": server.address,
            "port": server.port,
            "users": [user]
        ]
        
        let settings = XrayOutboundSettings([
            "vnext": [vnext]
        ])
        
        let streamSettings = createStreamSettings(for: server)
        
        return XrayOutbound(
            tag: "proxy",
            protocol: "vmess",
            settings: settings,
            streamSettings: streamSettings
        )
    }
    
    private static func createVLessOutbound(for server: VPNServer) throws -> XrayOutbound {
        guard let uuid = server.uuid else {
            throw XrayConfigError.missingField("UUID is required for VLESS")
        }
        
        let user: [String: Any] = [
            "id": uuid,
            "encryption": server.encryption ?? "none",
            "flow": server.flow ?? ""
        ]
        
        let vnext: [String: Any] = [
            "address": server.address,
            "port": server.port,
            "users": [user]
        ]
        
        let settings = XrayOutboundSettings([
            "vnext": [vnext]
        ])
        
        let streamSettings = createStreamSettings(for: server)
        
        return XrayOutbound(
            tag: "proxy",
            protocol: "vless",
            settings: settings,
            streamSettings: streamSettings
        )
    }
    
    private static func createTrojanOutbound(for server: VPNServer) throws -> XrayOutbound {
        guard let password = server.password else {
            throw XrayConfigError.missingField("Password is required for Trojan")
        }
        
        let serverConfig: [String: Any] = [
            "address": server.address,
            "port": server.port,
            "password": password
        ]
        
        let settings = XrayOutboundSettings([
            "servers": [serverConfig]
        ])
        
        let streamSettings = createStreamSettings(for: server)
        
        return XrayOutbound(
            tag: "proxy",
            protocol: "trojan",
            settings: settings,
            streamSettings: streamSettings
        )
    }
    
    private static func createShadowsocksOutbound(for server: VPNServer) throws -> XrayOutbound {
        guard let password = server.password else {
            throw XrayConfigError.missingField("Password is required for Shadowsocks")
        }
        
        let serverConfig: [String: Any] = [
            "address": server.address,
            "port": server.port,
            "method": server.encryption ?? "chacha20-ietf-poly1305",
            "password": password
        ]
        
        let settings = XrayOutboundSettings([
            "servers": [serverConfig]
        ])
        
        return XrayOutbound(
            tag: "proxy",
            protocol: "shadowsocks",
            settings: settings
        )
    }
    
    // MARK: - Stream Settings
    
    private static func createStreamSettings(for server: VPNServer) -> XrayStreamSettings {
        let network = server.type ?? "tcp"
        let security = server.security
        
        var streamSettings = XrayStreamSettings(network: network, security: security)
        
        // TLS Settings
        if security == "tls" {
            streamSettings = XrayStreamSettings(
                network: network,
                security: security,
                tlsSettings: XrayTLSSettings(
                    allowInsecure: false,
                    serverName: server.sni ?? server.host
                )
            )
        }
        
        // Network-specific settings
        switch network {
        case "ws":
            streamSettings = XrayStreamSettings(
                network: network,
                security: security,
                tlsSettings: streamSettings.tlsSettings,
                wsSettings: XrayWSSettings(
                    path: server.path ?? "/",
                    headers: server.host != nil ? ["Host": server.host!] : nil
                )
            )
            
        case "tcp":
            if let headerType = server.type, headerType == "http" {
                streamSettings = XrayStreamSettings(
                    network: network,
                    security: security,
                    tlsSettings: streamSettings.tlsSettings,
                    tcpSettings: XrayTCPSettings(
                        header: XrayTCPHeader(type: "http")
                    )
                )
            }
            
        default:
            break
        }
        
        return streamSettings
    }
    
    // MARK: - Routing Configuration
    
    private static func createRouting() -> XrayRoutingConfig {
        let rules: [XrayRoutingRule] = [
            // Block ads and tracking
            XrayRoutingRule(
                outboundTag: "block",
                domain: [
                    "geosite:ads",
                    "geosite:category-ads-all"
                ]
            ),
            
            // Direct connection for local addresses
            XrayRoutingRule(
                outboundTag: "direct",
                ip: [
                    "geoip:private",
                    "geoip:cn"
                ]
            ),
            
            // Direct connection for China domains (optional)
            XrayRoutingRule(
                outboundTag: "direct",
                domain: [
                    "geosite:cn"
                ]
            )
        ]
        
        return XrayRoutingConfig(rules: rules)
    }
    
    // MARK: - DNS Configuration
    
    private static func createDNS() -> XrayDNSConfig {
        return XrayDNSConfig(servers: [
            "8.8.8.8",
            "8.8.4.4",
            "1.1.1.1",
            "1.0.0.1"
        ])
    }
    
    // MARK: - Additional Outbounds
    
    private static func createDirectOutbound() -> XrayOutbound {
        return XrayOutbound(
            tag: "direct",
            protocol: "freedom",
            settings: XrayOutboundSettings([:])
        )
    }
    
    private static func createBlockOutbound() -> XrayOutbound {
        return XrayOutbound(
            tag: "block",
            protocol: "blackhole",
            settings: XrayOutboundSettings([
                "response": [
                    "type": "http"
                ]
            ])
        )
    }
}

// MARK: - Custom Configurations

extension XrayConfigBuilder {
    
    static func buildCustomConfig(
        server: VPNServer,
        routingRules: [CustomRoutingRule] = [],
        dnsServers: [String] = ["8.8.8.8", "8.8.4.4"],
        enableAdBlocking: Bool = true,
        enableDirectChina: Bool = false
    ) throws -> XrayConfig {
        
        let inbound = createInbound()
        let outbound = try createOutbound(for: server)
        let routing = createCustomRouting(
            rules: routingRules,
            enableAdBlocking: enableAdBlocking,
            enableDirectChina: enableDirectChina
        )
        let dns = XrayDNSConfig(servers: dnsServers)
        
        return XrayConfig(
            log: XrayLogConfig(loglevel: "warning"),
            dns: dns,
            routing: routing,
            inbounds: [inbound],
            outbounds: [outbound, createDirectOutbound(), createBlockOutbound()]
        )
    }
    
    private static func createCustomRouting(
        rules: [CustomRoutingRule],
        enableAdBlocking: Bool,
        enableDirectChina: Bool
    ) -> XrayRoutingConfig {
        
        var xrayRules: [XrayRoutingRule] = []
        
        // Add custom rules first
        for rule in rules {
            let xrayRule = XrayRoutingRule(
                outboundTag: rule.outbound,
                domain: rule.domains.isEmpty ? nil : rule.domains,
                ip: rule.ips.isEmpty ? nil : rule.ips,
                port: rule.port
            )
            xrayRules.append(xrayRule)
        }
        
        // Add ad blocking rules
        if enableAdBlocking {
            xrayRules.append(XrayRoutingRule(
                outboundTag: "block",
                domain: [
                    "geosite:ads",
                    "geosite:category-ads-all"
                ]
            ))
        }
        
        // Add China direct rules
        if enableDirectChina {
            xrayRules.append(XrayRoutingRule(
                outboundTag: "direct",
                domain: ["geosite:cn"]
            ))
            
            xrayRules.append(XrayRoutingRule(
                outboundTag: "direct",
                ip: ["geoip:cn"]
            ))
        }
        
        // Always add private IP direct rule
        xrayRules.append(XrayRoutingRule(
            outboundTag: "direct",
            ip: ["geoip:private"]
        ))
        
        return XrayRoutingConfig(rules: xrayRules)
    }
}

// MARK: - Supporting Types

struct CustomRoutingRule {
    let domains: [String]
    let ips: [String]
    let port: String?
    let outbound: String
    
    init(domains: [String] = [], ips: [String] = [], port: String? = nil, outbound: String = "proxy") {
        self.domains = domains
        self.ips = ips
        self.port = port
        self.outbound = outbound
    }
}

enum XrayConfigError: Error, LocalizedError {
    case missingField(String)
    case unsupportedProtocol(String)
    case invalidConfiguration(String)
    
    var errorDescription: String? {
        switch self {
        case .missingField(let field):
            return "Missing required field: \(field)"
        case .unsupportedProtocol(let message):
            return "Unsupported protocol: \(message)"
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        }
    }
}