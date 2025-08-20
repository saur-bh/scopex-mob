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
    echo "  --analyze                    Enable AI analysis"
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
    echo "  $0 -p android -t smoke                       # Run smoke tests on Android"
    echo "  $0 -p ios -t regression --analyze           # Run regression with AI analysis"
    echo "  $0 --sequential --format junit              # Sequential tests with JUnit report"
    echo "  $0 -v --debug --timeout 300                 # Verbose debug with timeout"
    echo ""
    echo "Available test categories:"
    echo "  smoke/        - Quick smoke tests"
    echo "  regression/   - Comprehensive regression tests"
    echo "  feature/      - Feature-specific tests"
    echo "  integration/  - Integration tests"
    echo ""
    echo "Available tags:"
    echo "  smoke, regression, feature, integration, critical, guest, authentication"
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
    
    if ! mkdir -p "$base_dir/ai-analysis"; then
        print_error "Failed to create ai-analysis directory"
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
    print_status "  🤖 $base_dir/ai-analysis"
    print_status "  ⚡ $base_dir/performance"
}

# Function to organize test outputs
organize_test_outputs() {
    local output_dir="$1"
    
    # Ensure directories exist
    mkdir -p "$output_dir/screenshots"
    mkdir -p "$output_dir/recordings"
    mkdir -p "$output_dir/ai-analysis"
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
    
    # Move AI analysis files from root directory and output directory
    for file in *insights*.html "$output_dir"/*insights*.html; do
        if [[ -f "$file" ]]; then
            mv "$file" "$output_dir/ai-analysis/"
            print_success "AI analysis moved: $(basename "$file")"
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

# Function to run tests with advanced features
run_tests() {
    local platform="$1"
    local device="$2"
    local output_dir="$3"
    local tags="$4"
    local exclude_tags="$5"
    local format="$6"
    local analyze="$7"
    local sequential="$8"
    local verbose="$9"
    local timeout="${10}"
    local retry="${11}"
    local parallel="${12}"
    local flow_files=("${@:13}")
    
    # Set output directory
    if [[ -z "$output_dir" ]]; then
        output_dir="reports/test-run-$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create reports directory structure
    create_reports_structure "$output_dir"
    
    # Build maestro command
    local maestro_cmd="maestro test"
    
    # Add device if specified
    if [[ -n "$device" ]]; then
        maestro_cmd="$maestro_cmd --device '$device'"
    fi
    
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
    
    # Add AI analysis
    if [[ "$analyze" == true ]]; then
        maestro_cmd="$maestro_cmd --analyze"
        print_test "AI analysis enabled"
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
        # Run all flows if none specified
        if [[ -d "flows" ]]; then
            flow_files=($(find flows -name "*.yaml" | sort))
        else
            print_error "No flows directory found"
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
    
    # Show AI analysis location
    local ai_dir="$output_dir/ai-analysis"
    if [[ -d "$ai_dir" ]] && [[ "$(ls -A "$ai_dir" 2>/dev/null)" ]]; then
        print_success "AI Analysis: $ai_dir"
        for file in "$ai_dir"/*.html; do
            if [[ -f "$file" ]]; then
                print_status "AI Report: open '$file'"
            fi
        done
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
    local analyze=false
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
            --analyze)
                analyze=true
                shift
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
    
    # List devices if requested
    if [[ -z "$device" ]]; then
        list_devices
        echo ""
    fi
    
    # Run tests
    run_tests "$platform" "$device" "$output_dir" "$tags" "$exclude_tags" "$format" "$analyze" "$sequential" "$verbose" "$timeout" "$retry" "$parallel" "${flow_files[@]}"
}

# Run main function
main "$@"
