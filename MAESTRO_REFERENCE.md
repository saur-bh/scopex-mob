# Maestro Framework Reference Guide

This document serves as a comprehensive reference for Maestro features, commands, and best practices. Keep this file for future reference when developing mobile test automation.

## 📚 Official Documentation Links

### Core Documentation
- **Main Site**: https://docs.maestro.dev/
- **Getting Started**: https://docs.maestro.dev/getting-started/what-is-maestro
- **API Reference**: https://docs.maestro.dev/api-reference/commands
- **Advanced Features**: https://docs.maestro.dev/advanced/

### Platform Support
- **Android Views**: https://docs.maestro.dev/platform-support/android-views
- **Android Jetpack Compose**: https://docs.maestro.dev/platform-support/android-jetpack-compose
- **iOS UIKit**: https://docs.maestro.dev/platform-support/ios-uikit
- **iOS SwiftUI**: https://docs.maestro.dev/platform-support/ios-swiftui
- **React Native**: https://docs.maestro.dev/platform-support/react-native
- **Flutter**: https://docs.maestro.dev/platform-support/flutter
- **Web Views**: https://docs.maestro.dev/platform-support/web-views
- **Web Desktop**: https://docs.maestro.dev/platform-support/web-desktop-browser

## 🎯 Maestro Commands Reference

### UI Interaction Commands
```yaml
# Touch Interactions
- tapOn: "Button Text"
- tapOn:
    id: "button_id"
- tapOn:
    point: "50%,50%"
- doubleTapOn: "Element"
- longPressOn: "Element"

# Text Input
- inputText: "Hello World"
- eraseText: 10  # Delete 10 characters
- pasteText: "Clipboard content"

# Gestures
- scroll
- scrollUntilVisible: "Element"
- swipe:
    direction: UP
    duration: 1000
```

### Navigation & Control
```yaml
# App Control
- launchApp
- stopApp
- killApp
- back

# Device Control
- setOrientation: PORTRAIT  # or LANDSCAPE
- setLocation:
    latitude: 37.7749
    longitude: -122.4194
- setAirplaneMode: true
- toggleAirplaneMode
- pressKey: "Enter"  # or HOME, BACK, etc.
```

### Assertions & Validation
```yaml
# Visibility Assertions
- assertVisible: "Expected Text"
- assertNotVisible: "Hidden Element"
- assertVisible:
    id: "element_id"
    timeout: 10000

# Custom Assertions
- assertTrue: ${output.isValid}

# AI-Powered Assertions (Experimental)
- assertWithAI: "The login form is displayed correctly"
- assertNoDefectsWithAi: "Check for UI defects on this screen"
```

### Advanced Commands
```yaml
# Flow Control
- runFlow: "subflow.yaml"
- runFlow:
    file: "common/login.yaml"
    env:
      USERNAME: "testuser"

# JavaScript Execution
- runScript: |
    const timestamp = Date.now();
    output.uniqueId = `test_${timestamp}`;

# Data Extraction
- copyTextFrom: "element_id"
- extractTextWithAI: "Extract the order number from this screen"

# Waiting
- waitForAnimationToEnd
- extendedWaitUntil:
    visible: "Loading Complete"
    timeout: 30000

# Media & Recording
- takeScreenshot: "login_success"
- startRecording
- stopRecording
- addMedia:
    - "path/to/image.jpg"
```

## 🔧 Configuration Options

### Workspace Configuration
```yaml
# maestro.yaml
name: "ScopeX Mobile Tests"
version: "1.0.0"

# App configuration
app:
  android:
    appId: "com.scopex.app"
    apkPath: "apps/android/app.apk"
  ios:
    appId: "com.scopex.app"
    appPath: "apps/ios/App.app"

# Environment variables
env:
  TEST_ENVIRONMENT: "staging"
  API_URL: "https://api-staging.scopex.com"
```

### Flow Configuration
```yaml
# Individual flow configuration
appId: ${APP_ID}
name: "Authentication Flow"
tags: ["auth", "smoke", "critical"]

# Flow-specific environment
env:
  LOGIN_EMAIL: "test@example.com"
  LOGIN_PASSWORD: "password123"

# Include/exclude conditions
onlyIf:
  platform: android
  
skipIf:
  platform: ios
  version: "< 14.0"
```

## 🎨 Advanced Features

### Conditional Execution
```yaml
# Platform-specific actions
- tapOn:
    when:
      platform: android
    id: "android_button"

- tapOn:
    when:
      platform: ios
    text: "iOS Button"

# Environment-based conditions
- runFlow:
    when:
      env:
        TEST_ENVIRONMENT: "production"
    file: "production-setup.yaml"
```

### Loops and Repetition
```yaml
# Repeat actions
- repeat:
    times: 3
    commands:
      - tapOn: "Refresh"
      - waitForAnimationToEnd

# Retry on failure
- retry:
    attempts: 3
    commands:
      - tapOn: "Submit"
      - assertVisible: "Success"
```

### JavaScript Integration
```yaml
# Data manipulation
- runScript: |
    const users = ["alice", "bob", "charlie"];
    output.randomUser = users[Math.floor(Math.random() * users.length)];

- inputText: ${output.randomUser}

# HTTP requests
- runScript: |
    const response = await http.get("https://api.example.com/data");
    output.apiData = response.data;

# Element text access
- runScript: |
    const titleText = maestro.copiedText || "default";
    output.processedTitle = titleText.toUpperCase();
```

### Nested Flows
```yaml
# Main flow
---
- runFlow: "flows/setup/permissions.yaml"
- runFlow: "flows/auth/login.yaml"
- runFlow:
    file: "flows/core/guest-journey.yaml"
    env:
      USER_TYPE: "guest"

# Parameterized flows
- runFlow:
    file: "flows/common/fill-form.yaml"
    env:
      FORM_DATA: |
        {
          "name": "John Doe",
          "email": "john@example.com"
        }
```

## 🏗️ Best Practices

### Test Organization
```
tests/
├── flows/
│   ├── auth/                 # Authentication flows
│   ├── onboarding/          # User onboarding
│   ├── core/                # Core functionality
│   ├── edge-cases/          # Error scenarios
│   └── common/              # Reusable components
├── data/                    # Test data files
└── config/                  # Environment configs
```

### Flow Structure
```yaml
# Good flow structure
appId: ${APP_ID}
name: "Clear, descriptive name"
tags: ["feature", "priority", "type"]

# Setup
---
- runFlow: "common/app-setup.yaml"

# Main test logic
---
- tapOn: "Primary Action"
- assertVisible: "Expected Result"

# Cleanup
---
- runFlow: "common/cleanup.yaml"
```

### Element Selection Best Practices
```yaml
# Prefer stable selectors (in order of preference)
- tapOn:
    id: "stable_element_id"        # Best: Resource ID

- tapOn:
    accessibilityId: "button_login"  # Good: Accessibility ID

- tapOn:
    text: "Login"                   # OK: Visible text

- tapOn:
    point: "50%,50%"               # Last resort: Coordinates
```

## 🛠️ CLI Commands

### Basic Commands
```bash
# Run tests
maestro test flow.yaml
maestro test flows/

# Specific device
maestro test --device "iPhone 15" flow.yaml

# Output formats
maestro test --format junit --output report.xml flow.yaml
maestro test --format json --output report.json flow.yaml

# Tags
maestro test --include-tags smoke,auth flows/
maestro test --exclude-tags slow flows/
```

### Advanced CLI Options
```bash
# Debug and verbose
maestro test --verbose --debug-output debug/ flow.yaml

# Continuous mode
maestro test --continuous flows/

# Recording
maestro test --record flow.yaml

# Environment variables
maestro test --env USERNAME=test --env PASSWORD=secret flow.yaml

# Timeout
maestro test --timeout 300 flow.yaml
```

### Studio and Development
```bash
# Interactive development
maestro studio

# Record flow from device interaction
maestro record

# View hierarchy
maestro hierarchy

# Start device/simulator
maestro start-device
```

## 🔍 Debugging & Troubleshooting

### Common Issues and Solutions
```yaml
# Element not found - use better selectors
- tapOn:
    text: "Button"
    optional: true  # Don't fail if not found

# Timing issues - add waits
- waitForAnimationToEnd
- extendedWaitUntil:
    visible: "Element"
    timeout: 10000

# App state issues - reset state
- clearState
- killApp
- launchApp
```

### Debug Information
```yaml
# Add debug screenshots
- takeScreenshot: "before_action"
- tapOn: "Button"
- takeScreenshot: "after_action"

# Log information
- runScript: |
    console.log("Current state:", JSON.stringify(maestro.state));
```

## 🌐 CI/CD Integration

### GitHub Actions
```yaml
name: Mobile Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: mobile-dev-inc/action-maestro-cloud@v1
        with:
          api-key: ${{ secrets.MAESTRO_CLOUD_API_KEY }}
          app-file: app.apk
          flows: flows/
```

### Environment Variables for CI
```bash
# Common CI environment variables
MAESTRO_CLOUD_API_KEY=your_api_key
MAESTRO_DRIVER_TIMEOUT=60000
MAESTRO_SCREENSHOT_ON_FAILURE=true
```

## 📊 Reporting & Analytics

### Report Formats
- **JUnit XML**: Standard CI integration
- **JSON**: Programmatic processing
- **HTML**: Human-readable reports

### Custom Reporting
```yaml
# Add metadata to flows
- runScript: |
    output.testMetadata = {
      startTime: Date.now(),
      environment: maestro.env.TEST_ENVIRONMENT,
      platform: maestro.platform
    };
```

## 🔮 Future Features & Updates

### Experimental Features
- AI-powered assertions and text extraction
- Visual regression testing
- Performance monitoring integration

### Keeping Updated
```bash
# Update Maestro
curl -Ls "https://get.maestro.mobile.dev" | bash

# Check version
maestro --version

# View changelog
# Visit: https://github.com/mobile-dev-inc/maestro/releases
```

---

## 📝 Quick Reference Card

### Most Used Commands
```yaml
# Essential commands for daily use
- launchApp
- tapOn: "text"
- inputText: "value"
- assertVisible: "element"
- takeScreenshot: "name"
- runFlow: "path/to/flow.yaml"
```

### Most Used Selectors
```yaml
# Reliable element selection
id: "resource_id"
text: "Visible Text"
accessibilityId: "accessibility_id"
point: "x%,y%"
```

### Most Used Configuration
```yaml
# Standard flow header
appId: ${APP_ID}
name: "Flow Name"
tags: ["category", "priority"]
```

**Remember**: Always refer to the official Maestro documentation for the latest features and updates: https://docs.maestro.dev/
