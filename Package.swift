// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RayLink",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RayLink",
            targets: ["RayLink"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        
        // Networking
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
        
        // JSON Parsing
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.0"),
        
        // Keychain Services
        .package(url: "https://github.com/evgenyneu/keychain-swift.git", from: "22.0.0"),
        
        // Logging
        .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
        
        // YAML Support
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.0"),
        
        // Network Extension Helper
        .package(url: "https://github.com/passepartoutvpn/tunnelkit.git", from: "6.0.0"),
        
        // QR Code Scanning (optional)
        .package(url: "https://github.com/twostraws/CodeScanner.git", from: "2.3.0"),
        
        // Crypto
        .package(url: "https://github.com/apple/swift-crypto.git", from: "3.0.0"),
        
        // Collections
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.0"),
        
        // Async Algorithms
        .package(url: "https://github.com/apple/swift-async-algorithms.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RayLink",
            dependencies: [
                .product(name: "Alamofire", package: "alamofire"),
                .product(name: "AnyCodable", package: "anycodable"),
                .product(name: "KeychainSwift", package: "keychain-swift"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Yams", package: "yams"),
                .product(name: "TunnelKit", package: "tunnelkit"),
                .product(name: "CodeScanner", package: "codescanner"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms"),
            ],
            path: "RayLink",
            sources: [
                "App",
                "Core",
                "Features",
                "Design",
                "Models"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals"),
                .enableUpcomingFeature("ConciseMagicFile"),
                .enableUpcomingFeature("ExistentialAny"),
                .enableUpcomingFeature("ForwardTrailingClosures"),
                .enableUpcomingFeature("ImplicitOpenExistentials"),
                .enableUpcomingFeature("StrictConcurrency"),
                .unsafeFlags(["-enable-actor-data-race-checks"], .when(configuration: .debug))
            ]
        ),
        .testTarget(
            name: "RayLinkTests",
            dependencies: [
                "RayLink",
                .product(name: "Alamofire", package: "alamofire"),
                .product(name: "AnyCodable", package: "anycodable"),
            ],
            path: "Tests"
        ),
    ]
)