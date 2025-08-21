# ScopeX Mobile Automation Framework - Auto Device Management

## 🎯 Overview

The framework now includes automatic device management and app installation features that handle the complete setup process for you.

## 🚀 Auto Device Management Features

### ✅ **What's Automated:**

1. **Device Detection** - Automatically finds available devices/emulators
2. **Device Startup** - Starts devices if none are running
3. **App Installation** - Installs the app if not already installed
4. **Platform Selection** - Prompts for platform choice if not specified
5. **Error Handling** - Comprehensive error handling and recovery

## 📱 **Supported Platforms**

### **Android**
- **Device Detection**: Uses `adb devices` to find connected devices/emulators
- **Device Startup**: Uses `maestro start-device --platform=android`
- **App Installation**: Uses `adb install -r apps/android/app-release.apk`
- **App Detection**: Checks `pm list packages` for app installation

### **iOS**
- **Device Detection**: Uses `xcrun simctl list devices` to find running simulators
- **Device Startup**: Uses `maestro start-device --platform=ios`
- **App Installation**: Uses `xcrun simctl install` to install the app
- **App Detection**: Checks `xcrun simctl listapps` for app installation

## 🎯 **Usage Examples**

### **1. Platform-Specific Auto Setup**

```bash
# Android - Auto device + app install + run tests
./run-tests.sh -p android -t "guest,clear-state"

# iOS - Auto device + app install + run tests  
./run-tests.sh -p ios -t "signup,clear-state"

# Both platforms - Auto setup for both
./run-tests.sh -p both -t regression
```

### **2. Flow-Specific Auto Setup**

```bash
# Run specific flow with auto platform selection
./run-tests.sh flows/feature/wallet-flow.yaml

# Run specific flow on specific platform
./run-tests.sh -p android flows/feature/send-money-flow.yaml
```

### **3. Interactive Platform Selection**

```bash
# No platform specified - interactive selection
./run-tests.sh -t "guest,clear-state"

# You'll see:
# [STEP] No platform specified. Please choose platform:
# 1. Android
# 2. iOS  
# 3. Both
# Enter choice (1-3):
```

## 🔧 **How It Works**

### **Step 1: Device Detection**
```bash
# Checks for existing devices
adb devices                    # Android
xcrun simctl list devices     # iOS
```

### **Step 2: Device Startup (if needed)**
```bash
# Starts new device if none found
maestro start-device --platform=android
maestro start-device --platform=ios
```

### **Step 3: App Installation Check**
```bash
# Checks if app is installed
adb shell pm list packages | grep com.scopex.scopexmobilev2  # Android
xcrun simctl listapps DEVICE_ID | grep com.scopex.scopexmobilev2  # iOS
```

### **Step 4: App Installation (if needed)**
```bash
# Installs app if not found
adb install -r apps/android/app-release.apk  # Android
xcrun simctl install DEVICE_ID apps/ios/MyApp.app  # iOS
```

## 📊 **Example Execution Flow**

### **Scenario 1: Fresh Setup**
```bash
$ ./run-tests.sh -p android -t "guest,clear-state"

[STEP] Auto device management for android platform
[DEVICE] Checking for available android device...
[DEVICE] No android device found. Starting new device...
[DEVICE] Starting android device...
[✓ SUCCESS] android device started successfully
[DEVICE] Successfully started android device: emulator-5554
[DEVICE] Checking if app is installed on android device...
[DEVICE] App not installed. Installing now...
[DEVICE] Installing app on android device: emulator-5554
[✓ SUCCESS] Android app installed successfully
[✓ SUCCESS] Device and app ready for testing on android
[STEP] Starting comprehensive test execution...
```

### **Scenario 2: Device Already Running**
```bash
$ ./run-tests.sh -p android -t "guest,clear-state"

[STEP] Auto device management for android platform
[DEVICE] Checking for available android device...
[✓ SUCCESS] Found existing android device: emulator-5554
[DEVICE] Checking if app is installed on android device...
[✓ SUCCESS] App is already installed on android device
[✓ SUCCESS] Device and app ready for testing on android
[STEP] Starting comprehensive test execution...
```

### **Scenario 3: App Not Installed**
```bash
$ ./run-tests.sh -p android -t "guest,clear-state"

[STEP] Auto device management for android platform
[DEVICE] Checking for available android device...
[✓ SUCCESS] Found existing android device: emulator-5554
[DEVICE] Checking if app is installed on android device...
[DEVICE] App not installed. Installing now...
[DEVICE] Installing app on android device: emulator-5554
[✓ SUCCESS] Android app installed successfully
[✓ SUCCESS] Device and app ready for testing on android
[STEP] Starting comprehensive test execution...
```

## 🛠️ **Error Handling**

### **Device Startup Failures**
- **Issue**: Device fails to start
- **Action**: Script exits with error message
- **Recovery**: Manual device startup required

### **App Installation Failures**
- **Issue**: App fails to install
- **Action**: Script exits with error message
- **Recovery**: Check app file exists and device is ready

### **Platform-Specific Issues**
- **Android**: ADB not found, SDK not installed
- **iOS**: Xcode not found, macOS required
- **Action**: Clear error messages with installation instructions

## 📁 **Required App Files**

### **Android**
- **Path**: `apps/android/app-release.apk`
- **Format**: APK file
- **Installation**: `adb install -r`

### **iOS**
- **Path**: `apps/ios/MyApp.app`
- **Format**: iOS app bundle
- **Installation**: `xcrun simctl install`

## 🎯 **Best Practices**

### **1. App File Management**
```bash
# Ensure app files are in correct locations
ls -la apps/android/app-release.apk
ls -la apps/ios/MyApp.app
```

### **2. Device Management**
```bash
# Check device status
./run-tests.sh --list-devices

# Start specific device manually
./run-tests.sh --start-device android
./run-tests.sh --start-device ios
```

### **3. Testing Workflow**
```bash
# 1. Setup (one time)
./setup.sh

# 2. Run tests with auto device management
./run-tests.sh -p android -t "guest,clear-state"
./run-tests.sh -p ios -t "signup,clear-state"

# 3. Run specific flows
./run-tests.sh flows/feature/wallet-flow.yaml
```

## ✅ **Benefits**

1. **Zero Setup** - No manual device management required
2. **Automatic Recovery** - Handles device/app issues automatically
3. **Cross-Platform** - Works seamlessly on Android and iOS
4. **Error Prevention** - Prevents common setup issues
5. **Time Saving** - Eliminates manual setup steps

## 🔍 **Troubleshooting**

### **Common Issues**

1. **"ADB not found"**
   - Install Android SDK and add to PATH
   - Run `./setup.sh` to verify installation

2. **"Xcode not found"**
   - Install Xcode on macOS
   - Install Xcode command line tools

3. **"App file not found"**
   - Ensure app files are in correct directories
   - Check file permissions

4. **"Device startup failed"**
   - Check system resources
   - Verify emulator/simulator installation

### **Debug Commands**
```bash
# Check device status
./run-tests.sh --list-devices

# Manual device startup
./run-tests.sh --start-device android
./run-tests.sh --start-device ios

# Verbose output
./run-tests.sh -v -p android -t "guest,clear-state"
```

## 🎯 **Framework Status**

**✅ Auto Device Management Ready** with:
- **Automatic device detection and startup**
- **Automatic app installation and verification**
- **Interactive platform selection**
- **Comprehensive error handling**
- **Cross-platform support**

The framework now provides a complete automated setup experience! 🎉
