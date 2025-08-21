# ScopeX Mobile Automation Framework - Command Fixes

## 🎯 Summary of Command Corrections

This document outlines all the command fixes made across the framework to ensure consistency and accuracy.

### ✅ **Issues Fixed:**

1. **Removed AI Analysis Commands** - `--analyze` flag removed from all files
2. **Updated Flow Structure References** - All flows now in `flows/feature/` directory
3. **Corrected Test Commands** - Updated to match current framework structure
4. **Fixed Directory References** - Removed old directory structure references
5. **Updated Tag References** - Changed from old tags to new tag structure

## 🔧 **Files Updated:**

### 1. **setup.sh** - Main Setup Script
**Before:**
```bash
# Old commands
./run-tests.sh -t smoke                 # Run smoke tests
./run-tests.sh -p android -t regression # Run regression on Android
./run-tests.sh --analyze                # Run with AI analysis

# Old directory structure
mkdir -p flows/smoke
mkdir -p flows/regression
mkdir -p flows/integration
mkdir -p reports/ai-analysis
```

**After:**
```bash
# Updated commands
./run-tests.sh -t "guest,clear-state"  # Run guest user tests
./run-tests.sh -t "signup,clear-state" # Run signup tests
./run-tests.sh -t "post-signup"        # Run post-signup tests
./run-tests.sh -t regression           # Run regression tests

# Updated directory structure
mkdir -p flows/feature
# Removed ai-analysis directory
```

### 2. **run-tests.sh** - Test Runner
**Before:**
```bash
echo "  $0 -p android -t smoke                       # Run smoke tests on Android"
echo "  smoke, regression, feature, integration, critical, guest, authentication, clear-state, post-signup"
```

**After:**
```bash
echo "  $0 -p android -t \"guest,clear-state\"        # Run guest user tests on Android"
echo "  feature, clear-state, post-signup, critical, guest, authentication"
```

### 3. **maestro.yaml** - Configuration
**Before:**
```yaml
flows:
  - "flows/smoke/*.yaml"           # Smoke tests
  - "flows/regression/*.yaml"      # Regression tests
  - "flows/feature/*.yaml"         # Feature-specific tests
  - "flows/integration/*.yaml"     # Integration tests

executionOrder:
  flowsOrder:
    - "app-launch"
    - "guest-user-journey"
    - "main-navigation"
```

**After:**
```yaml
flows:
  - "flows/feature/*.yaml"         # All feature tests organized here

executionOrder:
  flowsOrder:
    - "app-launch-clear-state"
    - "guest-user-journey-clear-state"
    - "signup-flow-clear-state"
```

### 4. **.cursor** - Reference Guide
**Before:**
```bash
maestro test flows/smoke/app-launch.yaml
maestro test --include-tags smoke --exclude-tags slow flows/
./run-tests.sh -t smoke
```

**After:**
```bash
maestro test flows/feature/app-launch-clear-state.yaml
maestro test --include-tags clear-state --exclude-tags slow flows/
./run-tests.sh -t "clear-state"
```

### 5. **.cursorrules** - Project Rules
**Before:**
```bash
./run-tests.sh -t smoke                    # Smoke tests
./run-tests.sh -t regression --analyze     # Regression with AI
```

**After:**
```bash
./run-tests.sh -t "guest,clear-state"      # Guest user tests
./run-tests.sh -t regression               # Regression tests
```

## 🚀 **Current Correct Commands:**

### **Device Management**
```bash
./run-tests.sh --start-device android      # Start Android device
./run-tests.sh --start-device ios          # Start iOS device
./run-tests.sh --list-devices              # List available devices
```

### **Test Execution**
```bash
# Clear state flows (fresh app state)
./run-tests.sh -t "guest,clear-state"      # Guest user journey
./run-tests.sh -t "signup,clear-state"     # Signup flow
./run-tests.sh -t "clear-state"            # All clear state flows

# Post-signup flows (authenticated user)
./run-tests.sh -t "post-signup"            # All post-signup flows
./run-tests.sh -t "send-money"             # Send money flow
./run-tests.sh -t "wallet"                 # Wallet flow

# Regression and feature tests
./run-tests.sh -t regression               # Regression tests (auto signup first)
./run-tests.sh -t feature                  # All feature tests
```

### **Advanced Options**
```bash
./run-tests.sh -p android -t "guest,clear-state"  # Platform specific
./run-tests.sh --format junit -t feature          # JUnit reports
./run-tests.sh -v --debug --timeout 300           # Verbose debug
./run-tests.sh --sequential --retry 3             # Sequential with retries
```

## 📁 **Current Directory Structure:**

```
mobile-automation-scopex/
├── flows/
│   └── feature/                    # All flows organized here
│       ├── app-launch-clear-state.yaml
│       ├── guest-user-journey-clear-state.yaml
│       ├── signup-flow-clear-state.yaml
│       ├── send-money-flow.yaml
│       └── wallet-flow.yaml
├── reports/
│   ├── screenshots/
│   ├── recordings/
│   ├── logs/
│   ├── step-logs/
│   └── performance/
└── apps/
    ├── android/
    └── ios/
```

## ✅ **Verification:**

The setup script now correctly shows:
```bash
[INFO] Available commands:
[INFO]   ./run-tests.sh --help                    # Show all options
[INFO]   ./run-tests.sh --list-devices           # List available devices
[INFO]   ./run-tests.sh -t "guest,clear-state"  # Run guest user tests
[INFO]   ./run-tests.sh -t "signup,clear-state" # Run signup tests
[INFO]   ./run-tests.sh -t "post-signup"        # Run post-signup tests
[INFO]   ./run-tests.sh -t regression            # Run regression tests
```

## 🎯 **Framework Status:**

**✅ All Commands Corrected** with:
- **Consistent command structure** across all files
- **No AI analysis references** - Clean and focused
- **Proper flow organization** - All flows in feature directory
- **Accurate tag references** - Updated to match current structure
- **Working setup script** - Shows correct commands and structure

All commands in the framework now match the actual implementation and will work correctly! 🎉
