# RayLink VPN

A modern, feature-rich VPN client for iOS built with SwiftUI and following MVVM-C architecture pattern.

## Features

- **Multiple VPN Protocols**: Support for Shadowsocks, VMess, VLESS, Trojan, IKEv2, and WireGuard
- **Server Management**: Easy server addition, import from subscription URLs, and QR code scanning
- **Modern UI**: Built with SwiftUI following Apple's Human Interface Guidelines
- **Dark Mode Support**: Automatic theme switching based on system preferences
- **Connection Statistics**: Real-time data usage tracking and connection analytics
- **Import/Export**: Support for various configuration formats (JSON, YAML, subscription URLs)
- **Trusted Networks**: Automatic VPN management based on network location
- **Speed Testing**: Built-in network speed testing capabilities
- **Advanced Settings**: DNS configuration, routing rules, and connection optimization

## Architecture

RayLink follows the **MVVM-C (Model-View-ViewModel-Coordinator)** architecture pattern:

### Directory Structure

```
RayLink/
├── App/                    # App entry point and configuration
├── Core/                   # Core services and utilities
│   ├── Network/           # Network service and API handling
│   ├── Storage/           # Data persistence and storage management
│   ├── VPN/               # VPN connection management
│   └── Extensions/        # Swift extensions and utilities
├── Features/              # Feature modules
│   ├── Home/              # Main dashboard and connection status
│   ├── ServerList/        # Server management and selection
│   ├── Settings/          # App settings and configuration
│   └── Import/            # Server import and subscription management
├── Design/                # Design system and UI components
│   ├── Theme/             # App theme and styling
│   ├── Components/        # Reusable UI components
│   └── Animations/        # Custom animations and transitions
├── Models/                # Data models and entities
└── Resources/             # Assets, localizations, and resources
```

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Dependencies

The project uses Swift Package Manager for dependency management:

- **Alamofire**: HTTP networking
- **KeychainSwift**: Secure credential storage
- **Yams**: YAML parsing support
- **TunnelKit**: VPN protocol implementations
- **CodeScanner**: QR code scanning
- **Swift Crypto**: Cryptographic operations

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/raylink-ios.git
cd raylink-ios
```

2. Open the project in Xcode:
```bash
open RayLink.xcodeproj
```

3. Build and run the project on your device or simulator.

## Configuration

### VPN Protocols Support

#### Shadowsocks
- Method: AES-GCM, ChaCha20-Poly1305
- Plugin support for obfuscation
- UDP relay support

#### VMess/VLESS
- Transport: TCP, mKCP, WebSocket, HTTP/2, gRPC
- Security: Auto, None, ChaCha20-Poly1305, AES-GCM
- Obfuscation: TLS, WebSocket headers

#### Trojan
- TLS encryption
- SNI configuration
- Fallback support

#### IKEv2
- Certificate and PSK authentication
- Perfect Forward Secrecy
- Dead Peer Detection

#### WireGuard
- Modern cryptography
- UDP-based protocol
- Minimal attack surface

### Import Formats

RayLink supports importing server configurations from various sources:

- **Subscription URLs**: HTTP/HTTPS endpoints returning base64-encoded server lists
- **QR Codes**: Encoded server configurations
- **JSON Files**: RayLink native format and V2Ray configurations
- **YAML Files**: Clash and other YAML-based configurations
- **Individual URLs**: ss://, vmess://, trojan://, vless:// protocol URLs

## Usage

### Adding Servers

1. **Manual Configuration**: Use the "Add Server" option to manually configure connection details
2. **Import from URL**: Paste subscription URLs to automatically import server lists
3. **QR Code Scanning**: Scan QR codes containing server configurations
4. **File Import**: Import configuration files from Files app

### Connection Management

- Tap the connection button on the home screen to connect/disconnect
- Select different servers from the server list
- Monitor real-time connection statistics
- Configure auto-connect and trusted networks

### Advanced Features

- **Custom DNS**: Configure custom DNS servers
- **Routing Rules**: Set up domain-based routing
- **Kill Switch**: Prevent traffic leaks when VPN disconnects
- **Speed Test**: Test connection speeds with built-in tools

## Development

### Building

The project uses standard iOS development practices:

1. Open `RayLink.xcodeproj` in Xcode
2. Select your development team in project settings
3. Choose target device/simulator
4. Build and run (⌘+R)

### Testing

Run tests using Xcode's test navigator or command line:

```bash
xcodebuild test -scheme RayLink -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### Code Style

The project follows Swift standard conventions:

- Use SwiftLint for code style enforcement
- Follow Apple's naming conventions
- Prefer value types over reference types
- Use async/await for asynchronous operations
- Implement proper error handling

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Guidelines

- Follow the existing code style and architecture
- Write unit tests for new functionality
- Update documentation as needed
- Ensure all tests pass before submitting

## Privacy

RayLink is designed with privacy in mind:

- No user data collection without explicit consent
- Local storage of server configurations
- Optional analytics (can be disabled)
- No ads or tracking

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Disclaimer

This software is for educational and research purposes. Users are responsible for complying with local laws and regulations regarding VPN usage.

## Support

- Create an issue for bug reports or feature requests
- Join our Telegram group for community support
- Email: support@raylink.app

---

Built with ❤️ using SwiftUI