# ScopeX Mobile Automation Framework

A comprehensive, production-ready Maestro-based mobile testing framework for the ScopeX application that works seamlessly on both Android and iOS platforms. Built with advanced features from the [Maestro documentation](https://docs.maestro.dev/) including flow hooks, JavaScript integration, video recording, and cross-platform automation.

## 🚀 Quick Start

### Automated Setup (Recommended)

```bash
# One-command setup that checks all requirements
./setup.sh --install-missing --quick-test
```

### Manual Setup

1. **Install Maestro**:
   ```bash
   curl -Ls "https://get.maestro.mobile.dev" | bash
   ```

2. **Install Dependencies**:
   - **macOS**: Xcode, iOS Simulator
   - **Windows/Linux**: Android SDK, ADB

3. **Clone and Setup**:
   ```bash
   git clone https://github.com/saur-bh/scopex-mob.git
   cd scopex-mob
   chmod +x *.sh
   ```

## 🎯 Test Execution

### Simple Test Execution

```bash
# Run guest user flow on iOS
./run-tests.sh -p ios -f guest-user-flow.yaml

# Run on Android
./run-tests.sh -p android -f guest-user-flow.yaml

# Run on both platforms
./run-tests.sh -p both -f guest-user-flow.yaml
```

### Enhanced iOS Testing

```bash
# Run with all enhanced features (recording, HTML reports, debug)
./run-ios-tests.sh --debug

# Run without recording
./run-ios-tests.sh --no-record

# Run without HTML reports
./run-ios-tests.sh --no-html

# Run on specific device
./run-ios-tests.sh -d "iPhone 15 Pro" --debug
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
mobile-automation-scopex/
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
├── apps/                          # App binaries
│   ├── android/
│   │   └── app-release.apk
│   └── ios/
│       └── MyApp.app
├── reports/                       # Test reports (auto-generated)
├── screenshots/                   # Screenshots (auto-generated)
├── maestro.yaml                   # Unified configuration
├── run-tests.sh                   # Main test runner
├── run-ios-tests.sh              # Enhanced iOS test runner
├── setup.sh                      # Environment setup
├── MAESTRO_REFERENCE.md          # Maestro documentation reference
└── README.md                     # This file
```

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

## 📊 Test Reports

### HTML Reports
- **Location**: `reports/ios_enhanced_*/report.html`
- **Features**: Screenshots, test results, execution timeline
- **Format**: Beautiful, interactive HTML reports

### Debug Output
- **Location**: `reports/ios_enhanced_*/debug/`
- **Contents**: Detailed logs, screenshots, performance metrics

### Video Recordings
- **Location**: `reports/ios_enhanced_*/`
- **Format**: MP4 video files of test execution

## 🛠️ Available Commands

### Main Test Runner (`run-tests.sh`)

```bash
Usage: ./run-tests.sh [OPTIONS]

Options:
  -p, --platform PLATFORM    Platform to test (android, ios, both)
  -f, --flow FLOW            Flow file to run
  --format FORMAT            Output format (JUNIT, HTML, NOOP)
  --debug                    Enable debug mode
  --continuous               Run in continuous mode
  --timeout TIMEOUT          Test timeout in milliseconds
  --include-tags TAGS        Include flows with specific tags
  --exclude-tags TAGS        Exclude flows with specific tags
  -h, --help                 Show help message
```

### iOS Test Runner (`run-ios-tests.sh`)

```bash
Usage: ./run-ios-tests.sh [OPTIONS]

Options:
  -f, --flow FLOW            Flow file to run [default: guest-user-flow.yaml]
  -d, --device DEVICE        Specific iOS device/simulator to use
  --no-record                Disable video recording
  --no-html                  Disable HTML report generation
  --debug                    Enable debug mode with detailed logs
  -v, --verbose              Enable verbose output
  -h, --help                 Show this help message
```

## 🔍 Troubleshooting

### Common Issues

1. **Android Emulator Interference**:
   ```bash
   # iOS test runner automatically handles this
   ./run-ios-tests.sh --debug
   ```

2. **iOS Simulator Not Starting**:
   ```bash
   # Manual simulator start
   xcrun simctl boot "iPhone 16 Pro"
   ```

3. **Permission Issues**:
   ```bash
   # Check app installation
   xcrun simctl listapps booted | grep scopex
   ```

### Debug Mode

```bash
# Enable comprehensive debugging
./run-tests.sh -p ios -f guest-user-flow.yaml --debug

# Check debug logs
ls -la reports/debug_*/
```

## 📚 Documentation

- **[Maestro Commands Reference](https://docs.maestro.dev/api-reference/commands)**
- **[Maestro Advanced Features](https://docs.maestro.dev/advanced/)**
- **[Maestro JavaScript Guide](https://docs.maestro.dev/advanced/javascript/run-javascript)**
- **[Maestro Hooks Documentation](https://docs.maestro.dev/advanced/onflowstart-onflowcomplete-hooks)**
- **[Maestro Permissions Guide](https://docs.maestro.dev/advanced/configuring-permissions)**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your test flows
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/saur-bh/scopex-mob/issues)
- **Documentation**: [Maestro Docs](https://docs.maestro.dev/)
- **Community**: [Maestro Community](https://github.com/mobile-dev-inc/maestro)

---

**Framework Version**: 2.0.0 (Enhanced)  
**Last Updated**: August 20, 2025  
**Status**: ✅ Production Ready

