# ScopeX Mobile Automation Framework v2.0

**Comprehensive mobile automation framework using Maestro with advanced features, detailed step execution, and scalable test management.**

## 🚀 Framework Overview

This framework incorporates all advanced Maestro features including:
- ✅ **Device Management** - Start and manage Android/iOS devices
- ✅ **Advanced Test Execution** - Tag-based, sequential, parallel execution
- ✅ **Comprehensive Reporting** - HTML, JUnit, AI analysis reports
- ✅ **JavaScript Integration** - Dynamic test logic and API calls
- ✅ **Flow Hooks** - Setup and cleanup automation
- ✅ **Conditional Execution** - Platform-specific test logic
- ✅ **Advanced Selectors** - Reliable element interaction
- ✅ **Performance Monitoring** - Test execution metrics

## 📁 Framework Structure

```
mobile-automation-scopex/
├── maestro.yaml                    # Comprehensive configuration
├── run-tests.sh                    # Advanced test runner v2.0
├── setup.sh                        # Environment setup
├── flows/                          # Organized test categories
│   ├── smoke/                      # Quick smoke tests
│   │   └── app-launch.yaml         # Enhanced app launch test
│   ├── regression/                 # Comprehensive regression tests
│   │   └── guest-user-journey.yaml # Full user journey test
│   ├── feature/                    # Feature-specific tests
│   │   └── user-authentication.yaml # Authentication flow test
│   └── integration/                # Integration tests
│       └── main-navigation.yaml    # Navigation integration test
├── apps/                           # App binaries
│   ├── android/app-release.apk
│   └── ios/MyApp.app
└── reports/                        # Comprehensive test results
    ├── screenshots/                # Test screenshots
    ├── recordings/                 # Video recordings
    ├── logs/                       # Maestro logs
    ├── step-logs/                  # Detailed step execution
    ├── ai-analysis/                # AI analysis reports
    └── performance/                # Performance metrics
```

## 🎯 Quick Start

### 1. Setup Environment
```bash
./setup.sh
```

### 2. Device Management
```bash
# Start Android device
./run-tests.sh --start-device android

# Start iOS device
./run-tests.sh --start-device ios

# List available devices
./run-tests.sh --list-devices
```

### 3. Run Tests
```bash
# Run smoke tests
./run-tests.sh -t smoke

# Run regression tests with AI analysis
./run-tests.sh -t regression --analyze

# Run specific platform
./run-tests.sh -p android -t smoke

# Run with JUnit reporting
./run-tests.sh --format junit -t critical

# Run with verbose debugging
./run-tests.sh -v --debug -t smoke
```

## 🔧 Advanced Features

### Device Management
```bash
# Start devices
./run-tests.sh --start-device android
./run-tests.sh --start-device ios

# Use specific device
./run-tests.sh --device "emulator-5554"
```

### Test Execution Options
```bash
# Tag-based execution
./run-tests.sh -t smoke                    # Run smoke tests
./run-tests.sh -t regression -e slow       # Run regression excluding slow tests
./run-tests.sh -t "smoke,critical"         # Run multiple tags

# Platform-specific
./run-tests.sh -p android                  # Android only
./run-tests.sh -p ios                      # iOS only
./run-tests.sh -p both                     # Both platforms

# Advanced execution
./run-tests.sh --sequential                # Sequential execution
./run-tests.sh --timeout 300               # Set timeout
./run-tests.sh --retry 3                   # Retry failed tests

# Advanced options
./run-tests.sh --analyze                   # Enable AI analysis
./run-tests.sh --sequential                # Sequential execution
./run-tests.sh --timeout 300               # Set timeout
./run-tests.sh --retry 3                   # Retry failed tests
./run-tests.sh -v --debug                  # Verbose debug mode
```

### Report Formats
```bash
# HTML reports (default)
./run-tests.sh --format html

# JUnit reports for CI/CD
./run-tests.sh --format junit
```

## 📊 Test Categories & Tag Organization

### Smoke Tests
- **Purpose**: Quick validation of basic functionality
- **Tags**: `smoke`, `critical`
- **Examples**: App launch, basic navigation
- **Current Tests**: 
  - `flows/smoke/app-launch.yaml` (smoke, launch, critical)
  - `flows/feature/guest-user-journey.yaml` (smoke, regression, guest, onboarding, critical)

### Regression Tests
- **Purpose**: Comprehensive testing of existing features
- **Tags**: `regression`, `critical`
- **Examples**: Complete user journeys, end-to-end flows
- **Current Tests**:
  - `flows/feature/guest-user-journey.yaml` (smoke, regression, guest, onboarding, critical)

### Feature Tests (`flows/feature/`)
- **Purpose**: Testing specific features
- **Tags**: `feature`, `template`, `example`
- **Examples**: User authentication, payment flows
- **Current Tests**:
  - `flows/feature/guest-user-journey.yaml` (smoke, regression, guest, onboarding, critical)
  - `flows/feature/template-flow.yaml` (template, example)

### Integration Tests (`flows/integration/`)
- **Purpose**: Testing component integration
- **Tags**: `integration`, `navigation`, `critical`
- **Examples**: Cross-feature navigation, API integration
- **Current Tests**:
  - `flows/integration/main-navigation.yaml` (integration, navigation, critical)

## 🎯 Advanced Test Features

### Flow Hooks
```yaml
onFlowStart:
  - evalScript: "console.log('Starting test...');"
  - evalScript: "output.startTime = Date.now();"

onFlowComplete:
  - evalScript: "console.log('Test completed');"
  - takeScreenshot: "test-complete"
```

### JavaScript Integration
```yaml
# Dynamic logging
- evalScript: "console.log('Step executed');"

# Element text extraction
- copyTextFrom: "Button"
- evalScript: "console.log('Button text:', output.text);"

# HTTP requests
- evalScript: |
    const response = fetch('https://api.scopex.com/data');
    const data = response.json();
    output.apiData = data;
```

### Advanced Selectors
```yaml
# Multiple selector types
- tapOn:
    id: "button_id"
    text: "Button Text"
    index: 0

# Scroll until visible
- scrollUntilVisible:
    element: "Target Element"
    direction: DOWN
    timeout: 5000
```

### Conditional Execution
```yaml
# Platform-specific flows
- runFlow:
    when:
      platform: android
    file: "flows/android-specific.yaml"
```

## 📈 Reporting & Analysis

### HTML Reports
- **Interactive test results** with step-by-step timeline
- **Performance metrics** and execution statistics
- **Error details** with context and debugging info

### Media Files & Recordings
- **Screen Recordings**: MP4 videos of test execution
- **Screenshots**: PNG images at key test points
- **Media Links Page**: Dedicated HTML page with all media files
- **File Organization**: All media organized in reports subdirectories

### AI Analysis
- **Automated issue detection** in UI/UX
- **Internationalization checks** for localization
- **Performance insights** and optimization suggestions
- **Accessibility recommendations**

### JUnit Reports
- **CI/CD integration** ready
- **Test result aggregation** for trend analysis
- **Failure analysis** with detailed error reporting

## 🔍 Troubleshooting

### Common Issues
1. **Element not found**: Use `scrollUntilVisible` or `extendedWaitUntil`
2. **Test flakiness**: Add proper waits and retry logic
3. **Platform differences**: Use conditional execution
4. **Device issues**: Check device connectivity and restart if needed
5. **YAML parsing errors**: Ensure proper quoting in evalScript commands
6. **Missing flow files**: Check that referenced flows exist

### Debug Commands
```bash
# Verbose output with debugging
./run-tests.sh -v --debug

# Check device status
./run-tests.sh --list-devices

# Start fresh device
./run-tests.sh --start-device android

# Run with timeout and retries
./run-tests.sh --timeout 300 --retry 3

# Check test execution logs
cat reports/test-run-*/step-logs/test-execution.log
```

### Setup Issues
```bash
# Run setup to check environment
./setup.sh

# Verify Maestro installation
maestro --version

# Check Android devices
adb devices

# Check iOS simulators (macOS only)
xcrun simctl list devices
```

## 🚀 CI/CD Integration

### GitHub Actions Example
```yaml
name: Maestro Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Smoke Tests
        run: |
          ./run-tests.sh -p android -t smoke --format junit
          ./run-tests.sh -p ios -t smoke --format junit
      - name: Run Regression Tests
        run: |
          ./run-tests.sh -p android -t regression --format junit
```

## 📚 Documentation

### Framework Reference
- **`.cursor`** - Comprehensive Maestro reference guide
- **`maestro.yaml`** - Configuration examples
- **Test flows** - Advanced feature demonstrations

### Maestro Documentation
- **Main Docs**: https://docs.maestro.dev/
- **Commands**: https://docs.maestro.dev/api-reference/commands
- **Advanced Features**: https://docs.maestro.dev/advanced/
- **Best Practices**: https://maestro.dev/blog/maestro-best-practices-structuring-your-test-suite

## 🎯 Best Practices

1. **Organize tests by category** (smoke, regression, feature, integration)
2. **Use descriptive tags** for test selection and filtering
3. **Implement proper error handling** with retry logic
4. **Add comprehensive logging** for debugging and monitoring
5. **Use conditional execution** for platform-specific tests
6. **Implement flow hooks** for setup and cleanup automation
7. **Use advanced selectors** for reliable element interaction
8. **Enable AI analysis** for automated insights and recommendations
9. **Generate multiple report formats** for different stakeholders
10. **Monitor performance** and optimize test execution

## 🆘 Support

- **Framework Issues**: Check the `.cursor` file for comprehensive reference
- **Maestro Community**: https://github.com/mobile-dev-inc/maestro
- **Documentation**: https://docs.maestro.dev/
- **Slack**: Join the Maestro community for support

---

**Framework Version**: 2.0  
**Last Updated**: August 2025  
**Status**: ✅ Production Ready with Advanced Features