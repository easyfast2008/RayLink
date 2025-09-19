import SwiftUI
import Foundation
import Combine

// Re-export all public types for global access
public typealias VPNServer = RayLinkTypes.VPNServer
public typealias VPNProtocol = RayLinkTypes.VPNProtocol  
public typealias NavigationDestination = RayLinkTypes.NavigationDestination

// Make core components globally accessible
public typealias NavigationCoordinator = RayLink.NavigationCoordinator
public typealias DependencyContainer = RayLink.DependencyContainer
public typealias AppTheme = RayLink.AppTheme

// View Models
public struct ImportViewModel {
    var isScanning: Bool = false
    var importedServers: [VPNServer] = []
}

public struct HomeModel {
    var isConnected: Bool = false
    var selectedServer: VPNServer?
    var connectionTime: TimeInterval = 0
    var uploadSpeed: String = "0 KB/s"
    var downloadSpeed: String = "0 KB/s"
}