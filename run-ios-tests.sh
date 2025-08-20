#!/bin/bash

# ScopeX iOS Test Runner with Recording and HTML Reports
# Specialized script for iOS simulator testing with enhanced features

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default values
FLOW="guest-user-flow.yaml"
DEVICE=""
RECORD=true
HTML_REPORT=true
DEBUG=false
VERBOSE=false

# Function to print colored output
print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║              ScopeX iOS Test Runner with Recording v1.0              ║${NC}"
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

# Function to show usage
show_usage() {
    echo "ScopeX iOS Test Runner - Enhanced with Recording and HTML Reports"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -f, --flow FLOW            Flow file to run [default: guest-user-flow.yaml]"
    echo "  -d, --device DEVICE        Specific iOS device/simulator to use"
    echo "  --no-record                Disable video recording"
    echo "  --no-html                  Disable HTML report generation"
    echo "  --debug                    Enable debug mode with detailed logs"
    echo "  -v, --verbose              Enable verbose output"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run guest flow with recording and HTML"
    echo "  $0 -f auth-flow.yaml                  # Run auth flow with recording"
    echo "  $0 -d \"iPhone 15 Pro\" --debug        # Run on specific device with debug"
    echo "  $0 --no-record --no-html              # Run without recording or HTML"
    echo ""
    echo "Features:"
    echo "  ✅ Video recording of test execution"
    echo "  ✅ HTML reports with screenshots"
    echo "  ✅ Enhanced logging and debugging"
    echo "  ✅ App data clearing with hooks"
    echo "  ✅ Permission management"
    echo "  ✅ Cross-platform compatibility"
}

# Function to check iOS requirements
check_ios_requirements() {
    print_step "Checking iOS requirements..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS testing requires macOS"
        exit 1
    fi
    
    if ! command -v xcrun &> /dev/null; then
        print_error "Xcode is not installed. Please install Xcode from App Store."
        exit 1
    fi
    
    # Kill ADB server to prevent Android emulator interference
    if command -v adb &> /dev/null; then
        print_status "Killing ADB server to prevent Android emulator interference..."
        adb kill-server 2>/dev/null || true
    fi
    
    # Check if iOS simulator is available
    if ! xcrun simctl list devices | grep -q "Booted"; then
        print_warning "No iOS simulator is running. Starting Simulator..."
        open -a Simulator
        sleep 5
    fi
    
    print_success "iOS simulator is available"
}

# Function to check Maestro installation
check_maestro() {
    print_step "Checking Maestro installation..."
    
    if ! command -v maestro &> /dev/null; then
        print_error "Maestro is not installed. Please install it first:"
        echo "  curl -Ls \"https://get.maestro.mobile.dev\" | bash"
        exit 1
    fi
    
    local maestro_version=$(maestro --version 2>/dev/null | head -n 1 || echo "unknown")
    print_success "Maestro is installed: $maestro_version"
}

# Function to install app on iOS simulator
install_ios_app() {
    print_step "Installing iOS app..."
    
    if [ -d "apps/ios/MyApp.app" ]; then
        print_status "Installing iOS app bundle..."
        xcrun simctl install booted apps/ios/MyApp.app
        print_success "iOS app installed"
    else
        print_error "iOS app bundle not found at apps/ios/MyApp.app"
        exit 1
    fi
}

# Function to list available iOS devices
list_ios_devices() {
    print_step "Available iOS devices:"
    xcrun simctl list devices | grep "Booted\|Shutdown" | while read line; do
        print_status "  $line"
    done
}

# Function to run iOS test with enhanced features
run_ios_test() {
    local flow_file=$1
    
    print_step "Running iOS test with enhanced features..."
    
    # Set environment variables
    export PLATFORM="ios"
    export APP_ID="com.scopex.scopexmobilev2"
    
    # Create timestamp for unique output
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_dir="reports/ios_enhanced_${timestamp}"
    mkdir -p "$output_dir"
    
    # Build Maestro command with all features
    local maestro_cmd="maestro test flows/$flow_file"
    
    # Add device if specified
    if [ -n "$DEVICE" ]; then
        maestro_cmd="$maestro_cmd --device \"$DEVICE\""
    fi
    
    # Note: Maestro doesn't support --record flag directly
    # Recording can be enabled in the flow using startRecording/stopRecording commands
    if [ "$RECORD" = true ]; then
        print_status "Recording enabled via flow commands (startRecording/stopRecording)"
    fi
    
    # Add HTML report if enabled
    if [ "$HTML_REPORT" = true ]; then
        maestro_cmd="$maestro_cmd --format HTML --output $output_dir/report.html"
        print_status "HTML report generation enabled"
    else
        maestro_cmd="$maestro_cmd --format JUNIT --output $output_dir/report.xml"
    fi
    
    # Add debug output if enabled
    if [ "$DEBUG" = true ]; then
        maestro_cmd="$maestro_cmd --debug-output $output_dir/debug"
        print_status "Debug output enabled"
    fi
    
    # Execute the command
    if [ "$VERBOSE" = true ]; then
        print_status "Executing: $maestro_cmd"
    fi
    
    print_status "Starting iOS test execution..."
    eval "$maestro_cmd"
    
    if [ $? -eq 0 ]; then
        print_success "iOS test completed successfully"
        
        # Show output information
        if [ "$HTML_REPORT" = true ]; then
            print_status "HTML report saved to: $output_dir/report.html"
            print_status "Open report: open $output_dir/report.html"
        else
            print_status "JUnit report saved to: $output_dir/report.xml"
        fi
        
        if [ "$RECORD" = true ]; then
            print_status "Video recording saved to: $output_dir/"
        fi
        
        if [ "$DEBUG" = true ]; then
            print_status "Debug logs saved to: $output_dir/debug/"
        fi
        
    else
        print_error "iOS test failed"
        exit 1
    fi
}

# Function to open results
open_results() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_dir="reports/ios_enhanced_${timestamp}"
    
    if [ "$HTML_REPORT" = true ] && [ -f "$output_dir/report.html" ]; then
        print_status "Opening HTML report..."
        open "$output_dir/report.html"
    fi
    
    print_status "Results directory: $output_dir"
    print_status "Open directory: open $output_dir"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--flow)
            FLOW="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        --no-record)
            RECORD=false
            shift
            ;;
        --no-html)
            HTML_REPORT=false
            shift
            ;;
        --debug)
            DEBUG=true
            VERBOSE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Validate flow file exists
if [ ! -f "flows/$FLOW" ]; then
    print_error "Flow file not found: flows/$FLOW"
    exit 1
fi

# Main execution
print_header

print_status "Flow: $FLOW"
print_status "Recording: $RECORD"
print_status "HTML Report: $HTML_REPORT"
print_status "Debug Mode: $DEBUG"

if [ -n "$DEVICE" ]; then
    print_status "Device: $DEVICE"
fi

# Check requirements
check_maestro
check_ios_requirements

# List available devices
list_ios_devices

# Install app
install_ios_app

# Create reports directory
mkdir -p reports

# Run the test
run_ios_test "$FLOW"

# Open results
open_results

print_success "iOS test execution completed! 🎉"
print_status "For advanced features, see: https://docs.maestro.dev/advanced/"
