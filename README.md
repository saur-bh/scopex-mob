# ScopeX Mobile Automation Framework

A comprehensive, production-ready Maestro-based mobile testing framework for the ScopeX application that works seamlessly on both Android and iOS platforms. Built with advanced features from the [Maestro documentation](https://docs.maestro.dev/) including continuous testing, advanced reporting, and cross-platform automation.

## 🚀 Quick Start

### Automated Setup (Recommended)

```bash
# One-command setup that checks all requirements
./setup.sh --install-missing --quick-test

# Or just check current setup
./setup.sh --check-only
```

The setup script automatically:
- ✅ Detects your operating system (Windows/macOS/Linux)
- ✅ Checks for Java, Android SDK, Xcode (macOS only)
- ✅ Installs Maestro CLI
- ✅ Verifies device connectivity
- ✅ Creates Android emulator if needed
- ✅ Runs a quick test to verify everything works

### Manual Setup

#### Prerequisites

- **Windows**: Android testing only (iOS requires macOS)
- **macOS**: Full Android + iOS testing support
- **Linux**: Android testing only

#### Install Maestro

```bash
# Install Maestro CLI (all platforms)
curl -Ls "https://get.maestro.mobile.dev" | bash

# Verify installation
maestro --version
```

#### Platform-Specific Setup

**Android (All Platforms):**
```bash
# Install Java 17 and Android SDK
# Windows: choco install openjdk17 androidstudio
# macOS: brew install openjdk@17 android-sdk
# Linux: sudo apt-get install openjdk-17-jdk

# Start Android emulator
emulator -avd Pixel_7_API_34

# Or connect physical device
adb devices
```

**iOS (macOS only):**
```bash
# Install Xcode from App Store
# Start iOS Simulator
open -a Simulator

# Verify simulator is running
xcrun simctl list devices booted
```

## 🧪 Running Tests

### Simple Test Execution

```bash
# Run guest user flow on Android (default)
./run-tests.sh

# Run guest user flow on iOS
./run-tests.sh -p ios

# Run on both platforms sequentially
./run-tests.sh -p both

# Run on both platforms in parallel
./run-tests.sh -p both --parallel
```

### Advanced Test Execution

Based on [Maestro's advanced features](https://docs.maestro.dev/advanced/):

```bash
# Run with specific device
./run-tests.sh -d "iPhone 15 Pro" -p ios

# Run with tags (flows tagged with 'smoke' or 'auth')
./run-tests.sh --include-tags smoke,auth

# Exclude certain flows
./run-tests.sh --exclude-tags slow,integration

# Different output formats
./run-tests.sh --format html          # HTML report
./run-tests.sh --format junit         # JUnit XML (default)
./run-tests.sh --format noop          # Text output only

# Debug mode with detailed logging
./run-tests.sh --debug --verbose

# Record test execution videos
./run-tests.sh --record

# Continuous mode - watch for file changes and rerun
./run-tests.sh --continuous

# Set timeout for tests
./run-tests.sh -t 300                 # 5 minute timeout

# Combine multiple options
./run-tests.sh -p ios --debug --record --include-tags smoke -d "iPhone 15"
```

### Available Options

**Platform Options:**
- `-p, --platform`: Platform to test (`android|ios|both`) [default: android]
- `-d, --device`: Specific device/emulator to use

**Test Options:**
- `-f, --flow`: Flow file to run [default: guest-user-flow.yaml]
- `-t, --timeout`: Test timeout in seconds
- `--include-tags`: Run flows with specific tags (comma-separated)
- `--exclude-tags`: Exclude flows with specific tags (comma-separated)

**Output Options:**
- `--format`: Output format (`junit|html|noop`) [default: junit]
- `-v, --verbose`: Enable verbose output
- `--debug`: Enable debug mode with detailed logs

**Execution Options:**
- `--parallel`: Run tests in parallel (when using 'both' platform)
- `--continuous`: Run in continuous mode (watch for changes)
- `--record`: Record test execution video

**Help:**
- `-h, --help`: Show detailed help message

## 📁 Project Structure

```
mobile-automation-scopex/
├── flows/                          # Test flow definitions
│   ├── guest-user-flow.yaml        # Main guest user journey
│   ├── auth-flow.yaml              # Authentication flows
│   ├── home-screen-flow.yaml       # Home screen tests
│   └── permissions/                # Platform-specific permissions
│       ├── android-permissions.yaml
│       └── ios-permissions.yaml
├── apps/                           # Application binaries
│   ├── android/
│   │   └── app-release.apk         # Android APK
│   └── ios/
│       └── MyApp.app/              # iOS app bundle
├── reports/                        # Test execution reports
├── maestro.yaml                    # Unified configuration
├── run-tests.sh                    # Test runner script
└── README.md                       # This file
```

## 📱 Platform Support

### Android Testing

**Requirements:**
- Java 11+ and Android SDK
- Android emulator or physical device
- ADB in PATH

**Setup:**
```bash
# Install Android SDK and create emulator
# Then run tests
./run-tests.sh -p android
```

### iOS Testing

**Requirements:**
- macOS with Xcode installed
- iOS Simulator or physical device

**Setup:**
```bash
# Install Xcode from App Store
# Start Simulator
open -a Simulator

# Run tests
./run-tests.sh -p ios
```

## 🔧 Configuration

### Maestro Configuration

The framework uses `maestro.yaml` for unified configuration following [Maestro's configuration guidelines](https://docs.maestro.dev/api-reference/configuration):

```yaml
# App configuration
app:
  android:
    appId: "com.scopex.scopexmobilev2"
    apkPath: "apps/android/app-release.apk"
  ios:
    appId: "com.scopex.scopexmobilev2"
    appPath: "apps/ios/MyApp.app"

# Device preferences
device:
  android:
    preferred: ["Pixel_7_API_34", "Pixel_6_API_33"]
  ios:
    preferred: ["iPhone 15", "iPhone 14", "iPhone 13"]

# Test configuration with timeouts
testing:
  timeouts:
    appLaunch: 15000
    elementWait: 10000
    permissionDialog: 5000
```

### Environment Variables

The framework automatically sets these variables:
- `PLATFORM`: Current platform (android/ios)
- `APP_ID`: Application bundle ID
- `TEST_ENVIRONMENT`: Test environment (staging)
- `MAESTRO_TIMEOUT`: Default test timeout

### Flow Configuration

Each test flow supports [Maestro's flow configuration](https://docs.maestro.dev/api-reference/configuration/flow-configuration):

```yaml
# Example flow with tags and metadata
appId: ${APP_ID}
name: "Guest User Journey"
tags: ["guest", "onboarding", "smoke"]

# Platform-specific conditions
---
- runFlow:
    when:
      platform: android
    file: permissions/android-permissions.yaml
```

## 📊 Test Reports

Reports are automatically generated in the `reports/` directory:

```bash
reports/
├── android_20241219_143022/        # Android test results
├── ios_20241219_143045/            # iOS test results
└── junit/                          # JUnit XML reports
```

## 🔄 CI/CD Integration

### GitHub Actions Example

```yaml
name: Mobile Tests
on: [push, pull_request]

jobs:
  mobile-tests:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install Maestro
        run: curl -Ls "https://get.maestro.mobile.dev" | bash
      - name: Start Android Emulator
        run: |
          echo "y" | sdkmanager "system-images;android-34;google_apis;x86_64"
          echo "no" | avdmanager create avd -n Pixel_7_API_34 -k "system-images;android-34;google_apis;x86_64"
          emulator -avd Pixel_7_API_34 &
          sleep 60
      - name: Run Android Tests
        run: ./run-tests.sh -p android
      - name: Upload Reports
        uses: actions/upload-artifact@v3
        with:
          name: test-reports
          path: reports/
```

## 🛠️ Troubleshooting

### Common Issues

**Maestro not found:**
```bash
# Install Maestro
curl -Ls "https://get.maestro.mobile.dev" | bash
```

**No Android device:**
```bash
# Start emulator
emulator -avd Pixel_7_API_34

# Or connect device
adb devices
```

**No iOS simulator:**
```bash
# Start Simulator
open -a Simulator

# Check available devices
xcrun simctl list devices
```

**App installation fails:**
```bash
# Android
adb install -r apps/android/app-release.apk

# iOS
xcrun simctl install booted apps/ios/MyApp.app
```

## 🚀 Advanced Features

### Maestro Commands Reference

The framework supports all [Maestro commands](https://docs.maestro.dev/api-reference/commands):

**UI Interactions:**
- `tapOn`, `doubleTapOn`, `longPressOn`: Touch interactions
- `inputText`, `eraseText`: Text input
- `scroll`, `scrollUntilVisible`: Scrolling actions
- `swipe`: Gesture navigation
- `pressKey`: Keyboard interactions

**Assertions:**
- `assertVisible`, `assertNotVisible`: Element visibility
- `assertTrue`: Custom assertions
- `assertWithAI`: AI-powered assertions (experimental)

**Navigation & Control:**
- `launchApp`, `stopApp`, `killApp`: App lifecycle
- `back`: Navigation
- `setOrientation`: Device rotation
- `setLocation`: GPS simulation

**Advanced Commands:**
- `runFlow`: [Nested flows](https://docs.maestro.dev/advanced/nested-flows)
- `runScript`: JavaScript execution
- `takeScreenshot`: Capture screenshots
- `startRecording`, `stopRecording`: Video recording

### Using JavaScript in Flows

Leverage [Maestro's JavaScript support](https://docs.maestro.dev/advanced/using-javascript-in-maestro) for dynamic testing:

```yaml
- runScript: |
    const currentDate = new Date().toISOString().split('T')[0];
    output.testDate = currentDate;

- inputText: ${output.testDate}
```

### Conditional Testing

Use [conditions](https://docs.maestro.dev/advanced/conditions) for platform-specific logic:

```yaml
- tapOn:
    when:
      platform: android
    id: "com.android.permissioncontroller:id/permission_allow_button"

- tapOn:
    when:
      platform: ios
    text: "Allow"
```

### Test Suite Organization

Following [Maestro's best practices](https://docs.maestro.dev/advanced/structuring-your-test-suite):

- **Atomic Tests**: Each flow tests one specific feature
- **Reusable Components**: Use `runFlow` for common actions
- **Tag-based Organization**: Group flows with meaningful tags
- **Data-driven Testing**: Use environment variables and scripts

## 🔗 Maestro Documentation Links

### Essential References
- **[Getting Started](https://docs.maestro.dev/getting-started/what-is-maestro)**: Introduction to Maestro
- **[Commands API](https://docs.maestro.dev/api-reference/commands)**: Complete command reference
- **[Advanced Features](https://docs.maestro.dev/advanced/)**: Advanced testing techniques
- **[Configuration](https://docs.maestro.dev/api-reference/configuration)**: Configuration options

### Advanced Topics
- **[Nested Flows](https://docs.maestro.dev/advanced/nested-flows)**: Reusable test components
- **[JavaScript Support](https://docs.maestro.dev/advanced/using-javascript-in-maestro)**: Dynamic test logic
- **[Conditions & Loops](https://docs.maestro.dev/advanced/conditions)**: Control flow
- **[Wait Commands](https://docs.maestro.dev/advanced/wait-commands-in-maestro-for-reliable-tests)**: Reliable timing

### Platform-Specific
- **[Android Testing](https://docs.maestro.dev/platform-support/android-views)**: Android-specific features
- **[iOS Testing](https://docs.maestro.dev/platform-support/ios-uikit)**: iOS-specific features
- **[React Native](https://docs.maestro.dev/platform-support/react-native)**: React Native support
- **[Flutter](https://docs.maestro.dev/platform-support/flutter)**: Flutter support

### CI/CD Integration
- **[GitHub Actions](https://docs.maestro.dev/ci-integration/github-actions)**: GitHub workflow integration
- **[Running on CI](https://docs.maestro.dev/getting-started/running-flows-on-ci)**: General CI setup
- **[Maestro Cloud](https://docs.maestro.dev/cloud)**: Cloud testing platform

## 📚 Framework Resources

### Local Documentation
- **Setup Guide**: `./setup.sh --help`
- **Test Runner**: `./run-tests.sh --help`
- **Flow Examples**: Check `flows/` directory

### External Resources
- **[Maestro GitHub](https://github.com/mobile-dev-inc/maestro)**: Source code and issues
- **[Community Slack](https://maestro.mobile.dev/join-slack)**: Community support
- **[Mobile Testing Best Practices](https://docs.maestro.dev/best-practices)**: Testing guidelines

---

**Note:** This framework is built on Maestro's advanced capabilities and follows industry best practices for mobile test automation. All platform-specific logic is handled automatically, allowing you to focus on writing comprehensive test flows.

