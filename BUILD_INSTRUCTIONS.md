# RayLink VPN - Build Instructions & Setup Guide

## 📱 Overview
RayLink is a premium iOS VPN application with Xray-core integration, featuring a unique Aurora-themed UI with glassmorphic design elements. This guide will walk you through building and running the app.

## 🛠 Prerequisites

### System Requirements
- **macOS**: Monterey 12.0 or later (Ventura 13.0+ recommended)
- **Xcode**: 15.0 or later
- **iOS Device/Simulator**: iOS 17.0+
- **Go**: 1.21+ (for building Xray-core)
- **CocoaPods**: 1.12.0+ (optional, if not using SPM)

### Developer Account
- Apple Developer Account (required for NetworkExtension)
- Paid Apple Developer Program membership ($99/year) for VPN capabilities

## 📦 Dependencies Setup

### 1. Clone the Repository
```bash
cd ~/Desktop
# Repository already exists at /Users/alisimacpro/Desktop/RayLink
```

### 2. Install Xcode Command Line Tools
```bash
xcode-select --install
```

### 3. Install Go (for Xray-core)
```bash
# Using Homebrew
brew install go

# Verify installation
go version
```

### 4. Install Gomobile
```bash
go install golang.org/x/mobile/cmd/gomobile@latest
go install golang.org/x/mobile/cmd/gobind@latest

# Initialize gomobile
gomobile init
```

## 🔧 Building Xray-core Library

### 1. Clone Xray-core
```bash
mkdir -p ~/Desktop/RayLink/xray-build
cd ~/Desktop/RayLink/xray-build

git clone https://github.com/XTLS/Xray-core.git
cd Xray-core
```

### 2. Create iOS Wrapper
Create a new file `~/Desktop/RayLink/xray-build/xray-ios/xray.go`:

```go
package xray

import (
    "encoding/json"
    "fmt"
    "github.com/xtls/xray-core/core"
    "github.com/xtls/xray-core/main/commands/base"
)

var server core.Server

// StartXray starts the Xray server with the given config
func StartXray(configJSON string) error {
    config, err := core.LoadConfig("json", []byte(configJSON))
    if err != nil {
        return fmt.Errorf("failed to load config: %v", err)
    }
    
    server, err = core.New(config)
    if err != nil {
        return fmt.Errorf("failed to create server: %v", err)
    }
    
    return server.Start()
}

// StopXray stops the Xray server
func StopXray() error {
    if server != nil {
        return server.Close()
    }
    return nil
}

// GetStats returns connection statistics
func GetStats() string {
    stats := map[string]interface{}{
        "uplink": 0,
        "downlink": 0,
    }
    
    data, _ := json.Marshal(stats)
    return string(data)
}
```

### 3. Build iOS Framework
```bash
cd ~/Desktop/RayLink/xray-build

# Create module
go mod init github.com/raylink/xray-ios
go get github.com/xtls/xray-core

# Build for iOS
gomobile bind -target=ios -o ~/Desktop/RayLink/Frameworks/Xray.xcframework ./xray-ios
```

## 📱 Xcode Project Setup

### 1. Open the Project
```bash
cd ~/Desktop/RayLink
open RayLink.xcodeproj
```

### 2. Configure Signing & Capabilities

1. Select the RayLink project in navigator
2. Select the RayLink target
3. Go to "Signing & Capabilities" tab
4. Enable "Automatically manage signing"
5. Select your Team (Apple Developer Account)
6. Bundle Identifier: `com.yourcompany.raylink`

### 3. Add Required Capabilities

Click "+ Capability" and add:
- **Network Extensions** (required for VPN)
- **Personal VPN** (for VPN configuration)
- **App Groups** (for sharing data with extension)
  - Create group: `group.com.yourcompany.raylink`

### 4. Configure NetworkExtension Target

1. File → New → Target
2. Select "Network Extension"
3. Choose "Packet Tunnel Provider"
4. Name: "RayLinkTunnel"
5. Language: Swift
6. Configure signing for this target too

### 5. Update Info.plist

Add to `RayLink/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>RayLink needs camera access to scan QR codes for server configuration</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>RayLink needs photo library access to import QR codes</string>

<key>UIBackgroundModes</key>
<array>
    <string>network-authentication</string>
    <string>voip</string>
</array>
```

### 6. Configure App Groups

In both targets (main app and tunnel), under Capabilities:
- Enable App Groups
- Add: `group.com.yourcompany.raylink`

### 7. Add Entitlements

Create `RayLink.entitlements`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.networking.networkextension</key>
    <array>
        <string>packet-tunnel-provider</string>
    </array>
    <key>com.apple.security.application-groups</key>
    <array>
        <string>group.com.yourcompany.raylink</string>
    </array>
</dict>
</plist>
```

## 🚀 Building & Running

### 1. Install Swift Package Dependencies

In Xcode:
1. File → Add Package Dependencies
2. Add the following packages:
   - `https://github.com/Alamofire/Alamofire`
   - `https://github.com/evgenyneu/keychain-swift`
   - `https://github.com/kean/Pulse`
   - `https://github.com/twostraws/CodeScanner`

### 2. Link Xray Framework

1. Select RayLinkTunnel target
2. Go to "Frameworks, Libraries, and Embedded Content"
3. Click "+" and add `Xray.xcframework`
4. Set to "Embed & Sign"

### 3. Build the Project

```bash
# Debug build
xcodebuild -project RayLink.xcodeproj -scheme RayLink -configuration Debug

# Or in Xcode:
# Press Cmd+B or Product → Build
```

### 4. Run on Simulator
1. Select an iOS Simulator (iPhone 15 Pro recommended)
2. Press Cmd+R or click the Play button

### 5. Run on Device
1. Connect your iPhone via USB
2. Select your device in the device selector
3. Trust the developer certificate on device:
   - Settings → General → VPN & Device Management
   - Select your developer profile
   - Tap "Trust"

## 🧪 Testing

### Test Credentials
For testing, you can use these sample server configurations:

```json
{
  "servers": [
    {
      "name": "Test VMess Server",
      "protocol": "vmess",
      "address": "test.example.com",
      "port": 443,
      "uuid": "a3482e88-686a-4a58-8126-99c9df64b7bf",
      "alterId": 0,
      "security": "auto"
    }
  ]
}
```

### Import Methods Testing
1. **QR Code**: Generate QR from vmess://... URL
2. **Clipboard**: Copy any supported URL format
3. **Subscription**: Use a test subscription URL

## 🐛 Troubleshooting

### Common Issues

#### 1. NetworkExtension Not Working
- Ensure you have a paid Apple Developer account
- Check entitlements are properly configured
- Verify App Groups match in both targets

#### 2. Xray-core Build Failures
```bash
# Clean and rebuild
go clean -cache
gomobile clean
gomobile bind -target=ios -o Xray.xcframework ./xray-ios
```

#### 3. Code Signing Issues
- Check Team selection in both targets
- Ensure Bundle IDs are unique
- Clean build folder: Shift+Cmd+K in Xcode

#### 4. VPN Connection Fails
- Check iOS Settings → General → VPN & Device Management
- Ensure VPN configuration is installed
- Check Console.app for detailed logs

### Debug Logging

Enable verbose logging:
```swift
// In AppDelegate or App.swift
UserDefaults.standard.set(true, forKey: "EnableDebugLogging")
```

View logs:
- Xcode Console (when running from Xcode)
- Console.app (for device logs)
- Settings → RayLink → Logs (in-app)

## 📝 Configuration

### Default Settings
The app uses these default configurations:

```swift
// DNS Settings
Primary DNS: 1.1.1.1
Secondary DNS: 8.8.8.8

// Routing Mode
Default: AUTOMATIC (smart routing)

// Connection Settings
Timeout: 30 seconds
Retry attempts: 3
```

### Advanced Configuration
Modify `RayLink/Core/Config/DefaultSettings.swift` for custom defaults.

## 🎨 UI Customization

### Theme Settings
Modify aurora theme colors in:
```
RayLink/Design/Theme/AppTheme.swift
```

### Animation Timing
Adjust animation curves in:
```
RayLink/Design/Animations/AnimationHelpers.swift
```

## 📦 Distribution

### TestFlight Beta
1. Archive the app: Product → Archive
2. Upload to App Store Connect
3. Submit for TestFlight review
4. Invite testers via email or public link

### App Store Release
1. Ensure all assets are included
2. Prepare screenshots for all device sizes
3. Write compelling app description
4. Submit for App Store review

## 🔐 Security Notes

- Never commit API keys or secrets
- Use Keychain for sensitive data storage
- Implement certificate pinning for server connections
- Regular security audits recommended

## 📚 Additional Resources

- [Apple NetworkExtension Documentation](https://developer.apple.com/documentation/networkextension)
- [Xray-core Documentation](https://xtls.github.io/en/)
- [SwiftUI Documentation](https://developer.apple.com/xcode/swiftui/)
- [Gomobile Documentation](https://pkg.go.dev/golang.org/x/mobile/cmd/gomobile)

## 🤝 Support

For issues or questions:
1. Check the troubleshooting section
2. Review Xcode console logs
3. Enable debug logging for detailed information

## ✅ Checklist

Before running the app, ensure:
- [ ] Xcode 15+ installed
- [ ] Go and Gomobile installed
- [ ] Xray-core framework built
- [ ] Developer account configured
- [ ] Entitlements properly set
- [ ] App Groups configured
- [ ] NetworkExtension capability added
- [ ] Code signing configured
- [ ] Dependencies installed via SPM

Once everything is set up, you should be able to build and run RayLink successfully!

---

**Note**: This is a development build. For production deployment, ensure proper security measures, API endpoint configuration, and thorough testing on multiple devices.