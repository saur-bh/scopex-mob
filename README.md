# ScopeX Mobile Automation Framework

A comprehensive mobile automation framework using Maestro for testing the ScopeX mobile app on both Android and iOS platforms. This framework incorporates advanced Maestro features, detailed step execution, and scalable test management.

## 🎯 Project Overview

This framework is designed to test the ScopeX mobile application with a focus on:
- **Guest User Journey**: Testing onboarding and basic app functionality
- **Signup Flow**: Complete user registration and authentication
- **Post-Signup Features**: Testing authenticated user functionality
- **Cross-Platform Testing**: Support for both Android and iOS

## 📁 Project Structure

```
mobile-automation-scopex/
├── maestro.yaml                    # Main Maestro configuration
├── run-tests.sh                    # Advanced test runner script
├── setup.sh                        # Environment setup script
├── flows/                          # All test flows organized in feature directory
│   └── feature/                    # All flows are now in feature directory
│       ├── app-launch-clear-state.yaml          # App launch with clear state
│       ├── app-launch-no-clear-state.yaml       # App launch without clear state
│       ├── guest-user-journey-clear-state.yaml  # Guest user flow with clear state
│       ├── signup-flow-clear-state.yaml         # Signup flow with clear state
│       ├── send-money-flow.yaml                 # Post-signup flow (no clear state)
│       ├── wallet-flow.yaml                     # Post-signup flow (no clear state)
│       └── template-flow.yaml                   # Template for new flows
├── apps/                           # App binaries
│   ├── android/app-release.apk
│   └── ios/MyApp.app
└── reports/                        # Test results and outputs
```

## 🚀 Framework Features

### Auto Device Management
- **Automatic Device Detection**: Finds available devices/emulators
- **Automatic Device Startup**: Starts devices if none are running
- **Automatic App Installation**: Installs app if not already installed
- **Interactive Platform Selection**: Prompts for platform choice if not specified
- **Cross-Platform Support**: Works seamlessly on Android and iOS

### Flow Organization
- **All flows in `flows/feature/` directory**: Simplified organization
- **Clear State Flows**: For guest user and signup scenarios
- **No Clear State Flows**: For post-signup authenticated user scenarios
- **Automatic Dependencies**: Regression tests run signup first

### Advanced Features
- Device management (Android/iOS)
- Tag-based test execution
- Comprehensive reporting (HTML, JUnit)
- JavaScript integration for dynamic logic
- Flow hooks for setup/cleanup
- Conditional execution for platform-specific tests
- Advanced selectors for reliable element interaction

## 📝 Flow Categories

### Clear State Flows (Fresh App State)
These flows clear app state and are used for guest users and signup:

1. **`app-launch-clear-state.yaml`**
   - Tags: `feature`, `launch`, `clear-state`, `guest`, `signup`, `critical`
   - Purpose: Launch app with clean state for authentication flows

2. **`guest-user-journey-clear-state.yaml`**
   - Tags: `feature`, `guest`, `onboarding`, `clear-state`, `critical`
   - Purpose: Test complete guest user onboarding journey

3. **`signup-flow-clear-state.yaml`**
   - Tags: `feature`, `signup`, `onboarding`, `authentication`, `clear-state`, `critical`
   - Purpose: Complete user registration and authentication

### No Clear State Flows (Authenticated User)
These flows assume user is already signed up:

1. **`app-launch-no-clear-state.yaml`**
   - Tags: `feature`, `launch`, `no-clear-state`, `authenticated`, `post-signup`, `critical`
   - Purpose: Launch app without clearing state for authenticated users

2. **`send-money-flow.yaml`**
   - Tags: `feature`, `send-money`, `transfer`, `authenticated`, `post-signup`, `critical`
   - Purpose: Test money transfer functionality

3. **`wallet-flow.yaml`**
   - Tags: `feature`, `wallet`, `balance`, `authenticated`, `post-signup`, `critical`
   - Purpose: Test wallet and balance functionality

## 🚀 Quick Start

### 1. Setup Environment
```bash
./setup.sh
```

### 2. Run Tests with Auto Device Management
```bash
# Android - Auto device + app install + run tests
./run-tests.sh -p android -t "guest,clear-state"

# iOS - Auto device + app install + run tests
./run-tests.sh -p ios -t "guest,clear-state"

# Specific flow with auto platform selection
./run-tests.sh flows/feature/wallet-flow.yaml
```

### 3. Manual Device Management (Optional)
```bash
# Start Android device manually
./run-tests.sh --start-device android

# Start iOS device manually
./run-tests.sh --start-device ios

# List available devices
./run-tests.sh --list-devices
```

#### Guest User Journey (Clear State)
```bash
./run-tests.sh -t "guest,clear-state"
```

#### Signup Flow (Clear State)
```bash
./run-tests.sh -t "signup,clear-state"
```

#### Post-Signup Features (No Clear State)
```bash
./run-tests.sh -t "post-signup"
```

#### Regression Tests (Automatic Signup First)
```bash
./run-tests.sh -t regression
```

#### All Feature Tests
```bash
./run-tests.sh -t feature
```

## 🎯 Test Execution Examples

### Auto Device Management
```bash
# Platform-specific auto setup
./run-tests.sh -p android -t "guest,clear-state"         # Auto device + app + run
./run-tests.sh -p ios -t "signup,clear-state"            # Auto device + app + run
./run-tests.sh -p both -t regression                     # Auto setup for both platforms

# Flow-specific auto setup
./run-tests.sh flows/feature/wallet-flow.yaml            # Auto platform + device + app + run
./run-tests.sh -p android flows/feature/send-money-flow.yaml  # Auto device + app + run

# Interactive platform selection
./run-tests.sh -t "guest,clear-state"                    # Prompts for platform choice
```

### Manual Device Management
```bash
./run-tests.sh --start-device android                     # Start Android device
./run-tests.sh --start-device ios                         # Start iOS device
./run-tests.sh --list-devices                             # List available devices
```

### Test Execution
```bash
./run-tests.sh -t "guest,clear-state"                    # Guest user tests
./run-tests.sh -t "signup,clear-state"                   # Signup tests
./run-tests.sh -t "post-signup"                          # Post-signup tests
./run-tests.sh -t regression                             # Regression tests
./run-tests.sh -p android -t critical                    # Critical tests on Android
./run-tests.sh --format junit -t feature                 # JUnit reports
./run-tests.sh -v --debug --timeout 300                  # Verbose debug
```

### Advanced Features
```bash
./run-tests.sh --sequential --retry 3                    # Sequential with retries
./run-tests.sh --device "emulator-5554"                  # Specific device
./run-tests.sh -t "clear-state,post-signup"              # Multiple tag combinations
```

## 🔄 Flow Dependencies

### Automatic Signup for Regression
When running regression tests, the framework automatically:
1. Runs signup flow first to ensure user authentication
2. Then runs all other regression tests
3. Post-signup flows assume user is already signed up

### Manual Flow Execution
You can also run specific flows in order:
```bash
# Run signup first, then other flows
./run-tests.sh flows/feature/signup-flow-clear-state.yaml
./run-tests.sh flows/feature/send-money-flow.yaml
./run-tests.sh flows/feature/wallet-flow.yaml
```

## 📊 Reporting

### HTML Reports
- Interactive test results with step-by-step timeline
- Embedded screenshots and video recordings
- Performance metrics and execution statistics
- Error details with context and debugging info

### JUnit Reports
- CI/CD integration ready
- Test result aggregation for trend analysis
- Failure analysis with detailed error reporting



## 🔍 Troubleshooting

### Common Issues
1. **Element not found**: Use `scrollUntilVisible` or `extendedWaitUntil`
2. **Test flakiness**: Add proper waits and retry logic
3. **Platform differences**: Use conditional execution
4. **Device issues**: Auto device management handles this automatically
5. **App not installed**: Auto app installation handles this automatically

### Debug Commands
```bash
./run-tests.sh -v --debug                  # Verbose output
./run-tests.sh --list-devices              # Check devices
./run-tests.sh --start-device android      # Start fresh device
./run-tests.sh --timeout 300 --retry 3     # Timeout and retries
```

### Auto Device Management Issues
```bash
# Check device status
./run-tests.sh --list-devices

# Force device restart
./run-tests.sh --start-device android
./run-tests.sh --start-device ios

# Check app installation
./run-tests.sh -p android -t "guest,clear-state"  # Will auto-install if needed
```

## 🎯 Quality Assurance

### Code Review Checklist
- [ ] Proper test organization in feature directory
- [ ] Clear state vs no clear state flow separation
- [ ] Comprehensive logging and error handling
- [ ] Platform-specific considerations
- [ ] Appropriate use of advanced selectors
- [ ] Proper timeout and retry logic
- [ ] Clear test documentation and purpose
- [ ] Screenshots at key verification points

### Performance Standards
- Guest user tests should complete within 3-5 minutes
- Signup tests should complete within 5-8 minutes
- Post-signup tests should complete within 2-4 minutes
- Regression tests should complete within 15-20 minutes

## 🔄 CI/CD Integration

### GitHub Actions Example
```yaml
name: Maestro Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Guest User Tests
        run: ./run-tests.sh -p android -t "guest,clear-state" --format junit
      - name: Run Signup Tests
        run: ./run-tests.sh -p android -t "signup,clear-state" --format junit
      - name: Run Post-Signup Tests
        run: ./run-tests.sh -p android -t "post-signup" --format junit
      - name: Run Regression Tests
        run: ./run-tests.sh -p android -t regression --format junit
```

## 📚 Documentation

### Required Files
- `README.md` - Complete framework guide
- `.cursor` - Comprehensive Maestro reference
- `maestro.yaml` - Configuration examples
- Test flows - Advanced feature demonstrations

### Documentation Standards
- Clear and concise descriptions
- Code examples for all features
- Troubleshooting guides
- Best practices and guidelines
- Links to official documentation

## 🆘 Support & Resources

### Framework Documentation
- `.cursor` file - Comprehensive Maestro reference guide
- `maestro.yaml` - Configuration examples and best practices
- Test flows - Advanced feature demonstrations

### External Resources
- **Maestro Documentation**: https://docs.maestro.dev/
- **MCP Integration**: https://docs.maestro.dev/getting-started/maestro-mcp
- **Best Practices**: https://maestro.dev/blog/maestro-best-practices-structuring-your-test-suite
- **Community**: https://github.com/mobile-dev-inc/maestro

---

**Framework Version**: 2.0  
**Last Updated**: August 2025  
**Status**: ✅ Production Ready with Advanced Features

*This framework provides a comprehensive solution for testing the ScopeX mobile application with proper flow organization, state management, and automated dependencies.*