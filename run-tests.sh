#!/bin/bash

# ScopeX Mobile Test Runner
# Unified script for running Maestro tests on both Android and iOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
PLATFORM="android"
FLOW="guest-user-flow.yaml"
VERBOSE=false
PARALLEL=false
DEBUG=false
CONTINUOUS=false
RECORD=false
DEVICE=""
OUTPUT_FORMAT="JUNIT"
TIMEOUT=""
TAGS=""
INCLUDE_TAGS=""
EXCLUDE_TAGS=""

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "ScopeX Mobile Test Runner - Enhanced with Maestro Features"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Platform Options:"
    echo "  -p, --platform PLATFORM    Platform to test (android|ios|both) [default: android]"
    echo "  -d, --device DEVICE        Specific device/emulator to use"
    echo ""
    echo "Test Options:"
    echo "  -f, --flow FLOW            Flow file to run [default: guest-user-flow.yaml]"
    echo "  -t, --timeout SECONDS      Test timeout in seconds"
    echo "  --include-tags TAGS        Run flows with specific tags (comma-separated)"
    echo "  --exclude-tags TAGS        Exclude flows with specific tags (comma-separated)"
    echo ""
    echo "Output Options:"
    echo "  --format FORMAT            Output format (junit|html|noop) [default: junit]"
    echo "  -v, --verbose              Enable verbose output"
    echo "  --debug                    Enable debug mode with detailed logs"
    echo ""
    echo "Execution Options:"
    echo "  --parallel                 Run tests in parallel (when using 'both' platform)"
    echo "  --continuous               Run in continuous mode (watch for changes)"
    echo "  --record                   Record test execution video"
    echo ""
    echo "Help:"
    echo "  -h, --help                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Run Android guest user flow"
    echo "  $0 -p ios                             # Run iOS guest user flow"
    echo "  $0 -p both --parallel                 # Run both platforms in parallel"
    echo "  $0 -f auth-flow.yaml -p android       # Run specific flow on Android"
    echo "  $0 -f guest-user-flow.yaml -p ios -v  # Run with verbose output"
    echo "  $0 --include-tags smoke,auth          # Run flows tagged with smoke or auth"
    echo "  $0 --debug --record                   # Debug mode with video recording"
    echo "  $0 --continuous                       # Watch mode - rerun on file changes"
    echo "  $0 -d \"iPhone 15\" -p ios              # Run on specific iOS device"
    echo ""
    echo "Maestro Documentation:"
    echo "  Commands: https://docs.maestro.dev/api-reference/commands"
    echo "  Advanced: https://docs.maestro.dev/advanced/"
}

# Function to check if Maestro is installed
check_maestro() {
    if ! command -v maestro &> /dev/null; then
        print_error "Maestro is not installed. Please install it first:"
        echo "  curl -Ls \"https://get.maestro.mobile.dev\" | bash"
        exit 1
    fi
    print_success "Maestro is installed: $(maestro --version)"
}

# Function to check platform-specific requirements
check_platform_requirements() {
    local platform=$1
    
    case $platform in
        "android")
            if ! command -v adb &> /dev/null; then
                print_error "ADB is not installed. Please install Android SDK."
                exit 1
            fi
            
            # Check if Android device/emulator is connected
            if ! adb devices | grep -q "device$"; then
                print_warning "No Android device/emulator found. Please start an emulator or connect a device."
                echo "  To start emulator: emulator -avd Pixel_7_API_34"
                exit 1
            fi
            print_success "Android device/emulator is connected"
            ;;
            
        "ios")
            if [[ "$OSTYPE" != "darwin"* ]]; then
                print_error "iOS testing requires macOS"
                exit 1
            fi
            
            if ! command -v xcrun &> /dev/null; then
                print_error "Xcode is not installed. Please install Xcode from App Store."
                exit 1
            fi
            
            # Check if iOS simulator is available
            if ! xcrun simctl list devices | grep -q "Booted"; then
                print_warning "No iOS simulator is running. Please start Simulator app."
                echo "  To start simulator: open -a Simulator"
                exit 1
            fi
            print_success "iOS simulator is available"
            ;;
    esac
}

# Function to install app on device
install_app() {
    local platform=$1
    
    case $platform in
        "android")
            if [ -f "apps/android/app-release.apk" ]; then
                print_status "Installing Android APK..."
                adb install -r apps/android/app-release.apk
                print_success "Android app installed"
            else
                print_error "Android APK not found at apps/android/app-release.apk"
                exit 1
            fi
            ;;
            
        "ios")
            if [ -d "apps/ios/MyApp.app" ]; then
                print_status "Installing iOS app..."
                xcrun simctl install booted apps/ios/MyApp.app
                print_success "iOS app installed"
            else
                print_error "iOS app bundle not found at apps/ios/MyApp.app"
                exit 1
            fi
            ;;
    esac
}

# Function to run test flow
run_flow() {
    local platform=$1
    local flow_file=$2
    
    print_status "Running $flow_file on $platform..."
    
    # Set platform-specific environment variables
    export PLATFORM=$platform
    
    case $platform in
        "android")
            export APP_ID="com.scopex.scopexmobilev2"
            ;;
        "ios")
            export APP_ID="com.scopex.scopexmobilev2"
            ;;
    esac
    
    # Build Maestro command with advanced options
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_file="reports/${platform}_${timestamp}"
    mkdir -p "reports"
    
    # Add file extension based on format
    case $OUTPUT_FORMAT in
        "JUNIT") output_file="${output_file}.xml" ;;
        "HTML") output_file="${output_file}.html" ;;
        "NOOP") output_file="${output_file}.txt" ;;
    esac
    
    local maestro_cmd="maestro test flows/$flow_file"
    
    # Add format option
    maestro_cmd="$maestro_cmd --format $OUTPUT_FORMAT"
    
    # Add output option
    maestro_cmd="$maestro_cmd --output $output_file"
    
    # Add device option if specified
    if [ -n "$DEVICE" ]; then
        maestro_cmd="$maestro_cmd --device \"$DEVICE\""
    fi
    
    # Add timeout option if specified
    if [ -n "$TIMEOUT" ]; then
        maestro_cmd="$maestro_cmd --timeout $TIMEOUT"
    fi
    
    # Add tag options if specified
    if [ -n "$INCLUDE_TAGS" ]; then
        maestro_cmd="$maestro_cmd --include-tags $INCLUDE_TAGS"
    fi
    
    if [ -n "$EXCLUDE_TAGS" ]; then
        maestro_cmd="$maestro_cmd --exclude-tags $EXCLUDE_TAGS"
    fi
    
    # Add debug options
    if [ "$DEBUG" = true ]; then
        maestro_cmd="$maestro_cmd --debug-output reports/debug_${platform}_${timestamp}"
    fi
    
    # Note: Maestro doesn't support --verbose flag, so we handle verbose output in our script
    
    # Add recording option
    if [ "$RECORD" = true ]; then
        maestro_cmd="$maestro_cmd --record"
    fi
    
    # Execute the command
    if [ "$VERBOSE" = true ]; then
        print_status "Executing: $maestro_cmd"
        print_status "Platform: $platform, Flow: $flow_file, Format: $OUTPUT_FORMAT"
    fi
    
    eval "$maestro_cmd"
    
    if [ $? -eq 0 ]; then
        print_success "Test completed successfully for $platform"
        print_status "Reports saved to: $output_file"
    else
        print_error "Test failed for $platform"
        exit 1
    fi
}

# Function to run tests on both platforms
run_both_platforms() {
    local flow_file=$1
    
    if [ "$PARALLEL" = true ]; then
        print_status "Running tests on both platforms in parallel..."
        
        # Run Android in background
        run_flow "android" "$flow_file" &
        local android_pid=$!
        
        # Run iOS in background
        run_flow "ios" "$flow_file" &
        local ios_pid=$!
        
        # Wait for both to complete
        wait $android_pid
        local android_result=$?
        
        wait $ios_pid
        local ios_result=$?
        
        if [ $android_result -eq 0 ] && [ $ios_result -eq 0 ]; then
            print_success "All tests completed successfully"
        else
            print_error "Some tests failed"
            exit 1
        fi
    else
        print_status "Running tests on both platforms sequentially..."
        
        run_flow "android" "$flow_file"
        run_flow "ios" "$flow_file"
    fi
}

# Function to run continuous mode
run_continuous_mode() {
    print_status "Running in continuous mode - watching for file changes..."
    print_status "Press Ctrl+C to stop"
    
    while true; do
        print_status "Running test suite..."
        case $PLATFORM in
            "android")
                run_flow "android" "$FLOW"
                ;;
            "ios")
                run_flow "ios" "$FLOW"
                ;;
            "both")
                run_both_platforms "$FLOW"
                ;;
        esac
        
        print_status "Waiting for file changes... (watching flows/ directory)"
        # Simple file watching - in production, consider using inotify or fswatch
        local initial_hash=$(find flows/ -name "*.yaml" -exec md5sum {} \; 2>/dev/null | md5sum)
        
        while true; do
            sleep 2
            local current_hash=$(find flows/ -name "*.yaml" -exec md5sum {} \; 2>/dev/null | md5sum)
            if [[ "$initial_hash" != "$current_hash" ]]; then
                print_status "File changes detected, rerunning tests..."
                break
            fi
        done
    done
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--platform)
            PLATFORM="$2"
            shift 2
            ;;
        -f|--flow)
            FLOW="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --format)
            OUTPUT_FORMAT=$(echo "$2" | tr '[:lower:]' '[:upper:]')
            shift 2
            ;;
        --include-tags)
            INCLUDE_TAGS="$2"
            shift 2
            ;;
        --exclude-tags)
            EXCLUDE_TAGS="$2"
            shift 2
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        --debug)
            DEBUG=true
            VERBOSE=true
            shift
            ;;
        --continuous)
            CONTINUOUS=true
            shift
            ;;
        --record)
            RECORD=true
            shift
            ;;
        --parallel)
            PARALLEL=true
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

# Validate platform
if [[ ! "$PLATFORM" =~ ^(android|ios|both)$ ]]; then
    print_error "Invalid platform: $PLATFORM. Use 'android', 'ios', or 'both'"
    exit 1
fi

# Validate output format
if [[ ! "$OUTPUT_FORMAT" =~ ^(JUNIT|HTML|NOOP)$ ]]; then
    print_error "Invalid output format: $OUTPUT_FORMAT. Use 'JUNIT', 'HTML', or 'NOOP'"
    exit 1
fi

# Validate flow file exists
if [ ! -f "flows/$FLOW" ]; then
    print_error "Flow file not found: flows/$FLOW"
    exit 1
fi

# Main execution
print_status "Starting ScopeX Mobile Test Runner (Enhanced)"
print_status "Platform: $PLATFORM"
print_status "Flow: $FLOW"
print_status "Output Format: $OUTPUT_FORMAT"

if [ -n "$DEVICE" ]; then
    print_status "Device: $DEVICE"
fi

if [ -n "$INCLUDE_TAGS" ]; then
    print_status "Include Tags: $INCLUDE_TAGS"
fi

if [ -n "$EXCLUDE_TAGS" ]; then
    print_status "Exclude Tags: $EXCLUDE_TAGS"
fi

# Check Maestro installation
check_maestro

# Create reports directory
mkdir -p reports

# Run continuous mode if requested
if [ "$CONTINUOUS" = true ]; then
    run_continuous_mode
    exit 0
fi

# Run tests based on platform
case $PLATFORM in
    "android")
        check_platform_requirements "android"
        install_app "android"
        run_flow "android" "$FLOW"
        ;;
    "ios")
        check_platform_requirements "ios"
        install_app "ios"
        run_flow "ios" "$FLOW"
        ;;
    "both")
        check_platform_requirements "android"
        check_platform_requirements "ios"
        install_app "android"
        install_app "ios"
        run_both_platforms "$FLOW"
        ;;
esac

print_success "Test execution completed! 🎉"

# Show additional information
if [ "$DEBUG" = true ]; then
    print_status "Debug logs available in reports/debug_* directories"
fi

if [ "$RECORD" = true ]; then
    print_status "Test recordings available in reports/ directory"
fi

print_status "For advanced features, see: https://docs.maestro.dev/advanced/"