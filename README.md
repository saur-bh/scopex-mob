# ScopeX Mobile Automation Framework

A comprehensive, production-ready Maestro-based mobile testing framework for the ScopeX application that works seamlessly on both Android and iOS platforms. Built with advanced features from the [Maestro documentation](https://docs.maestro.dev/) including flow hooks, JavaScript integration, video recording, and cross-platform automation.

## 🚀 Quick Start

### Automated Setup (Recommended)

The framework includes an intelligent setup script that automatically detects your system and installs required components:

```bash
# Full automated setup with component installation and testing
./setup.sh --install-missing --quick-test

# Check requirements only (no installation)
./setup.sh --check-only

# Install missing components automatically
./setup.sh --install-missing

# Create Android emulator after setup
./setup.sh --install-missing --create-emulator
```

### Manual Verification

```bash
# Verify all components are working
./setup.sh --check-only
```

## 🎯 Test Execution

### Unified Test Runner

The framework now uses a single unified test runner with automatic emulator management:

```bash
# Run Android with automatic emulator creation and cleanup
./run-tests.sh -p android

# Run iOS with automatic simulator creation and cleanup
./run-tests.sh -p ios

# Run on both platforms in parallel
./run-tests.sh -p both --parallel

# Run specific flow with enhanced features
./run-tests.sh -p ios -f auth-flow.yaml --debug --record
```

### Emulator Management Features

```bash
# Automatic emulator creation (default)
./run-tests.sh -p android                    # Creates timestamped emulator

# Use existing emulator
./run-tests.sh -p android --no-auto-emulator -d "Pixel_7"

# Keep emulator after test (for debugging)
./run-tests.sh -p ios --no-cleanup

# Run with all features
./run-tests.sh -p android --debug --record --format HTML
```

### Advanced Options

```bash
# Run with HTML reports
./run-tests.sh -p ios -f guest-user-flow.yaml --format HTML

# Run with debug output
./run-tests.sh -p ios -f guest-user-flow.yaml --debug

# Run with specific timeout
./run-tests.sh -p ios -f guest-user-flow.yaml --timeout 60000

# Run with tags
./run-tests.sh -p ios --include-tags "smoke,guest"

# Run in continuous mode (watch for changes)
./run-tests.sh -p ios -f guest-user-flow.yaml --continuous
```

## 📁 Project Structure

```
scopex-mob/
├── flows/                          # Test flows
│   ├── guest-user-flow.yaml       # Enhanced guest user journey
│   ├── auth-flow.yaml             # Authentication flow
│   ├── home-screen-flow.yaml      # Home screen navigation
│   ├── setup/                     # Setup flows
│   │   └── clear-app-data.yaml    # App data clearing
│   ├── cleanup/                   # Cleanup flows
│   │   └── cleanup-data.yaml      # Post-test cleanup
│   └── permissions/               # Permission handling
│       ├── android-permissions.yaml
│       └── ios-permissions.yaml
├── reports/                       # Test reports (auto-generated)
├── screenshots/                   # Screenshots (auto-generated)
├── maestro.yaml                   # Unified configuration
├── run-tests.sh                   # Unified test runner (Android + iOS)
├── run-tests.sh.backup           # Backup of old test runners
├── run-ios-tests.sh.backup       # Backup of old iOS runner
├── setup.sh                      # Intelligent environment setup
├── MAESTRO_REFERENCE.md          # Maestro documentation reference
├── ENHANCED_FEATURES_SUMMARY.md  # Framework features summary
└── README.md                     # This file
```

## 🔧 System Requirements & Setup

### Supported Platforms

| Platform | Android Testing | iOS Testing | Auto-Install |
|----------|----------------|-------------|--------------|
| **macOS** | ✅ Full Support | ✅ Full Support | ✅ Homebrew |
| **Windows** | ✅ Full Support | ❌ Not Supported | ⚠️ Manual |
| **Linux** | ✅ Full Support | ❌ Not Supported | ⚠️ Manual |

### Requirements

#### All Platforms
- **Java 8+** (Required for Maestro)
- **Maestro 1.36.0+** (Auto-installed)
- **Android SDK** with API Level 34
- **ADB** (Android Debug Bridge)

#### macOS Additional
- **Xcode** with Command Line Tools
- **iOS Simulator**
- **Homebrew** (for auto-installation)

### Intelligent Setup Script

The `setup.sh` script provides comprehensive environment validation:

```bash
# Features:
✅ OS Detection (macOS/Windows/Linux)
✅ Java Installation Check & Auto-Install
✅ Android SDK Validation
✅ iOS Requirements (macOS only)
✅ Maestro Installation & Version Check
✅ Device Connectivity (with timeout protection)
✅ Framework File Validation
✅ Apps Directory Auto-Creation
✅ App Files Guidance & Validation
✅ Quick Test Execution

# Timeout Protection:
- Maestro version check: 2s timeout
- ADB device detection: 3s timeout  
- iOS simulator detection: 3s timeout
- Prevents hanging on slow commands

# App Files Management:
- Auto-creates apps/android/ and apps/ios/ directories
- Provides detailed guidance for app placement
- Interactive prompts with non-interactive mode support
- Validates expected file names and locations
```

## 📱 App Files Setup

### Automatic Directory Creation

The setup script automatically creates the required directory structure:

```bash
./setup.sh --check-only  # Creates apps/android/ and apps/ios/
```

### Required App Files

| Platform | Expected Location | Description |
|----------|------------------|-------------|
| **Android** | `apps/android/app-release.apk` | Your Android APK file |
| **iOS** | `apps/ios/MyApp.app` | Your iOS app bundle |

### Adding Your App Files

#### Android APK
```bash
# Copy your Android APK
cp /path/to/your/app-release.apk apps/android/

# Verify placement
ls -la apps/android/app-release.apk
```

#### iOS App Bundle
```bash
# Copy your iOS app bundle
cp -r /path/to/your/MyApp.app apps/ios/

# Verify placement
ls -la apps/ios/MyApp.app
```

### Interactive Setup

The setup script provides interactive guidance when app files are missing:

```bash
# Interactive mode (default)
./setup.sh --check-only

# Non-interactive mode (for CI/CD)
./setup.sh --check-only --non-interactive
```

**Interactive Mode Features:**
- ✅ Step-by-step guidance for missing files
- ✅ Clear instructions with copy commands
- ✅ Option to continue setup without app files
- ✅ Detailed placement requirements

**Non-Interactive Mode Features:**
- ✅ Skips user prompts for automated environments
- ✅ Continues setup with warnings for missing files
- ✅ Perfect for CI/CD pipelines
- ✅ Provides clear status reporting

## 🔧 Configuration

### Maestro Configuration (`maestro.yaml`)

```yaml
# Unified Maestro Configuration for ScopeX Mobile App
name: "ScopeX Mobile Tests"
version: "1.0.0"

# App configuration
app:
  android:
    appId: "com.scopex.scopexmobilev2"
    apkPath: "apps/android/app-release.apk"
  ios:
    appId: "com.scopex.scopexmobilev2" 
    appPath: "apps/ios/MyApp.app"

# Device configuration
device:
  android:
    preferred: ["Pixel_7_API_34", "Pixel_6_API_33"]
  ios:
    preferred: ["iPhone 15", "iPhone 14", "iPhone 13"]

# Test configuration
testing:
  timeouts:
    appLaunch: 15000
    elementWait: 10000
    permissionDialog: 5000
```

### Environment Variables

```bash
# Set test environment
export TEST_ENVIRONMENT="staging"
export MAESTRO_TIMEOUT="30000"
export SCREENSHOT_ON_FAILURE="true"
```

## 🎨 Enhanced Features

### 1. Flow Hooks (onFlowStart/onFlowComplete)

```yaml
# Automatic setup and cleanup
onFlowStart:
  - runFlow: setup/clear-app-data.yaml
  - evalScript: ${output.flowStartTime = Date.now();}

onFlowComplete:
  - runFlow: cleanup/cleanup-data.yaml
  - evalScript: ${const duration = Date.now() - output.flowStartTime;}
```

### 2. JavaScript Integration

```yaml
# Dynamic content and logging
- evalScript: ${console.log('Testing on', maestro.platform);}
- evalScript: ${output.testData = 'dynamic content';}

# Environment variables
env:
  PLATFORM: ${maestro.platform}
  START_TIME: ${Date.now()}
```

### 3. Permission Management

```yaml
# Comprehensive permission configuration
- launchApp:
    permissions:
      all: deny
      camera: allow
      location: allow
      notifications: allow
      contacts: allow
      microphone: allow
```

### 4. Video Recording

```yaml
# Start and stop recording
- startRecording
# ... test steps ...
- stopRecording
```

## 📊 Test Reports & Logging

### HTML Reports
- **Location**: `reports/android_*/report.html` and `reports/ios_*/report.html`
- **Features**: Screenshots, test results, execution timeline, interactive navigation
- **Format**: Beautiful, interactive HTML reports (default output format)

### Screen Recordings
- **Location**: `flows/*.mp4` (alongside flow files)
- **Features**: Automatic video recordings of test execution
- **Format**: MP4 video files with descriptive names
- **Usage**: Perfect for debugging and evidence collection

### Detailed Logs
- **Location**: `reports/logs/maestro_*_*.log`
- **Features**: Comprehensive execution logs, error details, performance metrics
- **Format**: Timestamped log files with full Maestro output
- **Usage**: Debug test failures and analyze performance

### Debug Output
- **Location**: `reports/debug_*/` (when using `--debug` flag)
- **Contents**: Detailed logs, screenshots, performance metrics, device information

**📖 See [RECORDING_AND_LOGGING.md](RECORDING_AND_LOGGING.md) for comprehensive documentation.**

## 🛠️ Available Commands

### Setup Script (`setup.sh`)

```bash
Usage: ./setup.sh [OPTIONS]

Options:
  --check-only        Only check requirements, don't install anything
  --install-missing   Install missing components automatically
  --create-emulator   Create Android emulator after setup
  --quick-test        Run a quick test after setup
  --verbose           Enable verbose output
  --help              Show this help message

Examples:
  ./setup.sh                              # Check requirements and show status
  ./setup.sh --install-missing            # Install missing components
  ./setup.sh --install-missing --quick-test  # Full setup with test
```

### Unified Test Runner (`run-tests.sh`)

```bash
Usage: ./run-tests.sh [OPTIONS]

Platform Options:
  -p, --platform PLATFORM    Platform to test (android|ios|both) [default: android]
  -d, --device DEVICE        Specific device/emulator to use
  --no-auto-emulator         Disable automatic emulator creation
  --no-cleanup               Keep emulator after test completion

Test Options:
  -f, --flow FLOW            Flow file to run [default: guest-user-flow.yaml]
  -t, --timeout SECONDS      Test timeout in seconds
  --include-tags TAGS        Run flows with specific tags (comma-separated)
  --exclude-tags TAGS        Exclude flows with specific tags (comma-separated)

Output Options:
  --format FORMAT            Output format (junit|html|noop) [default: junit]
  -v, --verbose              Enable verbose output
  --debug                    Enable debug mode with detailed logs

Execution Options:
  --parallel                 Run tests in parallel (when using 'both' platform)
  --continuous               Run in continuous mode (watch for changes)
  --record                   Record test execution video

Help:
  -h, --help                 Show this help message
```

### Emulator Management Features

- ✅ **Automatic Creation**: Creates timestamped emulators for each test run
- ✅ **Automatic Installation**: Installs apps on the created emulators
- ✅ **Automatic Cleanup**: Deletes emulators after test completion
- ✅ **Cross-Platform**: Works with both Android emulators and iOS simulators
- ✅ **Parallel Execution**: Run both platforms simultaneously
- ✅ **Debug Mode**: Keep emulators for debugging with `--no-cleanup`

## 🔍 Troubleshooting

### Setup Issues

1. **Setup Script Hanging**:
   ```bash
   # Fixed with timeout protection in v1.0.0
   ./setup.sh --check-only  # Should complete quickly
   ```

2. **Apps Directory Creation Issues**:
   ```bash
   # Manual directory creation
   mkdir -p apps/android apps/ios
   
   # Check permissions
   ls -la apps/
   ```

3. **App Files Not Found**:
   ```bash
   # Check current structure
   find apps/ -type f
   
   # Verify expected locations
   ls -la apps/android/app-release.apk
   ls -la apps/ios/MyApp.app
   ```

4. **Maestro Installation Issues**:
   ```bash
   # Manual installation
   curl -Ls "https://get.maestro.mobile.dev" | bash
   export PATH="$HOME/.maestro/bin:$PATH"
   ```

3. **Java Not Found**:
   ```bash
   # macOS with Homebrew
   brew install openjdk@17
   
   # Ubuntu/Debian
   sudo apt-get install openjdk-17-jdk
   ```

4. **Android SDK Issues**:
   ```bash
   # Set environment variables
   export ANDROID_HOME="/path/to/android-sdk"
   export PATH="$ANDROID_HOME/platform-tools:$PATH"
   ```

### Runtime Issues

1. **Emulator Creation Issues**:
   ```bash
   # Use existing emulator instead of auto-creation
   ./run-tests.sh -p android --no-auto-emulator -d "Pixel_7"
   
   # Keep emulator for debugging
   ./run-tests.sh -p ios --no-cleanup
   ```

2. **Android Emulator Interference**:
   ```bash
   # Unified runner automatically handles this
   ./run-tests.sh -p ios --debug
   ```

3. **iOS Simulator Not Starting**:
   ```bash
   # Manual simulator start
   xcrun simctl boot "iPhone 16 Pro"
   open -a Simulator
   ```

3. **Permission Issues**:
   ```bash
   # Check app installation
   xcrun simctl listapps booted | grep scopex
   ```

4. **Device Connection Timeout**:
   ```bash
   # Setup script now handles timeouts automatically
   # Check manually:
   adb devices  # Android
   xcrun simctl list devices | grep Booted  # iOS
   ```

### Debug Mode

```bash
# Enable comprehensive debugging
./run-tests.sh -p ios -f guest-user-flow.yaml --debug

# Check debug logs
ls -la reports/debug_*/

# Setup script debugging
./setup.sh --check-only --verbose
```

## 📚 Documentation

- **[Maestro Commands Reference](https://docs.maestro.dev/api-reference/commands)**
- **[Maestro Advanced Features](https://docs.maestro.dev/advanced/)**
- **[Maestro JavaScript Guide](https://docs.maestro.dev/advanced/javascript/run-javascript)**
- **[Maestro Hooks Documentation](https://docs.maestro.dev/advanced/onflowstart-onflowcomplete-hooks)**
- **[Maestro Permissions Guide](https://docs.maestro.dev/advanced/configuring-permissions)**
- **[Framework Features Summary](./ENHANCED_FEATURES_SUMMARY.md)**
- **[Maestro Reference](./MAESTRO_REFERENCE.md)**

## 🔄 Getting Started Workflow

1. **Clone Repository**:
   ```bash
   git clone https://github.com/your-username/scopex-mob.git
   cd scopex-mob
   ```

2. **Run Setup**:
   ```bash
   chmod +x *.sh
   ./setup.sh --install-missing --quick-test
   ```

3. **Verify Installation**:
   ```bash
   ./setup.sh --check-only
   ```

4. **Run Your First Test**:
   ```bash
   # Run with automatic emulator management
   ./run-tests.sh -p android
   
   # Or run iOS with automatic simulator
   ./run-tests.sh -p ios
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Add your test flows or improvements
4. Test thoroughly with `./setup.sh --check-only`
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/your-username/scopex-mob/issues)
- **Documentation**: [Maestro Docs](https://docs.maestro.dev/)
- **Community**: [Maestro Community](https://github.com/mobile-dev-inc/maestro)

---

**Framework Version**: 2.1.0 (Enhanced with Intelligent Setup)  
**Last Updated**: December 2024  
**Status**: ✅ Production Ready with Timeout Protection

### Recent Improvements

- ✅ **Unified Test Runner**: Single script for both Android and iOS testing
- ✅ **Automatic Emulator Management**: Creates timestamped emulators with cleanup
- ✅ **Intelligent Setup Script**: Comprehensive environment validation
- ✅ **Timeout Protection**: Prevents hanging on slow commands
- ✅ **Cross-Platform Support**: Windows, macOS, and Linux compatibility
- ✅ **Auto-Installation**: Automated component installation where possible
- ✅ **Enhanced Error Handling**: Better error messages and recovery
- ✅ **Device Detection**: Robust Android and iOS device connectivity checks