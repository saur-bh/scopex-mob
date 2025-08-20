#!/bin/bash

# Comprehensive ScopeX Mobile Automation Setup Script
# Advanced setup for Maestro mobile testing framework

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║            Comprehensive ScopeX Mobile Automation Setup v2.0         ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[⚠ WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERROR]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to compare versions
version_ge() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

print_header

# Check operating system
OS=$(detect_os)
print_status "Operating System: $OS"

if [[ "$OS" == "unknown" ]]; then
    print_error "Unsupported operating system"
    exit 1
fi

# Check Java
print_step "Checking Java installation..."
if command_exists java; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
    print_success "Java found: $JAVA_VERSION"
else
    print_error "Java is not installed. Please install Java 8 or higher."
    exit 1
fi

# Check Maestro
print_step "Checking Maestro installation..."
if command_exists maestro; then
    MAESTRO_VERSION=$(maestro --version 2>/dev/null || echo "unknown")
    print_success "Maestro found: $MAESTRO_VERSION"
else
    print_warning "Maestro is not installed. Installing now..."
    
    if [[ "$OS" == "macos" ]]; then
        # Install Maestro on macOS
        curl -Ls "https://get.maestro.mobile.dev" | bash
        export PATH="$PATH":"$HOME/.maestro/bin"
        print_success "Maestro installed successfully"
    else
        print_error "Please install Maestro manually: https://docs.maestro.dev/getting-started/installing-maestro"
        exit 1
    fi
fi

# Check Android setup
print_step "Checking Android setup..."
if command_exists adb; then
    print_success "ADB found"
    
    # Check for connected devices
    DEVICES=$(adb devices | grep -v "List of devices" | grep -v "^$" | wc -l)
    if [[ $DEVICES -gt 0 ]]; then
        print_success "Found $DEVICES connected Android device(s)"
        adb devices | grep -v "List of devices" | grep -v "^$" | while read line; do
            if [[ -n "$line" ]]; then
                print_status "  $line"
            fi
        done
    else
        print_warning "No Android devices connected. Please connect a device or start an emulator."
        print_status "You can start a device with: ./run-tests.sh --start-device android"
    fi
else
    print_warning "ADB not found. Please install Android SDK and add it to PATH."
fi

# Check iOS setup (macOS only)
if [[ "$OS" == "macos" ]]; then
    print_step "Checking iOS setup..."
    if command_exists xcrun; then
        print_success "Xcode command line tools found"
        
        # Check for iOS simulators
        if command_exists xcrun simctl; then
            SIMULATORS=$(xcrun simctl list devices | grep "Booted" | wc -l)
            if [[ $SIMULATORS -gt 0 ]]; then
                print_success "Found $SIMULATORS running iOS simulator(s)"
                xcrun simctl list devices | grep "Booted" | while read line; do
                    print_status "  $line"
                done
            else
                print_warning "No iOS simulators running. You can start one with: ./run-tests.sh --start-device ios"
            fi
        fi
    else
        print_warning "Xcode command line tools not found. Please install Xcode."
    fi
fi

# Create comprehensive directory structure
print_step "Creating comprehensive directory structure..."
mkdir -p reports
mkdir -p reports/screenshots
mkdir -p reports/recordings
mkdir -p reports/logs
mkdir -p reports/step-logs
mkdir -p reports/ai-analysis
mkdir -p reports/performance
mkdir -p flows/smoke
mkdir -p flows/regression
mkdir -p flows/feature
mkdir -p flows/integration
mkdir -p apps/android
mkdir -p apps/ios
print_success "Directory structure created"

print_status "Reports directory structure:"
print_status "  📁 reports/"
print_status "  📸 reports/screenshots/"
print_status "  🎥 reports/recordings/"
print_status "  📝 reports/logs/"
print_status "  🔍 reports/step-logs/"
print_status "  🤖 reports/ai-analysis/"
print_status "  ⚡ reports/performance/"

print_status "Test flows structure:"
print_status "  🧪 flows/smoke/"
print_status "  🔄 flows/regression/"
print_status "  ⚙️ flows/feature/"
print_status "  🔗 flows/integration/"

# Check if app files exist
print_step "Checking app files..."
if [[ -f "apps/android/app-release.apk" ]]; then
    print_success "Android APK found"
else
    print_warning "Android APK not found at apps/android/app-release.apk"
    print_status "Please add your Android APK to apps/android/app-release.apk"
fi

if [[ -d "apps/ios/MyApp.app" ]]; then
    print_success "iOS app found"
else
    print_warning "iOS app not found at apps/ios/MyApp.app"
    print_status "Please add your iOS app to apps/ios/MyApp.app"
fi

# Verify test flows exist
print_step "Checking test flows..."
if [[ -f "flows/smoke/app-launch.yaml" ]]; then
    print_success "Smoke test flow found"
else
    print_warning "Smoke test flow not found"
fi

if [[ -f "flows/regression/guest-user-journey.yaml" ]]; then
    print_success "Regression test flow found"
else
    print_warning "Regression test flow not found"
fi

echo ""
print_success "Setup completed successfully!"
echo ""
print_status "Next steps:"
print_status "1. Add your app files to the apps/ directory"
print_status "2. Start a device: ./run-tests.sh --start-device android"
print_status "3. Run tests: ./run-tests.sh -t smoke"
echo ""
print_status "Available commands:"
print_status "  ./run-tests.sh --help                    # Show all options"
print_status "  ./run-tests.sh --list-devices           # List available devices"
print_status "  ./run-tests.sh -t smoke                 # Run smoke tests"
print_status "  ./run-tests.sh -p android -t regression # Run regression on Android"
print_status "  ./run-tests.sh --analyze                # Run with AI analysis"
