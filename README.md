# ScopeX Mobile Automation Framework

Advanced mobile automation framework using Maestro for testing the ScopeX mobile app on Android and iOS with AI-powered assertions and comprehensive reporting.

## 🚀 Quick Start

### 1. Setup Environment
First, run the setup script to verify everything is configured correctly:
```bash
./setup.sh
```

### 2. Run Tests

#### Sanity Tests (Quick validation with AI assertions)
```bash
./run-tests.sh -p android -t "sanity"
```

#### Clear State Tests (Fresh app state)
```bash
./run-tests.sh -t "clear-state"
```

#### Feature Tests (Specific functionality)
```bash
./run-tests.sh -t "feature"
```

#### Critical Tests (Essential flows)
```bash
./run-tests.sh -t "critical"
```

### 3. Create New Tests
Use the flow generator to create new test cases:
```bash
./create-flow.sh
```

## 📁 Project Structure

```
mobile-automation-scopex/
├── run-tests.sh                    # Advanced test runner with AI support
├── setup.sh                        # Environment setup
├── create-flow.sh                  # Test generator
├── maestro.yaml                    # Maestro configuration
├── config.yaml                     # Project configuration
├── flows/feature/                  # Test flows organized by category
│   ├── allCase.yaml               # Comprehensive test suite
│   ├── PromoCode.yaml             # Promo code testing
│   ├── Recipient.yaml             # Recipient management
│   ├── Rewards.yaml               # Rewards functionality
│   └── ...                        # Other test flows
├── scripts/                        # JavaScript utilities
│   └── getRate.js                 # API rate fetching
├── apps/                          # App binaries
│   ├── android/app-release.apk
│   └── ios/MyApp.app
└── reports/                        # Test results and outputs
```

## 📋 Test Types

### Sanity Tests
Quick validation tests with AI-powered assertions:
- App launch and navigation
- Settings screen verification with AI
- API integration testing
- Rate fetching and validation

### Clear State Tests
Tests that start with fresh app state:
- Guest user onboarding
- User signup flow
- App launch without cached data

### Feature Tests
Specific functionality testing:
- Promo code validation
- Recipient management
- Rewards system
- Wallet operations

### Critical Tests
Essential user journeys that must always pass:
- Core app functionality
- Payment flows
- User authentication

## 🔧 Advanced Usage

### Platform-specific Testing
```bash
# Run tests on specific platform
./run-tests.sh -p android -t "sanity"
./run-tests.sh -p ios -t "sanity"
./run-tests.sh -p android -t "feature"
```

### AI-Powered Testing
The framework includes AI-powered assertions for complex UI verification:
- `assertWithAI` for intelligent element detection
- Automatic screenshot analysis
- Smart error detection and reporting

### API Integration
JavaScript utilities for dynamic testing:
- Real-time API calls during test execution
- Dynamic data validation
- External service integration

### Custom Test Creation
The flow generator will guide you through creating new tests:
```bash
./create-flow.sh
# Follow the interactive prompts to:
# - Name your test
# - Add description
# - Choose test type (sanity/clear-state/feature/critical)
# - Set tags
```

## 📊 Test Reports

After running tests, comprehensive HTML reports are automatically generated in the `reports/` directory with:
- **Interactive Test Results** - Step-by-step timeline with expandable details
- **AI Analysis Reports** - Intelligent UI/UX analysis and defect detection
- **Screenshots & Recordings** - Visual evidence of test execution
- **Performance Metrics** - Execution time and resource usage
- **Detailed Step Logs** - Complete execution trace for debugging
- **Success/Failure Analysis** - Root cause analysis and recommendations

## 🚀 Key Features

- **AI-Powered Assertions** - Intelligent UI verification using `assertWithAI`
- **API Integration** - Real-time data fetching and validation
- **Comprehensive Reporting** - Rich HTML reports with media and analysis
- **Multi-Platform Support** - Android and iOS testing
- **Auto Device Management** - Intelligent device detection and setup
- **Fresh App Installation** - Ensures clean test environment
- **Advanced Flow Organization** - Tagged test categorization
- **JavaScript Integration** - Dynamic test logic and data handling

## 🛠️ Troubleshooting

If tests fail:
1. Check the setup: `./setup.sh`
2. Verify device connectivity: `./run-tests.sh --list-devices`
3. Review comprehensive reports in `reports/` directory
4. Check AI analysis reports for intelligent error detection
5. Review step-by-step logs for detailed error information
6. Verify API connectivity for dynamic tests

## 🔑 Environment Variables

The framework automatically configures:
- `MAESTRO_CLOUD_API_KEY` - For AI-powered assertions and analysis
- Platform-specific device management
- App installation and verification