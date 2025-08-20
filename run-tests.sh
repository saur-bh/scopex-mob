#!/bin/bash

# ScopeX Unified Mobile Test Runner
# Consolidated script for running Maestro tests on both Android and iOS
# Features: Automatic emulator management, app installation, and cleanup

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
AUTO_EMULATOR=true
CLEANUP_EMULATOR=true

# Emulator management variables
EMULATOR_NAME=""
EMULATOR_PID=""
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Function to print colored output
print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║              ScopeX Unified Mobile Test Runner v2.0                  ║${NC}"
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
    echo "ScopeX Unified Mobile Test Runner - Enhanced with Emulator Management"
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Platform Options:"
    echo "  -p, --platform PLATFORM    Platform to test (android|ios|both) [default: android]"
    echo "  -d, --device DEVICE        Specific device/emulator to use"
    echo "  --no-auto-emulator         Disable automatic emulator creation"
    echo "  --no-cleanup               Keep emulator after test completion"
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
    echo "  $0                                    # Run Android with auto emulator"
    echo "  $0 -p ios                             # Run iOS with auto simulator"
    echo "  $0 -p both --parallel                 # Run both platforms in parallel"
    echo "  $0 -f auth-flow.yaml -p android       # Run specific flow on Android"
    echo "  $0 --no-auto-emulator -d \"Pixel_7\"   # Use existing emulator"
    echo "  $0 --no-cleanup                       # Keep emulator after test"
    echo ""
    echo "Emulator Management:"
    echo "  ✅ Automatic emulator creation with timestamp"
    echo "  ✅ Automatic app installation"
    echo "  ✅ Automatic cleanup after tests"
    echo "  ✅ Cross-platform compatibility"
}

# Function to check if Maestro is installed
check_maestro() {
    print_step "Checking Maestro installation..."
    
    if ! command -v maestro &> /dev/null; then
        print_error "Maestro is not installed. Please install it first:"
        echo "  curl -Ls \"https://get.maestro.mobile.dev\" | bash"
        exit 1
    fi
    
    # Get Maestro version with timeout protection
    local temp_file=$(mktemp)
    (maestro --version > "$temp_file" 2>/dev/null) &
    local pid=$!
    
    # Wait for up to 2 seconds
    local count=0
    while [[ $count -lt 20 ]] && kill -0 $pid 2>/dev/null; do
        sleep 0.1
        count=$((count + 1))
    done
    
    if kill -0 $pid 2>/dev/null; then
        kill $pid 2>/dev/null
        print_success "Maestro is installed (version check skipped)"
    else
        if [[ -s "$temp_file" ]]; then
            local version=$(cat "$temp_file" | tr -d '\n\r')
            print_success "Maestro is installed: $version"
        else
            print_success "Maestro is installed (version unknown)"
        fi
    fi
    
    rm -f "$temp_file"
}

# Function to create Android emulator
create_android_emulator() {
    print_step "Creating Android emulator..."
    
    if [[ -z "$ANDROID_HOME" ]]; then
        print_error "ANDROID_HOME not set"
        return 1
    fi
    
    # Create unique emulator name with timestamp
    EMULATOR_NAME="ScopeX_Test_${TIMESTAMP}"
    local system_image="system-images;android-34;google_apis;x86_64"
    
    print_status "Creating emulator: $EMULATOR_NAME"
    
    # Install system image if not available
    if [[ ! -d "$ANDROID_HOME/system-images/android-34/google_apis/x86_64" ]]; then
        print_status "Installing system image: $system_image"
        yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "$system_image"
    fi
    
    # Create AVD
    print_status "Creating AVD: $EMULATOR_NAME"
    echo "no" | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
        -n "$EMULATOR_NAME" \
        -k "$system_image" \
        -d "Nexus 5X"
    
    if [[ $? -eq 0 ]]; then
        print_success "Android emulator created: $EMULATOR_NAME"
        return 0
    else
        print_error "Failed to create Android emulator"
        return 1
    fi
}

# Function to start Android emulator
start_android_emulator() {
    print_step "Starting Android emulator..."
    
    if [[ -z "$EMULATOR_NAME" ]]; then
        print_error "No emulator name set"
        return 1
    fi
    
    print_status "Starting emulator: $EMULATOR_NAME"
    
    # Start emulator in background
    "$ANDROID_HOME/emulator/emulator" -avd "$EMULATOR_NAME" -no-snapshot-save &
    EMULATOR_PID=$!
    
    print_status "Emulator started with PID: $EMULATOR_PID"
    
    # Wait for emulator to boot
    print_status "Waiting for emulator to boot..."
    local count=0
    while [[ $count -lt 120 ]]; do
        if adb devices | grep -q "emulator.*device$"; then
            print_success "Android emulator is ready"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        print_status "Waiting... ($count seconds)"
    done
    
    print_error "Android emulator failed to boot within 120 seconds"
    return 1
}

# Function to create iOS simulator
create_ios_simulator() {
    print_step "Creating iOS simulator..."
    
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "iOS simulator creation requires macOS"
        return 1
    fi
    
    # Create unique simulator name with timestamp
    EMULATOR_NAME="ScopeX_Test_${TIMESTAMP}"
    
    print_status "Creating iOS simulator: $EMULATOR_NAME"
    
    # Create simulator
    local simulator_id=$(xcrun simctl create "$EMULATOR_NAME" "iPhone 15" "iOS17.5")
    
    if [[ -n "$simulator_id" ]]; then
        print_success "iOS simulator created: $EMULATOR_NAME (ID: $simulator_id)"
        return 0
    else
        print_error "Failed to create iOS simulator"
        return 1
    fi
}

# Function to start iOS simulator
start_ios_simulator() {
    print_step "Starting iOS simulator..."
    
    if [[ -z "$EMULATOR_NAME" ]]; then
        print_error "No simulator name set"
        return 1
    fi
    
    print_status "Starting simulator: $EMULATOR_NAME"
    
    # Boot simulator
    xcrun simctl boot "$EMULATOR_NAME"
    
    # Open Simulator app
    open -a Simulator
    
    # Wait for simulator to boot
    print_status "Waiting for simulator to boot..."
    local count=0
    while [[ $count -lt 60 ]]; do
        if xcrun simctl list devices | grep "$EMULATOR_NAME" | grep -q "Booted"; then
            print_success "iOS simulator is ready"
            return 0
        fi
        sleep 2
        count=$((count + 2))
        print_status "Waiting... ($count seconds)"
    done
    
    print_error "iOS simulator failed to boot within 60 seconds"
    return 1
}

# Function to setup platform environment
setup_platform() {
    local platform=$1
    
    print_step "Setting up $platform environment..."
    
    case $platform in
        "android")
            # Kill ADB server to ensure clean state
            if command -v adb &> /dev/null; then
                adb kill-server 2>/dev/null || true
                adb start-server
            fi
            
            # Create and start emulator if auto-emulator is enabled
            if [[ "$AUTO_EMULATOR" == true ]]; then
                if create_android_emulator; then
                    if start_android_emulator; then
                        print_success "Android environment ready"
                        return 0
                    else
                        print_error "Failed to start Android emulator"
                        return 1
                    fi
                else
                    print_error "Failed to create Android emulator"
                    return 1
                fi
            else
                # Check if device is available
                if adb devices | grep -q "device$"; then
                    print_success "Android device/emulator is available"
                    return 0
                else
                    print_error "No Android device/emulator found"
                    return 1
                fi
            fi
            ;;
            
        "ios")
            if [[ "$OSTYPE" != "darwin"* ]]; then
                print_error "iOS testing requires macOS"
                return 1
            fi
            
            # Kill ADB server to prevent interference
            if command -v adb &> /dev/null; then
                adb kill-server 2>/dev/null || true
            fi
            
            # Create and start simulator if auto-emulator is enabled
            if [[ "$AUTO_EMULATOR" == true ]]; then
                if create_ios_simulator; then
                    if start_ios_simulator; then
                        print_success "iOS environment ready"
                        return 0
                    else
                        print_error "Failed to start iOS simulator"
                        return 1
                    fi
                else
                    print_error "Failed to create iOS simulator"
                    return 1
                fi
            else
                # Check if simulator is available
                if xcrun simctl list devices | grep -q "Booted"; then
                    print_success "iOS simulator is available"
                    return 0
                else
                    print_error "No iOS simulator found"
                    return 1
                fi
            fi
            ;;
    esac
}

# Function to install app on device
install_app() {
    local platform=$1
    
    print_step "Installing app on $platform..."
    
    case $platform in
        "android")
            if [ -f "apps/android/app-release.apk" ]; then
                print_status "Installing Android APK..."
                adb install -r apps/android/app-release.apk
                print_success "Android app installed"
            else
                print_error "Android APK not found at apps/android/app-release.apk"
                return 1
            fi
            ;;
            
        "ios")
            if [ -d "apps/ios/MyApp.app" ]; then
                print_status "Installing iOS app..."
                if [[ -n "$EMULATOR_NAME" ]]; then
                    xcrun simctl install "$EMULATOR_NAME" apps/ios/MyApp.app
                else
                    xcrun simctl install booted apps/ios/MyApp.app
                fi
                print_success "iOS app installed"
            else
                print_error "iOS app bundle not found at apps/ios/MyApp.app"
                return 1
            fi
            ;;
    esac
}

# Function to run test flow
run_flow() {
    local platform=$1
    local flow_file=$2
    
    print_step "Running $flow_file on $platform..."
    
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
    
    # Add recording option
    if [ "$RECORD" = true ]; then
        maestro_cmd="$maestro_cmd --record"
        print_status "Video recording enabled"
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
        return 1
    fi
}

# Function to run tests on both platforms
run_both_platforms() {
    local flow_file=$1
    
    if [ "$PARALLEL" = true ]; then
        print_status "Running tests on both platforms in parallel..."
        
        # Setup both platforms
        setup_platform "android" &
        local android_setup_pid=$!
        
        setup_platform "ios" &
        local ios_setup_pid=$!
        
        # Wait for both setups to complete
        wait $android_setup_pid
        local android_setup_result=$?
        
        wait $ios_setup_pid
        local ios_setup_result=$?
        
        if [[ $android_setup_result -eq 0 ]] && [[ $ios_setup_result -eq 0 ]]; then
            # Install apps
            install_app "android" &
            local android_install_pid=$!
            
            install_app "ios" &
            local ios_install_pid=$!
            
            wait $android_install_pid
            local android_install_result=$?
            
            wait $ios_install_pid
            local ios_install_result=$?
            
            if [[ $android_install_result -eq 0 ]] && [[ $ios_install_result -eq 0 ]]; then
                # Run tests
                run_flow "android" "$flow_file" &
                local android_pid=$!
                
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
                    return 1
                fi
            else
                print_error "App installation failed"
                return 1
            fi
        else
            print_error "Platform setup failed"
            return 1
        fi
    else
        print_status "Running tests on both platforms sequentially..."
        
        # Setup and run Android
        if setup_platform "android" && install_app "android"; then
            run_flow "android" "$flow_file"
        else
            print_error "Android setup failed"
            return 1
        fi
        
        # Setup and run iOS
        if setup_platform "ios" && install_app "ios"; then
            run_flow "ios" "$flow_file"
        else
            print_error "iOS setup failed"
            return 1
        fi
    fi
}

# Function to cleanup emulator
cleanup_emulator() {
    if [[ "$CLEANUP_EMULATOR" == true ]] && [[ -n "$EMULATOR_NAME" ]]; then
        print_step "Cleaning up emulator: $EMULATOR_NAME"
        
        case $PLATFORM in
            "android")
                # Kill emulator process
                if [[ -n "$EMULATOR_PID" ]] && kill -0 "$EMULATOR_PID" 2>/dev/null; then
                    print_status "Stopping Android emulator..."
                    kill "$EMULATOR_PID"
                    sleep 2
                fi
                
                # Delete AVD
                print_status "Deleting Android AVD: $EMULATOR_NAME"
                "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" delete avd -n "$EMULATOR_NAME" 2>/dev/null || true
                ;;
                
            "ios")
                # Shutdown simulator
                print_status "Shutting down iOS simulator: $EMULATOR_NAME"
                xcrun simctl shutdown "$EMULATOR_NAME" 2>/dev/null || true
                
                # Delete simulator
                print_status "Deleting iOS simulator: $EMULATOR_NAME"
                xcrun simctl delete "$EMULATOR_NAME" 2>/dev/null || true
                ;;
        esac
        
        print_success "Emulator cleanup completed"
    fi
}

# Function to run continuous mode
run_continuous_mode() {
    print_status "Running in continuous mode - watching for file changes..."
    print_status "Press Ctrl+C to stop"
    
    # Setup trap for cleanup
    trap cleanup_emulator EXIT
    
    while true; do
        print_status "Running test suite..."
        case $PLATFORM in
            "android")
                if setup_platform "android" && install_app "android"; then
                    run_flow "android" "$FLOW"
                fi
                ;;
            "ios")
                if setup_platform "ios" && install_app "ios"; then
                    run_flow "ios" "$FLOW"
                fi
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
        --no-auto-emulator)
            AUTO_EMULATOR=false
            shift
            ;;
        --no-cleanup)
            CLEANUP_EMULATOR=false
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
print_header

print_status "Platform: $PLATFORM"
print_status "Flow: $FLOW"
print_status "Output Format: $OUTPUT_FORMAT"
print_status "Auto Emulator: $AUTO_EMULATOR"
print_status "Cleanup Emulator: $CLEANUP_EMULATOR"

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

# Setup trap for cleanup
trap cleanup_emulator EXIT

# Run continuous mode if requested
if [ "$CONTINUOUS" = true ]; then
    run_continuous_mode
    exit 0
fi

# Run tests based on platform
case $PLATFORM in
    "android")
        if setup_platform "android" && install_app "android"; then
            run_flow "android" "$FLOW"
        else
            print_error "Android setup failed"
            exit 1
        fi
        ;;
    "ios")
        if setup_platform "ios" && install_app "ios"; then
            run_flow "ios" "$FLOW"
        else
            print_error "iOS setup failed"
            exit 1
        fi
        ;;
    "both")
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

if [ "$OUTPUT_FORMAT" = "HTML" ]; then
    print_status "HTML report generated - open in browser to view"
fi

print_status "For advanced features, see: https://docs.maestro.dev/advanced/"
