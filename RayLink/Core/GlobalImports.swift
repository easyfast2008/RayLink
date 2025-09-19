// GlobalImports.swift
// Import this file in each view/model file to get access to all common types

import Foundation
import SwiftUI
import Combine

// Re-export all types from RayLinkTypes
public typealias VPNServer = VPNServer
public typealias VPNProtocol = VPNProtocol
public typealias VPNConnectionStatus = VPNConnectionStatus
public typealias UserSettings = UserSettings
public typealias VPNSubscription = VPNSubscription
public typealias SpeedTestResult = SpeedTestResult
public typealias NavigationDestination = NavigationDestination
public typealias AlertItem = AlertItem
public typealias ConnectionMode = ConnectionMode

// Re-export protocols
public typealias VPNManagerProtocol = VPNManagerProtocol
public typealias StorageManagerProtocol = StorageManagerProtocol
public typealias NetworkServiceProtocol = NetworkServiceProtocol