import SwiftUI
import Foundation
import Combine

public struct HomeModel {
    var isConnected: Bool = false
    var selectedServer: VPNServer?
    var connectionTime: TimeInterval = 0
    var uploadSpeed: String = "0 KB/s"
    var downloadSpeed: String = "0 KB/s"
}