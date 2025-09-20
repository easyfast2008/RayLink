import Foundation
import Combine

// MARK: - Storage Manager Protocol
protocol StorageManagerProtocol {
    func save<T: Codable>(_ object: T, for key: StorageKey) throws
    func load<T: Codable>(_ type: T.Type, for key: StorageKey) throws -> T?
    func delete(for key: StorageKey) throws
    func exists(for key: StorageKey) -> Bool
    func saveServers(_ servers: [VPNServer]) throws
    func loadServers() throws -> [VPNServer]
    func saveUserSettings(_ settings: UserSettings) throws
    func loadUserSettings() throws -> UserSettings
    func clearAllData()
}

// MARK: - Storage Keys
enum StorageKey: String, CaseIterable {
    case servers = "raylink.servers"
    case selectedServer = "raylink.selected_server"
    case userSettings = "raylink.user_settings"
    case vpnConfigurations = "raylink.vpn_configs"
    case subscriptions = "raylink.subscriptions"
    case connectionHistory = "raylink.connection_history"
    case appTheme = "raylink.app_theme"
    case autoConnect = "raylink.auto_connect"
    case lastConnectedServer = "raylink.last_connected_server"
    case connectionMode = "raylink.connection_mode"
}

// MARK: - Storage Errors
enum StorageError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case fileNotFound
    case accessDenied
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode object"
        case .decodingFailed:
            return "Failed to decode object"
        case .fileNotFound:
            return "File not found"
        case .accessDenied:
            return "Access denied to storage"
        case .unknown:
            return "Unknown storage error"
        }
    }
}

// MARK: - Storage Manager Implementation
final class StorageManager: StorageManagerProtocol, ObservableObject {
    private let userDefaults: UserDefaults
    private let fileManager: FileManager
    private let documentsDirectory: URL
    
    init(userDefaults: UserDefaults = .standard, fileManager: FileManager = .default) {
        self.userDefaults = userDefaults
        self.fileManager = fileManager
        
        guard let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("Unable to access documents directory")
        }
        self.documentsDirectory = documentsPath
        
        createDirectoriesIfNeeded()
    }
    
    private func createDirectoriesIfNeeded() {
        let rayLinkDirectory = documentsDirectory.appendingPathComponent("RayLink")
        
        if !fileManager.fileExists(atPath: rayLinkDirectory.path) {
            try? fileManager.createDirectory(at: rayLinkDirectory, withIntermediateDirectories: true)
        }
    }
    
    // MARK: - Public Methods
    func save<T: Codable>(_ object: T, for key: StorageKey) throws {
        do {
            let data = try JSONEncoder().encode(object)
            
            switch key {
            case .userSettings, .appTheme, .autoConnect, .lastConnectedServer:
                // Store simple settings in UserDefaults
                userDefaults.set(data, forKey: key.rawValue)
            default:
                // Store complex objects in files
                let fileURL = documentsDirectory.appendingPathComponent("RayLink").appendingPathComponent("\(key.rawValue).json")
                try data.write(to: fileURL)
            }
        } catch {
            throw StorageError.encodingFailed
        }
    }
    
    func load<T: Codable>(_ type: T.Type, for key: StorageKey) throws -> T? {
        let data: Data?
        
        switch key {
        case .userSettings, .appTheme, .autoConnect, .lastConnectedServer:
            data = userDefaults.data(forKey: key.rawValue)
        default:
            let fileURL = documentsDirectory.appendingPathComponent("RayLink").appendingPathComponent("\(key.rawValue).json")
            data = try? Data(contentsOf: fileURL)
        }
        
        guard let data = data else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            throw StorageError.decodingFailed
        }
    }
    
    func delete(for key: StorageKey) throws {
        switch key {
        case .userSettings, .appTheme, .autoConnect, .lastConnectedServer:
            userDefaults.removeObject(forKey: key.rawValue)
        default:
            let fileURL = documentsDirectory.appendingPathComponent("RayLink").appendingPathComponent("\(key.rawValue).json")
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    func exists(for key: StorageKey) -> Bool {
        switch key {
        case .userSettings, .appTheme, .autoConnect, .lastConnectedServer:
            return userDefaults.data(forKey: key.rawValue) != nil
        default:
            let fileURL = documentsDirectory.appendingPathComponent("RayLink").appendingPathComponent("\(key.rawValue).json")
            return fileManager.fileExists(atPath: fileURL.path)
        }
    }
    
    // MARK: - Convenience Methods
    func saveServers(_ servers: [VPNServer]) throws {
        try save(servers, for: .servers)
    }
    
    func loadServers() throws -> [VPNServer] {
        return try load([VPNServer].self, for: .servers) ?? []
    }
    
    func saveUserSettings(_ settings: UserSettings) throws {
        try save(settings, for: .userSettings)
    }
    
    func loadUserSettings() throws -> UserSettings {
        return try load(UserSettings.self, for: .userSettings) ?? UserSettings.default
    }
    
    func clearAllData() {
        StorageKey.allCases.forEach { key in
            try? delete(for: key)
        }
    }
}