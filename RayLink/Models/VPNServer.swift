import Foundation

// MARK: - VPN Server Model
struct VPNServer: Codable, Identifiable, Equatable {
    let id: String
    var name: String
    let address: String
    let port: Int
    let protocol: VPNProtocol
    
    // Authentication
    var username: String?
    var password: String?
    var uuid: String?
    
    // Configuration
    var encryption: String?
    var alterId: Int?
    var sni: String?
    var flow: String?
    var path: String?
    var host: String?
    var type: String?
    var security: String?
    var publicKey: String?
    var privateKey: String?
    var preSharedKey: String?
    var allowedIPs: String?
    var endpoint: String?
    var configuration: [String: Any]?
    
    // Status
    var ping: Int = 0
    var isActive: Bool = true
    var lastConnected: Date?
    var bytesTransferred: Int64 = 0
    var connectionCount: Int = 0
    
    // Metadata
    var country: String?
    var city: String?
    var region: String?
    var countryCode: String?
    var flag: String?
    var provider: String?
    var tags: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    
    init(
        id: String = UUID().uuidString,
        name: String,
        address: String,
        port: Int,
        protocol: VPNProtocol,
        username: String? = nil,
        password: String? = nil,
        uuid: String? = nil,
        encryption: String? = nil,
        alterId: Int? = nil,
        sni: String? = nil,
        flow: String? = nil,
        path: String? = nil,
        host: String? = nil,
        type: String? = nil,
        security: String? = nil,
        publicKey: String? = nil,
        privateKey: String? = nil,
        preSharedKey: String? = nil,
        allowedIPs: String? = nil,
        endpoint: String? = nil,
        configuration: [String: Any]? = nil,
        ping: Int = 0,
        isActive: Bool = true,
        country: String? = nil,
        city: String? = nil,
        region: String? = nil,
        countryCode: String? = nil,
        provider: String? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.port = port
        self.protocol = `protocol`
        self.username = username
        self.password = password
        self.uuid = uuid
        self.encryption = encryption
        self.alterId = alterId
        self.sni = sni
        self.flow = flow
        self.path = path
        self.host = host
        self.type = type
        self.security = security
        self.publicKey = publicKey
        self.privateKey = privateKey
        self.preSharedKey = preSharedKey
        self.allowedIPs = allowedIPs
        self.endpoint = endpoint
        self.configuration = configuration
        self.ping = ping
        self.isActive = isActive
        self.country = country
        self.city = city
        self.region = region
        self.countryCode = countryCode
        self.provider = provider
        self.tags = tags
    }
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case id, name, address, port, protocol
        case username, password, uuid
        case encryption, alterId, sni, flow, path, host, type, security
        case publicKey, privateKey, preSharedKey, allowedIPs, endpoint
        case ping, isActive, lastConnected, bytesTransferred, connectionCount
        case country, city, region, countryCode, flag, provider, tags
        case createdAt, updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        port = try container.decode(Int.self, forKey: .port)
        protocol = try container.decode(VPNProtocol.self, forKey: .protocol)
        
        username = try container.decodeIfPresent(String.self, forKey: .username)
        password = try container.decodeIfPresent(String.self, forKey: .password)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid)
        
        encryption = try container.decodeIfPresent(String.self, forKey: .encryption)
        alterId = try container.decodeIfPresent(Int.self, forKey: .alterId)
        sni = try container.decodeIfPresent(String.self, forKey: .sni)
        flow = try container.decodeIfPresent(String.self, forKey: .flow)
        path = try container.decodeIfPresent(String.self, forKey: .path)
        host = try container.decodeIfPresent(String.self, forKey: .host)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        security = try container.decodeIfPresent(String.self, forKey: .security)
        publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey)
        privateKey = try container.decodeIfPresent(String.self, forKey: .privateKey)
        preSharedKey = try container.decodeIfPresent(String.self, forKey: .preSharedKey)
        allowedIPs = try container.decodeIfPresent(String.self, forKey: .allowedIPs)
        endpoint = try container.decodeIfPresent(String.self, forKey: .endpoint)
        
        ping = try container.decodeIfPresent(Int.self, forKey: .ping) ?? 0
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? true
        lastConnected = try container.decodeIfPresent(Date.self, forKey: .lastConnected)
        bytesTransferred = try container.decodeIfPresent(Int64.self, forKey: .bytesTransferred) ?? 0
        connectionCount = try container.decodeIfPresent(Int.self, forKey: .connectionCount) ?? 0
        
        country = try container.decodeIfPresent(String.self, forKey: .country)
        city = try container.decodeIfPresent(String.self, forKey: .city)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        countryCode = try container.decodeIfPresent(String.self, forKey: .countryCode)
        flag = try container.decodeIfPresent(String.self, forKey: .flag)
        provider = try container.decodeIfPresent(String.self, forKey: .provider)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        
        // Configuration is not included in Codable as it contains Any values
        configuration = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(port, forKey: .port)
        try container.encode(protocol, forKey: .protocol)
        
        try container.encodeIfPresent(username, forKey: .username)
        try container.encodeIfPresent(password, forKey: .password)
        try container.encodeIfPresent(uuid, forKey: .uuid)
        
        try container.encodeIfPresent(encryption, forKey: .encryption)
        try container.encodeIfPresent(alterId, forKey: .alterId)
        try container.encodeIfPresent(sni, forKey: .sni)
        try container.encodeIfPresent(flow, forKey: .flow)
        try container.encodeIfPresent(path, forKey: .path)
        try container.encodeIfPresent(host, forKey: .host)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(security, forKey: .security)
        try container.encodeIfPresent(publicKey, forKey: .publicKey)
        try container.encodeIfPresent(privateKey, forKey: .privateKey)
        try container.encodeIfPresent(preSharedKey, forKey: .preSharedKey)
        try container.encodeIfPresent(allowedIPs, forKey: .allowedIPs)
        try container.encodeIfPresent(endpoint, forKey: .endpoint)
        
        try container.encode(ping, forKey: .ping)
        try container.encode(isActive, forKey: .isActive)
        try container.encodeIfPresent(lastConnected, forKey: .lastConnected)
        try container.encode(bytesTransferred, forKey: .bytesTransferred)
        try container.encode(connectionCount, forKey: .connectionCount)
        
        try container.encodeIfPresent(country, forKey: .country)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(countryCode, forKey: .countryCode)
        try container.encodeIfPresent(flag, forKey: .flag)
        try container.encodeIfPresent(provider, forKey: .provider)
        try container.encode(tags, forKey: .tags)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
    
    // MARK: - Helper Methods
    var displayLocation: String {
        if let city = city, let country = country {
            return "\(city), \(country)"
        } else if let country = country {
            return country
        } else {
            return "Unknown"
        }
    }
    
    var pingColor: String {
        if ping < 100 {
            return "green"
        } else if ping < 200 {
            return "orange"
        } else {
            return "red"
        }
    }
    
    var connectionURL: String {
        switch `protocol` {
        case .shadowsocks:
            return generateShadowsocksURL()
        case .vmess:
            return generateVMessURL()
        case .trojan:
            return generateTrojanURL()
        case .vless:
            return generateVLessURL()
        case .ikev2:
            return generateIKEv2URL()
        case .wireguard:
            return generateWireGuardURL()
        }
    }
    
    mutating func updatePing(_ newPing: Int) {
        ping = newPing
        updatedAt = Date()
    }
    
    mutating func recordConnection() {
        connectionCount += 1
        lastConnected = Date()
        updatedAt = Date()
    }
    
    mutating func addBytesTransferred(_ bytes: Int64) {
        bytesTransferred += bytes
        updatedAt = Date()
    }
    
    // MARK: - URL Generation Methods
    private func generateShadowsocksURL() -> String {
        let method = encryption ?? "chacha20-ietf-poly1305"
        let pass = password ?? ""
        let auth = "\(method):\(pass)".data(using: .utf8)?.base64EncodedString() ?? ""
        return "ss://\(auth)@\(address):\(port)#\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
    }
    
    private func generateVMessURL() -> String {
        // Simplified VMess URL generation
        let config = VMessConfig(
            v: "2",
            ps: name,
            add: address,
            port: String(port),
            id: uuid ?? "",
            aid: String(alterId ?? 0),
            scy: security ?? "auto",
            net: type ?? "tcp",
            type: "none",
            host: host ?? "",
            path: path ?? "",
            tls: security == "tls" ? "tls" : "",
            sni: sni ?? ""
        )
        
        if let jsonData = try? JSONEncoder().encode(config),
           let jsonString = String(data: jsonData, encoding: .utf8),
           let base64String = jsonString.data(using: .utf8)?.base64EncodedString() {
            return "vmess://\(base64String)"
        }
        return ""
    }
    
    private func generateTrojanURL() -> String {
        let pass = password ?? ""
        return "trojan://\(pass)@\(address):\(port)?sni=\(sni ?? address)#\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
    }
    
    private func generateVLessURL() -> String {
        let id = uuid ?? ""
        return "vless://\(id)@\(address):\(port)?encryption=\(encryption ?? "none")&flow=\(flow ?? "")#\(name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? name)"
    }
    
    private func generateIKEv2URL() -> String {
        // IKEv2 doesn't have a standard URL format
        return "ikev2://\(username ?? ""):\(password ?? "")@\(address):\(port)"
    }
    
    private func generateWireGuardURL() -> String {
        // WireGuard config format (simplified)
        return "wireguard://\(publicKey ?? "")@\(address):\(port)"
    }
    
    // MARK: - Dictionary Conversion
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "name": name,
            "address": address,
            "port": port,
            "protocol": `protocol`.rawValue,
            "ping": ping,
            "isActive": isActive,
            "bytesTransferred": bytesTransferred,
            "connectionCount": connectionCount,
            "tags": tags,
            "createdAt": createdAt.timeIntervalSince1970,
            "updatedAt": updatedAt.timeIntervalSince1970
        ]
        
        // Add optional fields
        dict["username"] = username
        dict["password"] = password
        dict["uuid"] = uuid
        dict["encryption"] = encryption
        dict["alterId"] = alterId
        dict["sni"] = sni
        dict["flow"] = flow
        dict["path"] = path
        dict["host"] = host
        dict["type"] = type
        dict["security"] = security
        dict["country"] = country
        dict["city"] = city
        dict["region"] = region
        dict["countryCode"] = countryCode
        dict["provider"] = provider
        
        if let lastConnected = lastConnected {
            dict["lastConnected"] = lastConnected.timeIntervalSince1970
        }
        
        if let configuration = configuration {
            dict["configuration"] = configuration
        }
        
        return dict
    }
    
    static func from(dictionary dict: [String: Any]) -> VPNServer? {
        guard let id = dict["id"] as? String,
              let name = dict["name"] as? String,
              let address = dict["address"] as? String,
              let port = dict["port"] as? Int,
              let protocolString = dict["protocol"] as? String,
              let vpnProtocol = VPNProtocol(rawValue: protocolString) else {
            return nil
        }
        
        var server = VPNServer(
            id: id,
            name: name,
            address: address,
            port: port,
            protocol: vpnProtocol
        )
        
        // Set optional fields
        server.username = dict["username"] as? String
        server.password = dict["password"] as? String
        server.uuid = dict["uuid"] as? String
        server.encryption = dict["encryption"] as? String
        server.alterId = dict["alterId"] as? Int
        server.sni = dict["sni"] as? String
        server.flow = dict["flow"] as? String
        server.path = dict["path"] as? String
        server.host = dict["host"] as? String
        server.type = dict["type"] as? String
        server.security = dict["security"] as? String
        server.ping = dict["ping"] as? Int ?? 0
        server.isActive = dict["isActive"] as? Bool ?? true
        server.bytesTransferred = dict["bytesTransferred"] as? Int64 ?? 0
        server.connectionCount = dict["connectionCount"] as? Int ?? 0
        server.country = dict["country"] as? String
        server.city = dict["city"] as? String
        server.region = dict["region"] as? String
        server.countryCode = dict["countryCode"] as? String
        server.provider = dict["provider"] as? String
        server.tags = dict["tags"] as? [String] ?? []
        server.configuration = dict["configuration"] as? [String: Any]
        
        if let createdAtInterval = dict["createdAt"] as? TimeInterval {
            server.createdAt = Date(timeIntervalSince1970: createdAtInterval)
        }
        
        if let updatedAtInterval = dict["updatedAt"] as? TimeInterval {
            server.updatedAt = Date(timeIntervalSince1970: updatedAtInterval)
        }
        
        if let lastConnectedInterval = dict["lastConnected"] as? TimeInterval {
            server.lastConnected = Date(timeIntervalSince1970: lastConnectedInterval)
        }
        
        return server
    }
}

// MARK: - VPN Protocol Enum
enum VPNProtocol: String, Codable, CaseIterable {
    case shadowsocks = "shadowsocks"
    case vmess = "vmess"
    case vless = "vless"
    case trojan = "trojan"
    case ikev2 = "ikev2"
    case wireguard = "wireguard"
    
    var displayName: String {
        switch self {
        case .shadowsocks:
            return "Shadowsocks"
        case .vmess:
            return "VMess"
        case .vless:
            return "VLESS"
        case .trojan:
            return "Trojan"
        case .ikev2:
            return "IKEv2"
        case .wireguard:
            return "WireGuard"
        }
    }
    
    var defaultPort: Int {
        switch self {
        case .shadowsocks:
            return 8388
        case .vmess, .vless:
            return 443
        case .trojan:
            return 443
        case .ikev2:
            return 500
        case .wireguard:
            return 51820
        }
    }
    
    var requiresEncryption: Bool {
        switch self {
        case .shadowsocks, .vmess, .vless:
            return true
        case .trojan, .ikev2, .wireguard:
            return false
        }
    }
    
    var supportsUUID: Bool {
        switch self {
        case .vmess, .vless:
            return true
        case .shadowsocks, .trojan, .ikev2, .wireguard:
            return false
        }
    }
}

// MARK: - VMess Configuration Model
private struct VMessConfig: Codable {
    let v: String
    let ps: String
    let add: String
    let port: String
    let id: String
    let aid: String
    let scy: String
    let net: String
    let type: String
    let host: String
    let path: String
    let tls: String
    let sni: String
}