# ScopeX Mobile Automation Framework

Mobile automation framework using Maestro for testing the ScopeX mobile app on Android and iOS.

## 🚀 Quick Start

### 1. Setup Environment
First, run the setup script to verify everything is configured correctly:
```bash
./setup.sh
```

### 2. Run Tests

#### Smoke Tests (Quick validation)
```bash
./run-tests.sh -t "smoke"
```
#### Sanity Tests (Quick validation)
```bash
./run-tests.sh -t "sanity"
```

#### Regression Tests (Full test suite)
```bash
./run-tests.sh -t "regression"
```

### 3. Create New Tests
Use the flow generator to create new test cases:
```bash
./create-flow.sh
```

## 📁 Project Structure

```
mobile-automation-scopex/
├── run-tests.sh                    # Test runner
├── setup.sh                        # Environment setup
├── create-flow.sh                  # Test generator
├── flows/feature/                  # Test flows
└── reports/                        # Test results
```

## 📋 Test Types

### Smoke Tests
Quick validation tests that run the most critical user journeys:
- Guest user onboarding
- User signup flow

### Regression Tests
Comprehensive test suite covering all features:
- All smoke tests
- Post-signup functionality
- Edge cases and error scenarios

## 🔧 Advanced Usage

### Platform-specific Testing
```bash
# Run tests on specific platform
./run-tests.sh -p android -t "smoke"
./run-tests.sh -p ios -t "regression"
```

### Custom Test Creation
The flow generator will guide you through creating new tests:
```bash
./create-flow.sh
# Follow the interactive prompts to:
# - Name your test
# - Add description
# - Choose test type (smoke/regression)
# - Set tags
```

## 📊 Test Reports

After running tests, comprehensive HTML reports are automatically generated in the `reports/` directory with:
- Test execution timeline
- Screenshots and recordings
- Detailed step logs
- Success/failure analysis

## 🛠️ Troubleshooting

If tests fail:
1. Check the setup: `./setup.sh`
2. Verify device connectivity: `./run-tests.sh --list-devices`
3. Review test reports in `reports/` directory
4. Check step-by-step logs for detailed error information