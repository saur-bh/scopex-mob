#!/bin/bash

# Comprehensive ScopeX Mobile Test Runner
# Advanced Maestro framework with all features

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
    echo -e "${PURPLE}║            Comprehensive ScopeX Mobile Test Runner v2.0              ║${NC}"
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

print_test() {
    echo -e "${PURPLE}[TEST]${NC} $1"
}

print_device() {
    echo -e "${GREEN}[DEVICE]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Comprehensive ScopeX Mobile Test Runner - Advanced Maestro Framework"
    echo "Usage: $0 [OPTIONS] [FLOW_FILES...]"
    echo ""
    echo "Device Management:"
    echo "  --start-device <platform>    Start device (android/ios)"
    echo "  --list-devices              List available devices"
    echo "  --device <device-id>        Use specific device"
    echo ""
    echo "Test Execution:"
    echo "  -p, --platform <platform>    Platform to test (android, ios, both)"
    echo "  -t, --tags <tags>            Run flows with specific tags"
    echo "  -e, --exclude <tags>         Exclude flows with specific tags"
    echo "  -f, --format <format>        Report format (html, junit)"
    echo "  -o, --output <directory>     Output directory for reports"
    echo "  --sequential                 Run tests in sequential order"
    echo ""
    echo "Advanced Options:"
    echo "  -v, --verbose                Enable verbose output"
    echo "  --debug                      Enable debug mode"
    echo "  --timeout <seconds>          Set test timeout"
    echo "  --retry <count>              Retry failed tests"
    echo "  --parallel                   Run tests in parallel"
    echo ""
    echo "Examples:"
    echo "  $0 --start-device android                    # Start Android device"
    echo "  $0 -p android -t \"guest,clear-state\"        # Auto device + app install + run tests"
    echo "  $0 -p ios -t regression                     # Auto device + app install + run tests"
    echo "  $0 flows/feature/wallet-flow.yaml           # Auto platform selection + device + app + run"
    echo "  $0 --sequential --format junit              # Sequential tests with JUnit report"
    echo "  $0 -v --debug --timeout 300                 # Verbose debug with timeout"
    echo ""
    echo "Flow Organization:"
    echo "  All flows are now in flows/feature/ directory"
    echo "  Clear state flows: app-launch-clear-state.yaml, guest-user-journey-clear-state.yaml, signup-flow-clear-state.yaml"
    echo "  No clear state flows: app-launch-no-clear-state.yaml, send-money-flow.yaml, wallet-flow.yaml"
    echo ""
    echo "Auto Device Management:"
    echo "  Automatically starts device if not running"
    echo "  Automatically installs app if not installed"
    echo "  Platform selection prompt if not specified"
    echo ""
    echo "Flow Dependencies:"
    echo "  Regression tests automatically run signup flow first"
    echo "  Post-signup flows assume user is already authenticated"
    echo ""
    echo "Available tags:"
    echo "  feature, clear-state, post-signup, critical, guest, authentication"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to start device
start_device() {
    local platform="$1"
    print_device "Starting $platform device..."
    
    if maestro start-device --platform="$platform"; then
        print_success "$platform device started successfully"
        return 0
    else
        print_error "Failed to start $platform device"
        return 1
    fi
}

# Function to check if device is available
check_device_available() {
    local platform="$1"
    local device_id=""
    
    if [[ "$platform" == "android" ]]; then
        # Check for Android devices
        if command_exists adb; then
            device_id=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -n "$device_id" ]]; then
                echo "$device_id"
                return 0
            fi
        fi
    elif [[ "$platform" == "ios" ]]; then
        # Check for iOS simulators (macOS only)
        if [[ "$OSTYPE" == "darwin"* ]] && command_exists xcrun; then
            device_id=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            if [[ -n "$device_id" ]]; then
                echo "$device_id"
                return 0
            fi
        fi
    fi
    
    return 1
}

# Function to wait for device to be ready
wait_for_device_ready() {
    local platform="$1"
    local device_id="$2"
    local max_attempts=30
    local attempt=1
    
    print_device "Waiting for $platform device to be ready: $device_id"
    
    while [[ $attempt -le $max_attempts ]]; do
        if [[ "$platform" == "android" ]]; then
            if adb -s "$device_id" shell getprop sys.boot_completed 2>/dev/null | grep -q "1" 2>/dev/null; then
                print_success "$platform device is ready"
                return 0
            fi
        elif [[ "$platform" == "ios" ]]; then
            if xcrun simctl list devices 2>/dev/null | grep "$device_id" | grep -q "Booted" 2>/dev/null; then
                print_success "$platform device is ready"
                return 0
            fi
        fi
        
        print_device "Waiting for device to be ready... (attempt $attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    print_error "Device did not become ready within timeout"
    return 1
}

# Function to ensure device is running
ensure_device_running() {
    local platform="$1"
    local device_id=""
    
    print_device "Checking for available $platform device..."
    
    # First check if device is already available
    device_id=$(check_device_available "$platform")
    if [[ -n "$device_id" ]]; then
        print_success "Found existing $platform device: $device_id"
        # Wait for device to be ready
        if wait_for_device_ready "$platform" "$device_id"; then
            # Clean and return device ID
            device_id=$(echo "$device_id" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            echo "$device_id"
            return 0
        else
            print_error "Existing device is not ready"
            return 1
        fi
    fi
    
    # If no device found, start one
    print_device "No $platform device found. Starting new device..."
    if start_device "$platform"; then
        # Wait for device to fully start
        sleep 10
        
        # Check again for the device
        device_id=$(check_device_available "$platform")
        if [[ -n "$device_id" ]]; then
            print_success "Successfully started $platform device: $device_id"
            # Wait for device to be ready
            if wait_for_device_ready "$platform" "$device_id"; then
                # Clean and return device ID
                device_id=$(echo "$device_id" | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                echo "$device_id"
                return 0
            else
                print_error "Started device is not ready"
                return 1
            fi
        else
            print_error "Failed to detect started $platform device"
            return 1
        fi
    else
        print_error "Failed to start $platform device"
        return 1
    fi
}

# Function to check if app is installed
check_app_installed() {
    local platform="$1"
    local device_id="$2"
    local app_id="com.scopex.scopexmobilev2"
    
    if [[ "$platform" == "android" ]]; then
        if adb -s "$device_id" shell pm list packages | grep -q "$app_id"; then
            return 0
        fi
    elif [[ "$platform" == "ios" ]]; then
        if xcrun simctl listapps "$device_id" | grep -q "$app_id"; then
            return 0
        fi
    fi
    
    return 1
}

# Function to uninstall app
uninstall_app() {
    local platform="$1"
    local device_id="$2"
    local app_id="com.scopex.scopexmobilev2"
    
    print_device "Uninstalling app from $platform device: $device_id"
    
    if [[ "$platform" == "android" ]]; then
        if adb -s "$device_id" shell pm list packages | grep -q "$app_id"; then
            print_device "Found existing app, uninstalling..."
            if adb -s "$device_id" uninstall "$app_id" 2>/dev/null; then
                print_success "Android app uninstalled successfully"
            else
                print_warning "Failed to uninstall Android app (may not exist)"
            fi
        else
            print_device "Android app not found to uninstall"
        fi
    elif [[ "$platform" == "ios" ]]; then
        if xcrun simctl listapps "$device_id" | grep -q "$app_id"; then
            print_device "Found existing app, uninstalling..."
            if xcrun simctl uninstall "$device_id" "$app_id" 2>/dev/null; then
                print_success "iOS app uninstalled successfully"
            else
                print_warning "Failed to uninstall iOS app (may not exist)"
            fi
        else
            print_device "iOS app not found to uninstall"
        fi
    fi
    
    return 0
}

# Function to install app
install_app() {
    local platform="$1"
    local device_id="$2"
    
    print_device "Installing app on $platform device: $device_id"
    
    if [[ "$platform" == "android" ]]; then
        local apk_path="apps/android/app-release.apk"
        if [[ -f "$apk_path" ]]; then
            print_device "APK found at: $apk_path"
            
            # First uninstall if exists
            uninstall_app "$platform" "$device_id"
            
            # Wait a moment after uninstall
            sleep 2
            
            # Then install fresh
            print_device "Installing fresh APK..."
            if adb -s "$device_id" install "$apk_path" 2>&1; then
                print_success "Android app installed successfully"
                return 0
            else
                print_error "Failed to install Android app"
                print_device "Installation output: $(adb -s "$device_id" install "$apk_path" 2>&1)"
                return 1
            fi
        else
            print_error "Android APK not found at: $apk_path"
            return 1
        fi
    elif [[ "$platform" == "ios" ]]; then
        local app_path="apps/ios/MyApp.app"
        if [[ -d "$app_path" ]]; then
            print_device "iOS app found at: $app_path"
            
            # First uninstall if exists
            uninstall_app "$platform" "$device_id"
            
            # Wait a moment after uninstall
            sleep 2
            
            # Then install fresh
            print_device "Installing fresh iOS app..."
            if xcrun simctl install "$device_id" "$app_path" 2>&1; then
                print_success "iOS app installed successfully"
                return 0
            else
                print_error "Failed to install iOS app"
                print_device "Installation output: $(xcrun simctl install "$device_id" "$app_path" 2>&1)"
                return 1
            fi
        else
            print_error "iOS app not found at: $app_path"
            return 1
        fi
    fi
    
    return 1
}

# Function to verify app installation
verify_app_installation() {
    local platform="$1"
    local device_id="$2"
    local app_id="com.scopex.scopexmobilev2"
    
    print_device "Verifying app installation on $platform device..."
    
    if [[ "$platform" == "android" ]]; then
        if adb -s "$device_id" shell pm list packages | grep -q "$app_id"; then
            print_success "Android app verified as installed"
            return 0
        else
            print_error "Android app not found after installation"
            return 1
        fi
    elif [[ "$platform" == "ios" ]]; then
        if xcrun simctl listapps "$device_id" | grep -q "$app_id"; then
            print_success "iOS app verified as installed"
            return 0
        else
            print_error "iOS app not found after installation"
            return 1
        fi
    fi
    
    return 1
}

# Function to ensure app is installed
ensure_app_installed() {
    local platform="$1"
    local device_id="$2"
    
    print_device "Ensuring fresh app installation on $platform device..."
    
    # Always do fresh install (uninstall + install)
    if install_app "$platform" "$device_id"; then
        # Verify installation
        if verify_app_installation "$platform" "$device_id"; then
            print_success "Fresh app installation completed and verified successfully"
            return 0
        else
            print_error "App installation verification failed"
            return 1
        fi
    else
        print_error "Failed to install app"
        return 1
    fi
}

# Function to list devices
list_devices() {
    print_device "Available devices:"
    
    # Android devices
    if command_exists adb; then
        print_device "Android devices:"
        adb devices | grep -v "List of devices" | grep -v "^$" | while read line; do
            if [[ -n "$line" ]]; then
                echo "  $line"
            fi
        done
    fi
    
    # iOS devices (macOS only)
    if [[ "$OSTYPE" == "darwin"* ]] && command_exists xcrun; then
        print_device "iOS simulators:"
        xcrun simctl list devices | grep "Booted" | while read line; do
            echo "  $line"
        done
    fi
    
    # Maestro devices
    print_device "Maestro managed devices:"
    maestro device list 2>/dev/null || print_warning "Maestro device list not available"
}

# Function to create reports directory structure
create_reports_structure() {
    local base_dir="$1"
    
    # Create main directories with error checking
    if ! mkdir -p "$base_dir"; then
        print_error "Failed to create main directory: $base_dir"
        return 1
    fi
    
    if ! mkdir -p "$base_dir/screenshots"; then
        print_error "Failed to create screenshots directory"
        return 1
    fi
    
    if ! mkdir -p "$base_dir/recordings"; then
        print_error "Failed to create recordings directory"
        return 1
    fi
    
    if ! mkdir -p "$base_dir/logs"; then
        print_error "Failed to create logs directory"
        return 1
    fi
    
    if ! mkdir -p "$base_dir/step-logs"; then
        print_error "Failed to create step-logs directory"
        return 1
    fi
    

    
    if ! mkdir -p "$base_dir/performance"; then
        print_error "Failed to create performance directory"
        return 1
    fi
    
    print_status "Created comprehensive reports directory structure:"
    print_status "  📁 $base_dir"
    print_status "  📸 $base_dir/screenshots"
    print_status "  🎥 $base_dir/recordings"
    print_status "  📝 $base_dir/logs"
    print_status "  🔍 $base_dir/step-logs"

    print_status "  ⚡ $base_dir/performance"
}

# Function to organize test outputs
organize_test_outputs() {
    local output_dir="$1"
    
    # Ensure directories exist
    mkdir -p "$output_dir/screenshots"
    mkdir -p "$output_dir/recordings"

    mkdir -p "$output_dir/performance"
    
    # Move screenshots from root directory and output directory
    for file in *.png "$output_dir"/*.png; do
        if [[ -f "$file" ]]; then
            mv "$file" "$output_dir/screenshots/"
            print_success "Screenshot moved: $(basename "$file")"
        fi
    done
    
    # Move recordings from root directory and output directory
    for file in *.mp4 "$output_dir"/*.mp4; do
        if [[ -f "$file" ]]; then
            mv "$file" "$output_dir/recordings/"
            print_success "Recording moved: $(basename "$file")"
        fi
    done
    

    
    # Move performance logs from root directory and output directory
    for file in *performance*.json "$output_dir"/*performance*.json; do
        if [[ -f "$file" ]]; then
            mv "$file" "$output_dir/performance/"
            print_success "Performance log moved: $(basename "$file")"
        fi
    done
}

# Function to run signup flow first for regression tests
run_signup_first() {
    local platform="$1"
    local device="$2"
    local output_dir="$3"
    local format="$4"
    local verbose="$5"
    local timeout="$6"
    local retry="$7"
    
    print_test "Running signup flow first to ensure user authentication..."
    
    # Build maestro command for signup flow
    local signup_cmd="maestro test"
    
    # Add device if specified
    if [[ -n "$device" ]]; then
        signup_cmd="$signup_cmd --device '$device'"
    fi
    
    # Add output directory and format
    signup_cmd="$signup_cmd --output '$output_dir/signup-report.$format' --format $format"
    
    # Add signup flow specific tags
    signup_cmd="$signup_cmd --include-tags 'signup,clear-state'"
    

    
    # Add verbose if enabled
    if [[ "$verbose" == true ]]; then
        signup_cmd="$signup_cmd --verbose"
    fi
    
    # Add timeout if specified
    if [[ -n "$timeout" ]]; then
        signup_cmd="$signup_cmd --timeout $timeout"
    fi
    
    # Add retry if specified
    if [[ -n "$retry" ]]; then
        signup_cmd="$signup_cmd --retry $retry"
    fi
    
    # Add flows directory
    signup_cmd="$signup_cmd flows/feature/"
    
    print_step "Executing signup flow: $signup_cmd"
    
    # Execute signup flow
    if eval "$signup_cmd"; then
        print_success "Signup flow completed successfully"
    else
        print_error "Signup flow failed - continuing with other tests"
    fi
    
    # Wait a moment for app state to stabilize
    sleep 2
}

# Function to enhance HTML report with media links
enhance_html_report() {
    local output_dir="$1"
    local html_report="$output_dir/report.html"
    
    if [[ ! -f "$html_report" ]]; then
        return
    fi
    
    # Create a simple media links file instead of modifying HTML
    local media_links_file="$output_dir/media-links.html"
    
    cat > "$media_links_file" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Test Media Files</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
    <div class="container mt-4">
        <h1 class="mb-4">📸 Test Media Files</h1>
        
        <div class="row">
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>🎥 Recordings</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
EOF
    
    # Add recording links
    if [[ -d "$output_dir/recordings" ]]; then
        for recording in "$output_dir/recordings"/*.mp4; do
            if [[ -f "$recording" ]]; then
                local filename=$(basename "$recording")
                local test_name=$(echo "$filename" | sed 's/\.mp4$//' | sed 's/-/ /g' | sed 's/_/ /g')
                local file_size=$(ls -lh "$recording" | awk '{print $5}')
                echo "                            <li class='list-group-item'>
                                <a href='recordings/$filename' target='_blank' class='btn btn-primary btn-sm'>
                                    📹 $test_name
                                </a>
                                <small class='text-muted'>$file_size</small>
                            </li>" >> "$media_links_file"
            fi
        done
    fi
    
    cat >> "$media_links_file" << 'EOF'
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <div class="card">
                    <div class="card-header">
                        <h5>📸 Screenshots</h5>
                    </div>
                    <div class="card-body">
                        <ul class="list-group list-group-flush">
EOF
    
    # Add screenshot links
    if [[ -d "$output_dir/screenshots" ]]; then
        for screenshot in "$output_dir/screenshots"/*.png; do
            if [[ -f "$screenshot" ]]; then
                local filename=$(basename "$screenshot")
                local test_name=$(echo "$filename" | sed 's/\.png$//' | sed 's/-/ /g' | sed 's/_/ /g')
                local file_size=$(ls -lh "$screenshot" | awk '{print $5}')
                echo "                            <li class='list-group-item'>
                                <a href='screenshots/$filename' target='_blank' class='btn btn-info btn-sm'>
                                    🖼️ $test_name
                                </a>
                                <small class='text-muted'>$file_size</small>
                            </li>" >> "$media_links_file"
            fi
        done
    fi
    
    cat >> "$media_links_file" << 'EOF'
                        </ul>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="mt-4">
            <h5>📊 Quick Actions</h5>
            <a href="step-logs/test-execution.log" target="_blank" class="btn btn-secondary btn-sm me-2">
                📝 View Detailed Logs
            </a>
            <a href="report.html" target="_blank" class="btn btn-primary btn-sm me-2">
                📊 View Test Report
            </a>
            <a href="." class="btn btn-success btn-sm">
                📁 Open Reports Folder
            </a>
        </div>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js"></script>
</body>
</html>
EOF
    
    print_success "Created media links file: $media_links_file"
}

# Function to run tests with advanced features and flow dependencies
run_tests() {
    local platform="$1"
    local device="$2"
    local output_dir="$3"
    local tags="$4"
    local exclude_tags="$5"
    local format="$6"
    local sequential="$7"
    local verbose="$8"
    local timeout="$9"
    local retry="${10}"
    local parallel="${11}"
    local flow_files=("${@:12}")
    
    # Set output directory
    if [[ -z "$output_dir" ]]; then
        output_dir="reports/test-run-$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create reports directory structure
    create_reports_structure "$output_dir"
    
    # Handle flow dependencies for regression tests
    if [[ "$tags" == *"regression"* ]]; then
        print_test "Regression test detected - running signup flow first"
        run_signup_first "$platform" "$device" "$output_dir" "$format" "$verbose" "$timeout" "$retry"
    fi
    
    # Build maestro command
    local maestro_cmd="maestro test"
    
    # Note: Maestro doesn't support --device flag, it auto-detects devices
    # The device parameter is used for app installation only
    
    # Add output directory and format
    maestro_cmd="$maestro_cmd --output '$output_dir/report.$format' --format $format"
    
    # Note: Maestro doesn't support --test-output-dir flag directly
    # Output directory is handled by --output flag
    
    # Add tag filters
    if [[ -n "$tags" ]]; then
        maestro_cmd="$maestro_cmd --include-tags '$tags'"
        print_test "Running flows with tags: $tags"
    fi
    
    if [[ -n "$exclude_tags" ]]; then
        maestro_cmd="$maestro_cmd --exclude-tags '$exclude_tags'"
        print_test "Excluding flows with tags: $exclude_tags"
    fi
    

    
    # Add sequential execution
    if [[ "$sequential" == true ]]; then
        maestro_cmd="$maestro_cmd --sequential"
        print_test "Sequential execution enabled"
    fi
    
    # Add verbose output
    if [[ "$verbose" == true ]]; then
        maestro_cmd="$maestro_cmd --verbose"
        print_test "Verbose output enabled"
    fi
    
    # Add timeout
    if [[ -n "$timeout" ]]; then
        maestro_cmd="$maestro_cmd --timeout $timeout"
        print_test "Timeout set to: $timeout seconds"
    fi
    
    # Add flow files
    if [[ ${#flow_files[@]} -eq 0 ]]; then
        # Run all flows from feature directory if none specified
        if [[ -d "flows/feature" ]]; then
            flow_files=($(find flows/feature -name "*.yaml" | sort))
            print_test "Found $((${#flow_files[@]})) flows in flows/feature/ directory"
        else
            print_error "No flows/feature directory found"
            exit 1
        fi
    fi
    
    # Add flow files to command
    for flow in "${flow_files[@]}"; do
        if [[ -f "$flow" ]]; then
            maestro_cmd="$maestro_cmd '$flow'"
            print_test "Added flow: $flow"
        else
            print_warning "Flow file not found: $flow"
        fi
    done
    
    # Run the command
    print_step "Starting comprehensive test execution..."
    print_status "Command: $maestro_cmd"
    echo ""
    
    # Create step log file
    local step_log="$output_dir/step-logs/test-execution.log"
    echo "=== Comprehensive ScopeX Mobile Test Execution Log ===" > "$step_log"
    echo "Timestamp: $(date)" >> "$step_log"
    echo "Platform: $platform" >> "$step_log"
    echo "Device: $device" >> "$step_log"
    echo "Tags: $tags" >> "$step_log"
    echo "Exclude Tags: $exclude_tags" >> "$step_log"
    echo "Format: $format" >> "$step_log"
    echo "AI Analysis: $analyze" >> "$step_log"
    echo "Sequential: $sequential" >> "$step_log"
    echo "Timeout: $timeout" >> "$step_log"
    echo "=====================================================" >> "$step_log"
    echo "" >> "$step_log"
    
    # Execute with retry logic
    local max_retries=${retry:-1}
    local attempt=1
    
    while [[ $attempt -le $max_retries ]]; do
        if [[ $attempt -gt 1 ]]; then
            print_warning "Retry attempt $attempt of $max_retries"
        fi
        
        if eval "$maestro_cmd" 2>&1 | tee -a "$step_log"; then
            print_success "Tests completed successfully!"
            break
        else
            if [[ $attempt -eq $max_retries ]]; then
                print_error "Tests failed after $max_retries attempts"
                print_status "Check detailed logs at: $step_log"
                exit 1
            else
                print_warning "Test attempt $attempt failed, retrying..."
                attempt=$((attempt + 1))
                sleep 5
            fi
        fi
    done
    
    # Organize test outputs
    organize_test_outputs "$output_dir"
    
    # Enhance HTML report with media links
    enhance_html_report "$output_dir"
    
    # Show results
    print_status "Results saved to: $output_dir"
    
    # Show HTML report location
    local html_report="$output_dir/report.$format"
    if [[ -f "$html_report" ]]; then
        print_success "Report: $html_report"
        if [[ "$format" == "html" ]]; then
            print_status "Open in browser: open '$html_report'"
        fi
    fi
    
    # Show media links file location
    local media_links_file="$output_dir/media-links.html"
    if [[ -f "$media_links_file" ]]; then
        print_success "Media Links: $media_links_file"
        print_status "Open media files: open '$media_links_file'"
    fi
    

    
    # Show other directories
    local screenshots_dir="$output_dir/screenshots"
    if [[ -d "$screenshots_dir" ]] && [[ "$(ls -A "$screenshots_dir" 2>/dev/null)" ]]; then
        print_success "Screenshots: $screenshots_dir"
    fi
    
    local recordings_dir="$output_dir/recordings"
    if [[ -d "$recordings_dir" ]] && [[ "$(ls -A "$recordings_dir" 2>/dev/null)" ]]; then
        print_success "Recordings: $recordings_dir"
    fi
    
    local step_logs_dir="$output_dir/step-logs"
    if [[ -d "$step_logs_dir" ]] && [[ "$(ls -A "$step_logs_dir" 2>/dev/null)" ]]; then
        print_success "Step logs: $step_logs_dir"
    fi
    
    echo ""
    print_status "📊 Comprehensive test report available at: $output_dir"
    print_status "🔍 Detailed step execution log: $step_log"
}

# Main function
main() {
    local platform=""
    local device=""
    local output_dir=""
    local tags=""
    local exclude_tags=""
    local format="html"

    local sequential=false
    local verbose=false
    local timeout=""
    local retry="1"
    local parallel=false
    local start_device_platform=""
    local list_devices_flag=false
    local flow_files=()
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --start-device)
                start_device_platform="$2"
                shift 2
                ;;
            --list-devices)
                list_devices_flag=true
                shift
                ;;
            -p|--platform)
                platform="$2"
                shift 2
                ;;
            -d|--device)
                device="$2"
                shift 2
                ;;
            -o|--output)
                output_dir="$2"
                shift 2
                ;;
            -t|--tags)
                tags="$2"
                shift 2
                ;;
            -e|--exclude)
                exclude_tags="$2"
                shift 2
                ;;
            -f|--format)
                format="$2"
                shift 2
                ;;

            --sequential)
                sequential=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            --debug)
                verbose=true
                shift
                ;;
            --timeout)
                timeout="$2"
                shift 2
                ;;
            --retry)
                retry="$2"
                shift 2
                ;;
            --parallel)
                parallel=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                flow_files+=("$1")
                shift
                ;;
        esac
    done
    
    # Show header
    print_header
    
    # Handle device management commands
    if [[ -n "$start_device_platform" ]]; then
        start_device "$start_device_platform"
        exit 0
    fi
    
    if [[ "$list_devices_flag" == true ]]; then
        list_devices
        exit 0
    fi
    
    # Check if maestro is available
    if ! command_exists maestro; then
        print_error "Maestro is not installed or not in PATH"
        print_status "Install Maestro: https://docs.maestro.dev/getting-started/installing-maestro"
        exit 1
    fi
    
    # Handle platform-specific logic
    case "$platform" in
        android)
            print_step "Running Android tests only"
            if ! command_exists adb; then
                print_error "ADB not found. Please install Android SDK."
                exit 1
            fi
            ;;
        ios)
            if [[ "$OSTYPE" != "darwin"* ]]; then
                print_error "iOS testing is only supported on macOS"
                exit 1
            fi
            print_step "Running iOS tests only"
            ;;
        both)
            print_step "Running tests on both platforms"
            ;;
        "")
            print_status "No platform specified, will use default"
            ;;
        *)
            print_error "Invalid platform: $platform"
            print_status "Valid platforms: android, ios, both"
            exit 1
            ;;
    esac
    
    # Validate format
    case "$format" in
        html|junit)
            ;;
        *)
            print_error "Invalid format: $format"
            print_status "Valid formats: html, junit"
            exit 1
            ;;
    esac
    
    # Auto device management and app installation
    if [[ -n "$platform" ]] && [[ "$platform" != "both" ]]; then
        print_step "Auto device management for $platform platform"
        
        # Get or start device
        device=""
        if [[ "$platform" == "android" ]]; then
            # Check for existing Android device
            device=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [[ -n "$device" ]]; then
                print_success "Found existing Android device: $device"
            else
                print_device "No Android device found. Starting new device..."
                if maestro start-device --platform=android >/dev/null 2>&1; then
                    sleep 10
                    device=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if [[ -n "$device" ]]; then
                        print_success "Successfully started Android device: $device"
                    else
                        print_error "Failed to start Android device"
                        exit 1
                    fi
                else
                    print_error "Failed to start Android device"
                    exit 1
                fi
            fi
            
            # Wait for device to be ready
            print_device "Waiting for Android device to be ready..."
            local attempts=0
            while [[ $attempts -lt 30 ]]; do
                if adb -s "$device" shell getprop sys.boot_completed 2>/dev/null | grep -q "1" 2>/dev/null; then
                    print_success "Android device is ready"
                    break
                fi
                sleep 2
                ((attempts++))
            done
            
            if [[ $attempts -eq 30 ]]; then
                print_error "Android device did not become ready"
                exit 1
            fi
            
        elif [[ "$platform" == "ios" ]]; then
            # Check for existing iOS device
            device=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            if [[ -n "$device" ]]; then
                print_success "Found existing iOS device: $device"
            else
                print_device "No iOS device found. Starting new device..."
                if maestro start-device --platform=ios >/dev/null 2>&1; then
                    sleep 10
                    device=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                    if [[ -n "$device" ]]; then
                        print_success "Successfully started iOS device: $device"
                    else
                        print_error "Failed to start iOS device"
                        exit 1
                    fi
                else
                    print_error "Failed to start iOS device"
                    exit 1
                fi
            fi
        fi
        
        print_device "Using device: '$device'"
        
        # Install app
        if [[ "$platform" == "android" ]]; then
            local apk_path="apps/android/app-release.apk"
            if [[ -f "$apk_path" ]]; then
                print_device "Installing Android app on device: $device"
                
                # Uninstall if exists
                if adb -s "$device" shell pm list packages | grep -q "com.scopex.scopexmobilev2" 2>/dev/null; then
                    print_device "Uninstalling existing app..."
                    adb -s "$device" uninstall com.scopex.scopexmobilev2 >/dev/null 2>&1
                    sleep 2
                fi
                
                # Install fresh
                if adb -s "$device" install "$apk_path" >/dev/null 2>&1; then
                    print_success "Android app installed successfully"
                else
                    print_error "Failed to install Android app"
                    exit 1
                fi
            else
                print_error "Android APK not found at: $apk_path"
                exit 1
            fi
        elif [[ "$platform" == "ios" ]]; then
            local app_path="apps/ios/MyApp.app"
            if [[ -d "$app_path" ]]; then
                print_device "Installing iOS app on device: $device"
                
                # Uninstall if exists
                if xcrun simctl listapps "$device" | grep -q "com.scopex.scopexmobilev2" 2>/dev/null; then
                    print_device "Uninstalling existing app..."
                    xcrun simctl uninstall "$device" com.scopex.scopexmobilev2 >/dev/null 2>&1
                    sleep 2
                fi
                
                # Install fresh
                if xcrun simctl install "$device" "$app_path" >/dev/null 2>&1; then
                    print_success "iOS app installed successfully"
                else
                    print_error "Failed to install iOS app"
                    exit 1
                fi
            else
                print_error "iOS app not found at: $app_path"
                exit 1
            fi
        fi
        
        print_success "Device and app ready for testing on $platform"
    elif [[ "$platform" == "both" ]]; then
        print_step "Auto device management for both platforms"
        
        # Handle both platforms
        for p in "android" "ios"; do
            print_device "Setting up $p platform..."
            
            if [[ "$p" == "android" ]]; then
                # Get or start Android device
                local device_id=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                if [[ -n "$device_id" ]]; then
                    print_success "Found existing Android device: $device_id"
                else
                    print_device "No Android device found. Starting new device..."
                    if maestro start-device --platform=android >/dev/null 2>&1; then
                        sleep 10
                        device_id=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        if [[ -n "$device_id" ]]; then
                            print_success "Successfully started Android device: $device_id"
                        else
                            print_error "Failed to start Android device"
                            continue
                        fi
                    else
                        print_error "Failed to start Android device"
                        continue
                    fi
                fi
                
                # Wait for device to be ready
                print_device "Waiting for Android device to be ready..."
                local attempts=0
                while [[ $attempts -lt 30 ]]; do
                    if adb -s "$device_id" shell getprop sys.boot_completed 2>/dev/null | grep -q "1" 2>/dev/null; then
                        print_success "Android device is ready"
                        break
                    fi
                    sleep 2
                    ((attempts++))
                done
                
                if [[ $attempts -eq 30 ]]; then
                    print_error "Android device did not become ready"
                    continue
                fi
                
                # Install app
                local apk_path="apps/android/app-release.apk"
                if [[ -f "$apk_path" ]]; then
                    print_device "Installing Android app on device: $device_id"
                    
                    # Uninstall if exists
                    if adb -s "$device_id" shell pm list packages | grep -q "com.scopex.scopexmobilev2" 2>/dev/null; then
                        print_device "Uninstalling existing app..."
                        adb -s "$device_id" uninstall com.scopex.scopexmobilev2 >/dev/null 2>&1
                        sleep 2
                    fi
                    
                    # Install fresh
                    if adb -s "$device_id" install "$apk_path" >/dev/null 2>&1; then
                        print_success "Android app installed successfully"
                    else
                        print_error "Failed to install Android app"
                        continue
                    fi
                else
                    print_error "Android APK not found at: $apk_path"
                    continue
                fi
                
            elif [[ "$p" == "ios" ]]; then
                # Get or start iOS device
                local device_id=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                if [[ -n "$device_id" ]]; then
                    print_success "Found existing iOS device: $device_id"
                else
                    print_device "No iOS device found. Starting new device..."
                    if maestro start-device --platform=ios >/dev/null 2>&1; then
                        sleep 10
                        device_id=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        if [[ -n "$device_id" ]]; then
                            print_success "Successfully started iOS device: $device_id"
                        else
                            print_error "Failed to start iOS device"
                            continue
                        fi
                    else
                        print_error "Failed to start iOS device"
                        continue
                    fi
                fi
                
                # Install app
                local app_path="apps/ios/MyApp.app"
                if [[ -d "$app_path" ]]; then
                    print_device "Installing iOS app on device: $device_id"
                    
                    # Uninstall if exists
                    if xcrun simctl listapps "$device_id" | grep -q "com.scopex.scopexmobilev2" 2>/dev/null; then
                        print_device "Uninstalling existing app..."
                        xcrun simctl uninstall "$device_id" com.scopex.scopexmobilev2 >/dev/null 2>&1
                        sleep 2
                    fi
                    
                    # Install fresh
                    if xcrun simctl install "$device_id" "$app_path" >/dev/null 2>&1; then
                        print_success "iOS app installed successfully"
                    else
                        print_error "Failed to install iOS app"
                        continue
                    fi
                else
                    print_error "iOS app not found at: $app_path"
                    continue
                fi
            fi
            
            print_success "Device and app ready for testing on $p"
        done
    else
        # No platform specified - ask user to choose
        print_step "No platform specified. Please choose platform:"
        echo "1. Android"
        echo "2. iOS"
        echo "3. Both"
        read -p "Enter choice (1-3): " choice
        
        case "$choice" in
            1)
                platform="android"
                # Get or start Android device
                device=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                if [[ -n "$device" ]]; then
                    print_success "Found existing Android device: $device"
                else
                    print_device "No Android device found. Starting new device..."
                    if maestro start-device --platform=android >/dev/null 2>&1; then
                        sleep 10
                        device=$(adb devices 2>/dev/null | grep -v "List of devices" | grep -v "^$" | head -n 1 | cut -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        if [[ -n "$device" ]]; then
                            print_success "Successfully started Android device: $device"
                        else
                            print_error "Failed to start Android device"
                            exit 1
                        fi
                    else
                        print_error "Failed to start Android device"
                        exit 1
                    fi
                fi
                
                # Wait for device to be ready
                print_device "Waiting for Android device to be ready..."
                local attempts=0
                while [[ $attempts -lt 30 ]]; do
                    if adb -s "$device" shell getprop sys.boot_completed 2>/dev/null | grep -q "1" 2>/dev/null; then
                        print_success "Android device is ready"
                        break
                    fi
                    sleep 2
                    ((attempts++))
                done
                
                if [[ $attempts -eq 30 ]]; then
                    print_error "Android device did not become ready"
                    exit 1
                fi
                
                # Install app
                local apk_path="apps/android/app-release.apk"
                if [[ -f "$apk_path" ]]; then
                    print_device "Installing Android app on device: $device"
                    
                    # Uninstall if exists
                    if adb -s "$device" shell pm list packages | grep -q "com.scopex.scopexmobilev2" 2>/dev/null; then
                        print_device "Uninstalling existing app..."
                        adb -s "$device" uninstall com.scopex.scopexmobilev2 >/dev/null 2>&1
                        sleep 2
                    fi
                    
                    # Install fresh
                    if adb -s "$device" install "$apk_path" >/dev/null 2>&1; then
                        print_success "Android app installed successfully"
                    else
                        print_error "Failed to install Android app"
                        exit 1
                    fi
                else
                    print_error "Android APK not found at: $apk_path"
                    exit 1
                fi
                ;;
            2)
                platform="ios"
                # Get or start iOS device
                device=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                
                if [[ -n "$device" ]]; then
                    print_success "Found existing iOS device: $device"
                else
                    print_device "No iOS device found. Starting new device..."
                    if maestro start-device --platform=ios >/dev/null 2>&1; then
                        sleep 10
                        device=$(xcrun simctl list devices 2>/dev/null | grep "Booted" | head -n 1 | cut -d'(' -f2 | cut -d')' -f1 | tr -d '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                        if [[ -n "$device" ]]; then
                            print_success "Successfully started iOS device: $device"
                        else
                            print_error "Failed to start iOS device"
                            exit 1
                        fi
                    else
                        print_error "Failed to start iOS device"
                        exit 1
                    fi
                fi
                
                # Install app
                local app_path="apps/ios/MyApp.app"
                if [[ -d "$app_path" ]]; then
                    print_device "Installing iOS app on device: $device"
                    
                    # Uninstall if exists
                    if xcrun simctl listapps "$device" | grep -q "com.scopex.scopexmobilev2" 2>/dev/null; then
                        print_device "Uninstalling existing app..."
                        xcrun simctl uninstall "$device" com.scopex.scopexmobilev2 >/dev/null 2>&1
                        sleep 2
                    fi
                    
                    # Install fresh
                    if xcrun simctl install "$device" "$app_path" >/dev/null 2>&1; then
                        print_success "iOS app installed successfully"
                    else
                        print_error "Failed to install iOS app"
                        exit 1
                    fi
                else
                    print_error "iOS app not found at: $app_path"
                    exit 1
                fi
                ;;
            3)
                platform="both"
                print_error "Both platforms not supported in interactive mode"
                print_status "Please specify platform explicitly: -p android or -p ios"
                exit 1
                ;;
            *)
                print_error "Invalid choice"
                exit 1
                ;;
        esac
    fi
    
    # Run tests
    run_tests "$platform" "$device" "$output_dir" "$tags" "$exclude_tags" "$format" "$sequential" "$verbose" "$timeout" "$retry" "$parallel" "${flow_files[@]}"
}

# Run main function
main "$@"
