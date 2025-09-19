# RayLink iOS App - Setup Guide for Personal Apple ID

This guide will help you set up and run the RayLink VPN app using a personal (free) Apple ID. The app will work with all UI features, but actual VPN connectivity requires a paid developer account.

## 📋 Prerequisites Check

### 1. Install Xcode (Required)
```bash
# Check if Xcode is installed
xcodebuild -version

# If not installed, get it from App Store or:
xcode-select --install
```

### 2. Install Homebrew (Required for Go)
```bash
# Check if Homebrew is installed
brew --version

# If not installed:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Install Go (Required for mock library)
```bash
# Install Go using Homebrew
brew install go

# Verify installation
go version
# Should show: go version go1.21.x or higher
```

## 🚀 Quick Setup Steps

### Step 1: Build the Mock Xray Library
```bash
cd ~/Desktop/RayLink

# Run the build script
./build_xray.sh
```

**Expected output:**
```
🚀 RayLink Xray Build Script
✓ Go is installed: go version go1.21.x
📁 Creating directories...
📝 Creating mock Xray library for development...
✅ Mock framework built successfully!
```

### Step 2: Open Project in Xcode
```bash
open RayLink.xcodeproj
```

### Step 3: Configure Signing (Personal Apple ID)

1. **Select the project** in the navigator (top left)
2. **Select "RayLink" target**
3. Go to **"Signing & Capabilities"** tab
4. **Enable** "Automatically manage signing"
5. **Team**: Select your personal Apple ID
   - If not listed, click "Add an Account..." and sign in
6. **Bundle Identifier**: Change to something unique like:
   - `com.yourname.raylink` (replace "yourname" with your actual name)

### Step 4: Remove VPN Capabilities (for Personal ID)

Since personal Apple IDs don't support VPN:

1. In **"Signing & Capabilities"** tab
2. Look for any of these capabilities and **remove them** (click the X):
   - ❌ Network Extensions
   - ❌ Personal VPN
   - ❌ Packet Tunnel Provider

3. Keep these capabilities (they work with personal ID):
   - ✅ App Groups (optional)
   - ✅ Push Notifications (optional)

### Step 5: Fix Common Issues

#### Issue: "No account for team"
**Solution:** 
1. Xcode → Settings → Accounts
2. Click "+" → Apple ID
3. Sign in with your Apple ID

#### Issue: "Bundle identifier already exists"
**Solution:** Change bundle ID to something unique:
```
com.[yourname].raylink.dev
```

#### Issue: "Failed to register bundle identifier"
**Solution:** This happens with free accounts. Try:
1. Clean build folder: `Shift + Cmd + K`
2. Change bundle ID slightly
3. Try again

## 🎯 Running the App

### On Simulator (Easiest)

1. Select **iPhone 15 Pro** simulator (or any iOS 17+ simulator)
2. Press **Cmd + R** or click the ▶️ Play button
3. Wait for build to complete

**The app will:**
- ✅ Show all UI screens and animations
- ✅ Allow server management
- ✅ Show mock connection states
- ✅ Display sample statistics
- ⚠️ Not create actual VPN connections (mock only)

### On Physical iPhone

1. **Connect iPhone** via USB
2. **Select your device** from the device list
3. Press **Cmd + R** to run

**First time running:**
1. You'll see "Untrusted Developer" on your iPhone
2. On iPhone: Settings → General → VPN & Device Management
3. Find "Developer App" section
4. Tap your email/Apple ID
5. Tap "Trust [your email]"
6. Run the app again from Xcode

## 🧪 Testing the App

### What Works with Personal Apple ID:
- ✅ **Complete UI/UX** - All screens, animations, and interactions
- ✅ **Server Management** - Add, edit, delete, import servers
- ✅ **Mock Connections** - Simulated VPN states
- ✅ **Settings** - All configuration options
- ✅ **Import Methods** - QR codes, clipboard, files
- ✅ **Speed Tests** - Mock latency results
- ✅ **Statistics** - Mock data usage display

### What Requires Paid Developer Account:
- ❌ Actual VPN connections
- ❌ Real network tunneling
- ❌ System VPN configuration
- ❌ NetworkExtension features

## 🔧 Troubleshooting

### Build Errors

#### "Module 'XrayMock' not found"
```bash
# Rebuild the mock framework
cd ~/Desktop/RayLink
./build_xray.sh
```

#### "Command PhaseScriptExecution failed"
```bash
# Clean and rebuild
cd ~/Desktop/RayLink
rm -rf ~/Library/Developer/Xcode/DerivedData
# Then rebuild in Xcode
```

#### "Signing for 'RayLink' requires a development team"
- Follow Step 3 above to add your Apple ID

### Runtime Issues

#### App crashes on launch
1. Check Console app for crash logs
2. Ensure iOS 17.0+ on device/simulator
3. Clean build: `Shift + Cmd + K`
4. Delete app from device and reinstall

#### Mock VPN not working
The app should automatically detect lack of VPN entitlements and use mock mode. Check Xcode console for:
```
⚠️ Using Mock VPN Manager (no paid developer account detected)
```

## 📱 Using the App

### First Launch
1. App opens to home screen
2. Tap "+" to add a server manually
3. Or use Import to add from clipboard/QR

### Testing Mock Connection
1. Add a server (any details work in mock mode)
2. Tap the connection button
3. See mock "Connecting" → "Connected" states
4. Statistics will show simulated data

### Sample Server for Testing
```
Name: Test Server
Address: test.example.com
Port: 443
Protocol: VMess
UUID: any-uuid-here
```

## 🎨 Exploring Features

### Aurora Theme
- Changes based on time of day
- Morning: Blue-purple gradients
- Day: Bright aurora colors
- Evening: Warm orange-pink
- Night: Deep purple-blue

### Animations
- Pull down on any list to refresh
- Swipe servers left for actions
- Long press for haptic feedback
- Watch the connection button pulse

## 📝 Development Tips

### Enable Debug Logging
In `RayLinkApp.swift`, add:
```swift
UserDefaults.standard.set(true, forKey: "EnableDebugLogging")
```

### View Console Logs
1. Run app from Xcode
2. View logs in bottom console panel
3. Filter by "RayLink" or "Mock"

### Hot Reload with SwiftUI
1. Make UI changes in code
2. Press `Cmd + Option + P` for preview
3. See changes without rebuilding

## 🚀 Next Steps

### When You Get Paid Developer Account

1. **Add VPN Capabilities** in Xcode
2. **Build Real Xray Framework**:
   ```bash
   # Follow original instructions for real Xray-core
   ```
3. **Change Mock Flag** in `DependencyContainer.swift`:
   ```swift
   // Set to false for real VPN
   let useMockVPN = false
   ```
4. **Configure NetworkExtension** target
5. **Test on real device** with VPN permissions

### For Production

1. Archive app: Product → Archive
2. Upload to TestFlight
3. Internal testing with team
4. Submit to App Store

## ❓ FAQ

**Q: Can I test real VPN connections?**
A: No, you need a paid Apple Developer account ($99/year) for NetworkExtension capability.

**Q: Will the app look different with mock VPN?**
A: No, the UI is identical. Only the actual VPN connection is mocked.

**Q: Can I publish to App Store with personal ID?**
A: No, you need a paid developer account to publish apps.

**Q: Why does Xcode show "Personal Team" warnings?**
A: This is normal for free accounts. The app will still run on your devices.

**Q: How do I know if mock mode is active?**
A: Check Xcode console for "Using Mock VPN Manager" message.

## 🆘 Getting Help

1. **Check Xcode Console** for error messages
2. **Clean Build Folder**: Shift + Cmd + K
3. **Reset Simulator**: Device → Erase All Content and Settings
4. **Update Xcode** if using older version

## ✅ Success Indicators

You know setup is successful when:
- ✅ App builds without errors
- ✅ App runs on simulator
- ✅ Home screen shows with aurora background
- ✅ Can navigate all screens
- ✅ Mock connection shows "Connected"
- ✅ Console shows "Mock VPN Manager" message

---

**Remember:** This setup is for development and testing only. For actual VPN functionality and App Store distribution, you'll need a paid Apple Developer account.