# **Project Inception Document: RayLink**

Version: 1.3 (Expanded Features)  
Date: August 30, 2025  
Author: Ali Ahrabi

## **1\. Project Overview & Goals**

### **1.1. Project Summary**

This document outlines the design and functional specifications for RayLink, a new iOS VPN application. The app will provide users with a simple, one-tap interface to connect to a VPN while also offering advanced features for power users to import, manage, and test custom server configurations. The app will support modern proxy protocols like VLESS and VMess by integrating the Xray-core engine.

### **1.2. Core Goals**

* **Simplicity:** Offer a clean, intuitive user interface where connecting to the VPN is the primary, most accessible action.  
* **Power & Flexibility:** Allow users to import configurations from various sources (QR code, clipboard, subscription links) and manage a list of servers.  
* **Performance:** Provide real-time latency (ping) tests for servers so users can choose the fastest option.  
* **Stability:** Build a reliable VPN connection that runs seamlessly in the background using native iOS frameworks.  
* **Monetization (v1):** Implement a simple ad-supported model to support the free use of the app's core features.

## **2\. UI/UX Design Guidelines**

This section provides visual and interactive guidelines for the UI/UX designer.

### **2.1. Visual Style**

* **Theme:** Minimalist, modern, and clean. The design should prioritize clarity and ease of use.  
* **Color Palette:**  
  * **Primary Background:** A light grey or off-white with a subtle geometric pattern.  
  * **Accent Colors:** A vibrant green for "connected" status and buttons (\#4CD964 or similar). A neutral dark grey/charcoal for the main connection button and selected items.  
  * **Text:** Dark grey for primary text, lighter grey for secondary text.  
* **Typography:** A clean, sans-serif font like San Francisco (SF Pro), the default iOS font.  
* **Iconography:** Use simple, universally understood line icons (e.g., settings cog, plus symbol, connection symbol).

### **2.2. Key UI Components**

* **Main Connection Button:** A large, circular button that serves as the central point of interaction on the home screen. Its state should change visually (color and icon) to reflect the connection status.  
* **Server Selector Card:** A prominent card on the home screen that displays the currently selected server. Tapping it navigates to the full server list.  
* **Lists & Cells:** Lists should be clean with ample spacing. Each server cell should display the server name, protocol type (VLESS/VMess), and a real-time ping result.

## **3\. Screen-by-Screen Breakdown & Functionality (v1 Scope)**

### **3.1. Main Screen (Home)**

* **Inspiration:** main\_page.jpg & main\_page\_connected.jpg.  
* **Elements:**  
  1. **Header:** Settings icon (left), Add/Import icon (right).  
  2. **Status Display:** App logo (disconnected) or Connection timer/location (connected).  
  3. **Server Selector Card:** Displays the currently selected server and navigates to the Server List Screen on tap.  
  4. **Connection Mode Tabs:** Segmented control with options: AUTOMATIC, GLOBAL, DIRECT. These are presets linked to the Routing rules.  
  5. **Main Connection Button:** Initiates or terminates the VPN connection.

### **3.2. Server List Screen**

* **Inspiration:** servers\_list.jpg and photo\_2025-8-30\_06-48-00.jpg.  
* **Elements:**  
  1. **Header:** Title "Servers" and a "Back" button.  
  2. **Server Groups:** Servers grouped by subscription or source. Each group is collapsible.  
  3. **Group Actions:** Icons to test latency or delete the group.  
  4. **Server Cell:** Displays Server Name, Protocol Tag, Latency, and a connect/disconnect Action Button.  
  5. **User Interaction:** Tapping a cell selects it. Swiping left reveals Delete, Copy, Share options.

### **3.3. Add/Import Server Flow**

* **Inspiration:** photo\_2025-08-30\_06-48-03.jpg.  
* **Functionality:** An action sheet with options: Manual Input, Scan QR Code, Import QR Code from Photos, Import from Clipboard, Subscribe Link.

### **3.4. Settings Screen**

* **Inspiration:** photo\_2025-08-30\_06-47-51.jpg.  
* **Elements (Simplified for v1):**  
  1. **Configuration:** Routings, DNS.  
  2. **Tools:** Speed Test, Clean Configs, Subscriptions.  
  3. **General:** App Icon, Logs, About/Help.

### **3.5. Advanced Feature Explanations**

This section provides a detailed breakdown of the features listed in the Settings screen for the development team.

#### **3.5.1. Subscriptions Management**

* **Purpose:** To allow users to manage lists of servers provided by a third-party URL.  
* **UI:** A dedicated screen showing a list of all added subscriptions.  
* **Functionality:**  
  * **Add Subscription:** User provides a name and a URL. The app fetches the config list from the URL, parses it, and creates a new server group on the Server List screen.  
  * **Update (Refresh):** Each subscription in the list has a "Refresh" button. This action re-fetches the URL to get the latest server list. An "Update All" button should also be available.  
  * **Auto-Update:** A global toggle on this screen to "Refresh subscriptions on launch."  
  * **Custom User-Agent:** A text field on this screen allowing users to set a custom User-Agent string for all subscription requests. This is a crucial feature to prevent being blocked by some providers.

#### **3.5.2. Routing Setup**

* **Purpose:** To give advanced users control over how network traffic is handled when the VPN is active. The tabs on the main screen (AUTOMATIC, GLOBAL, DIRECT) are presets for these rules.  
* **UI:** A screen where users can manage rule sets.  
* **Functionality:**  
  * Users can create custom rules based on domain, IP CIDR, or GeoIP.  
  * For each rule, users can assign an "outbound tag":  
    * **Proxy:** Traffic matching this rule goes through the VPN.  
    * **Direct:** Traffic matching this rule bypasses the VPN.  
    * **Block:** Traffic matching this rule is blocked (useful for ads and trackers).  
  * The app should come with pre-configured rule sets for the AUTOMATIC, GLOBAL, and DIRECT modes.

#### **3.5.3. DNS Setup**

* **Purpose:** To allow users to override the system's default DNS servers when the VPN is connected.  
* **UI:** A screen with fields for primary and secondary DNS.  
* **Functionality:**  
  * Users can input IP addresses for their preferred DNS servers (e.g., 1.1.1.1, 8.8.8.8, 9.9.9.9).  
  * A special "System" or "Default" option should be available.  
  * The specified DNS will be used for all DNS queries while the VPN is active, potentially improving privacy and speed.

#### **3.5.4. Speed Test (Ping Setup)**

* **Purpose:** To measure the real-world latency of each server.  
* **Functionality:**  
  * The test sends a small TCP packet to the server's address and port and measures the time it takes to get a response (a TCP handshake is a good method).  
  * This is a latency test, not a bandwidth (speed) test.  
  * The process should be asynchronous, running in the background so it doesn't freeze the UI.  
  * Results (in milliseconds) should be displayed next to each server in the Server List Screen. A color code (green for low, yellow for medium, red for high) can be used for quick visual feedback.

## **4\. Technical Architecture & Stack**

* **Language:** Swift  
* **UI Framework:** SwiftUI  
* **VPN Core:** Apple NetworkExtension Framework.  
* **Proxy Engine:** xtls/xray-core (Go library).  
* **Go/Swift Bridge:** Gomobile.  
* **Secure Storage:** iOS Keychain for server credentials.  
* **Ad Network SDK:** Integration with an ad provider like Google AdMob for banner and interstitial video ads.  
* **Concurrency:** async/await.

## **5\. User Flow Examples**

### **5.1. First-Time User & Connection**

1. User opens RayLink and is prompted to add a server.  
2. User taps the connect button.  
3. iOS prompts for VPN configuration permission.  
4. User accepts, and the connection is established. A banner or interstitial ad is shown upon connection/disconnection.

### **5.2. Importing a Server via Clipboard**

1. User copies a vless:// link.  
2. User opens RayLink.  
3. A banner prompts the user to add the server from the clipboard.  
4. User accepts, and the server is added to their list.

## **6\. Monetization Strategy (v1)**

* **Model:** Ad-Supported Freemium.  
* **Core Principle:** The app's full functionality for importing and using personal server configurations is free for all users.  
* **Revenue Source:** The app is supported by:  
  * **Banner Ads:** Displayed on non-critical screens (e.g., Server List, Settings).  
  * **Interstitial Ads:** Full-screen ads shown at logical breaks in the user experience, such as after a successful connection or disconnection.

## **7\. Future Roadmap (v2.0 and beyond)**

* **VIP Server Access:** Introduce a premium tier of high-performance servers managed by us.  
* **Virtual Currency System:** Implement an "earn-to-use" model where users can watch rewarded ads to earn a virtual currency.  
* **VIP Store:** This currency can be spent in an in-app store to purchase temporary access to the VIP servers and an ad-free experience.  
* **Cloud Sync:** Allow users to back up their server lists and settings.