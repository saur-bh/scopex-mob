#!/bin/bash

# ScopeX Mobile Automation Setup Script
# Comprehensive setup and requirement checker for both Windows and macOS
# Based on Maestro documentation: https://docs.maestro.dev/

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_VERSION="1.0.0"
MAESTRO_MIN_VERSION="1.36.0"
JAVA_MIN_VERSION="8"
ANDROID_API_LEVEL="34"
IOS_MIN_VERSION="14.0"

# Global variables
NON_INTERACTIVE=false

# Function to print colored output
print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║               ScopeX Mobile Automation Setup v${SCRIPT_VERSION}               ║${NC}"
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
    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        echo "windows"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
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

# Function to show platform capabilities
show_platform_info() {
    local os=$(detect_os)
    
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        Platform Information                          ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    
    case $os in
        "windows")
            print_status "Operating System: Windows"
            print_warning "iOS testing is NOT supported on Windows"
            print_status "Supported platforms: Android only"
            print_status "Required tools: Java, Android SDK, ADB, Maestro"
            ;;
        "macos")
            print_status "Operating System: macOS"
            print_success "iOS and Android testing are BOTH supported"
            print_status "Supported platforms: Android + iOS"
            print_status "Required tools: Java, Android SDK, ADB, Xcode, iOS Simulator, Maestro"
            ;;
        "linux")
            print_status "Operating System: Linux"
            print_warning "iOS testing is NOT supported on Linux"
            print_status "Supported platforms: Android only"
            print_status "Required tools: Java, Android SDK, ADB, Maestro"
            ;;
        *)
            print_error "Unknown operating system: $OSTYPE"
            exit 1
            ;;
    esac
    echo ""
}

# Function to check Java installation
check_java() {
    print_step "Checking Java installation..."
    
    if command_exists java; then
        local java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1-2)
        if version_ge "$java_version" "$JAVA_MIN_VERSION"; then
            print_success "Java $java_version is installed"
            export JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
            return 0
        else
            print_error "Java version $java_version is too old. Minimum required: $JAVA_MIN_VERSION"
            return 1
        fi
    else
        print_error "Java is not installed"
        return 1
    fi
}

# Function to install Java
install_java() {
    local os=$(detect_os)
    
    print_step "Installing Java..."
    
    case $os in
        "macos")
            if command_exists brew; then
                brew install openjdk@17
                echo 'export PATH="/usr/local/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
                export PATH="/usr/local/opt/openjdk@17/bin:$PATH"
            else
                print_error "Homebrew is required to install Java on macOS"
                print_status "Install Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                return 1
            fi
            ;;
        "windows")
            print_status "Please download and install Java 17 from: https://adoptium.net/"
            print_status "Or use chocolatey: choco install openjdk17"
            return 1
            ;;
        "linux")
            print_status "Install Java using your package manager:"
            print_status "Ubuntu/Debian: sudo apt-get install openjdk-17-jdk"
            print_status "CentOS/RHEL: sudo yum install java-17-openjdk-devel"
            return 1
            ;;
    esac
}

# Function to check Android SDK
check_android_sdk() {
    print_step "Checking Android SDK..."
    
    if [[ -n "$ANDROID_HOME" ]] && [[ -d "$ANDROID_HOME" ]]; then
        print_success "Android SDK found at: $ANDROID_HOME"
        
        # Check ADB
        if command_exists adb; then
            print_success "ADB is available"
        else
            print_error "ADB not found in PATH"
            return 1
        fi
        
        # Check for required API level
        local platforms_dir="$ANDROID_HOME/platforms"
        if [[ -d "$platforms_dir/android-$ANDROID_API_LEVEL" ]]; then
            print_success "Android API level $ANDROID_API_LEVEL is installed"
        else
            print_warning "Android API level $ANDROID_API_LEVEL not found"
            print_status "Available platforms:"
            ls "$platforms_dir" 2>/dev/null | grep "android-" || print_status "No platforms found"
        fi
        
        return 0
    else
        print_error "Android SDK not found. ANDROID_HOME is not set or directory doesn't exist"
        return 1
    fi
}

# Function to install Android SDK
install_android_sdk() {
    local os=$(detect_os)
    
    print_step "Installing Android SDK..."
    
    case $os in
        "macos")
            if command_exists brew; then
                brew install --cask android-sdk
                echo 'export ANDROID_HOME="/usr/local/share/android-sdk"' >> ~/.zshrc
                echo 'export PATH="$ANDROID_HOME/platform-tools:$PATH"' >> ~/.zshrc
                export ANDROID_HOME="/usr/local/share/android-sdk"
                export PATH="$ANDROID_HOME/platform-tools:$PATH"
            else
                print_error "Homebrew is required to install Android SDK on macOS"
                return 1
            fi
            ;;
        "windows")
            print_status "Please download and install Android Studio from: https://developer.android.com/studio"
            print_status "Or use chocolatey: choco install androidstudio"
            return 1
            ;;
        "linux")
            print_status "Please download and install Android Studio from: https://developer.android.com/studio"
            print_status "Or install command line tools manually"
            return 1
            ;;
    esac
}

# Function to check iOS requirements (macOS only)
check_ios_requirements() {
    local os=$(detect_os)
    
    if [[ "$os" != "macos" ]]; then
        return 0  # Skip iOS checks on non-macOS
    fi
    
    print_step "Checking iOS requirements..."
    
    # Check Xcode
    if command_exists xcode-select && xcode-select -p >/dev/null 2>&1; then
        local xcode_path=$(xcode-select -p)
        print_success "Xcode is installed at: $xcode_path"
        
        # Check iOS Simulator
        if command_exists xcrun && xcrun simctl list devices >/dev/null 2>&1; then
            print_success "iOS Simulator is available"
            
            # List available iOS versions
            local ios_versions=$(xcrun simctl list runtimes | grep "iOS" | head -3)
            if [[ -n "$ios_versions" ]]; then
                print_success "Available iOS runtimes found"
                echo "$ios_versions" | while read line; do
                    print_status "  $line"
                done
            else
                print_warning "No iOS runtimes found"
            fi
        else
            print_error "iOS Simulator not available"
            return 1
        fi
    else
        print_error "Xcode is not installed or command line tools are missing"
        print_status "Install Xcode from App Store and run: xcode-select --install"
        return 1
    fi
    
    return 0
}

# Function to check Maestro installation
check_maestro() {
    print_step "Checking Maestro installation..."
    
    if command_exists maestro; then
        print_success "Maestro is installed"
        
        # Optional: Try to get version with timeout (non-blocking)
        local temp_file=$(mktemp)
        (maestro --version > "$temp_file" 2>/dev/null) &
        local pid=$!
        
        # Wait for up to 2 seconds
        local count=0
        while [[ $count -lt 20 ]] && kill -0 $pid 2>/dev/null; do
            sleep 0.1
            count=$((count + 1))
        done
        
        # Kill if still running
        if kill -0 $pid 2>/dev/null; then
            kill $pid 2>/dev/null
            print_status "Maestro version check skipped (timeout)"
        else
            # Read version from temp file
            if [[ -s "$temp_file" ]]; then
                local version=$(cat "$temp_file" | tr -d '\n\r')
                print_success "Maestro version: $version"
            fi
        fi
        
        # Clean up
        rm -f "$temp_file"
        return 0
    else
        print_error "Maestro is not installed"
        return 1
    fi
}

# Function to install Maestro
install_maestro() {
    print_step "Installing Maestro..."
    
    print_status "Downloading and installing Maestro..."
    if curl -Ls "https://get.maestro.mobile.dev" | bash; then
        print_success "Maestro installed successfully"
        
        # Add to PATH for current session
        export PATH="$HOME/.maestro/bin:$PATH"
        
        # Add to shell configuration
        local shell_config=""
        if [[ "$SHELL" == *"zsh"* ]]; then
            shell_config="$HOME/.zshrc"
        elif [[ "$SHELL" == *"bash"* ]]; then
            shell_config="$HOME/.bashrc"
        fi
        
        if [[ -n "$shell_config" ]]; then
            echo 'export PATH="$HOME/.maestro/bin:$PATH"' >> "$shell_config"
            print_status "Added Maestro to PATH in $shell_config"
        fi
        
        return 0
    else
        print_error "Failed to install Maestro"
        return 1
    fi
}

# Function to check device connectivity
check_devices() {
    local os=$(detect_os)
    
    print_step "Checking device connectivity..."
    
    # Check Android devices with timeout
    if command_exists adb; then
        print_status "Checking Android devices..."
        local adb_output=""
        local adb_pid=""
        
        # Run adb devices in background
        (adb devices > /tmp/adb_devices_output 2>/dev/null) &
        adb_pid=$!
        
        # Wait for up to 3 seconds
        local count=0
        while [[ $count -lt 30 ]] && kill -0 $adb_pid 2>/dev/null; do
            sleep 0.1
            count=$((count + 1))
        done
        
        # Kill if still running
        if kill -0 $adb_pid 2>/dev/null; then
            kill $adb_pid 2>/dev/null
            print_warning "ADB device check timed out"
        else
            # Read output
            if [[ -s /tmp/adb_devices_output ]]; then
                local android_devices=$(grep -v "List of devices" /tmp/adb_devices_output | grep "device$" | wc -l)
                if [[ $android_devices -gt 0 ]]; then
                    print_success "$android_devices Android device(s) connected"
                    grep "device$" /tmp/adb_devices_output | while read line; do
                        print_status "  Android: $line"
                    done
                else
                    print_warning "No Android devices connected"
                    print_status "Start an emulator or connect a physical device"
                fi
            else
                print_warning "ADB device check failed"
            fi
        fi
        
        # Clean up
        rm -f /tmp/adb_devices_output
    fi
    
    # Check iOS devices (macOS only) with timeout
    if [[ "$os" == "macos" ]] && command_exists xcrun; then
        print_status "Checking iOS simulators..."
        local ios_output=""
        local ios_pid=""
        
        # Run xcrun simctl list devices in background
        (xcrun simctl list devices > /tmp/ios_devices_output 2>/dev/null) &
        ios_pid=$!
        
        # Wait for up to 3 seconds
        local count=0
        while [[ $count -lt 30 ]] && kill -0 $ios_pid 2>/dev/null; do
            sleep 0.1
            count=$((count + 1))
        done
        
        # Kill if still running
        if kill -0 $ios_pid 2>/dev/null; then
            kill $ios_pid 2>/dev/null
            print_warning "iOS simulator check timed out"
        else
            # Read output
            if [[ -s /tmp/ios_devices_output ]]; then
                local ios_devices=$(grep "Booted" /tmp/ios_devices_output | wc -l)
                if [[ $ios_devices -gt 0 ]]; then
                    print_success "$ios_devices iOS simulator(s) running"
                    grep "Booted" /tmp/ios_devices_output | while read line; do
                        print_status "  iOS: $line"
                    done
                else
                    print_warning "No iOS simulators running"
                    print_status "Start iOS Simulator from Xcode or run: open -a Simulator"
                fi
            else
                print_warning "iOS simulator check failed"
            fi
        fi
        
        # Clean up
        rm -f /tmp/ios_devices_output
    fi
}

# Function to create Android emulator
create_android_emulator() {
    print_step "Creating Android emulator..."
    
    if [[ -z "$ANDROID_HOME" ]]; then
        print_error "ANDROID_HOME not set"
        return 1
    fi
    
    local avd_name="ScopeX_Test_API_$ANDROID_API_LEVEL"
    local system_image="system-images;android-$ANDROID_API_LEVEL;google_apis;x86_64"
    
    # Install system image
    print_status "Installing system image: $system_image"
    yes | "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" "$system_image"
    
    # Create AVD
    print_status "Creating AVD: $avd_name"
    echo "no" | "$ANDROID_HOME/cmdline-tools/latest/bin/avdmanager" create avd \
        -n "$avd_name" \
        -k "$system_image" \
        -d "Nexus 5X"
    
    if [[ $? -eq 0 ]]; then
        print_success "Android emulator created: $avd_name"
        print_status "Start it with: emulator -avd $avd_name"
    else
        print_error "Failed to create Android emulator"
        return 1
    fi
}

# Function to setup apps directory
setup_apps_directory() {
    print_step "Setting up apps directory..."
    
    # Create apps directory structure
    if [[ ! -d "apps" ]]; then
        print_status "Creating apps directory structure..."
        mkdir -p apps/android
        mkdir -p apps/ios
        
        if [[ $? -eq 0 ]]; then
            print_success "Apps directory structure created"
        else
            print_error "Failed to create apps directory structure"
            return 1
        fi
    else
        print_success "Apps directory already exists"
    fi
    
    # Check for app files and provide guidance
    local android_apk_missing=false
    local ios_app_missing=false
    
    if [[ ! -f "apps/android/app-release.apk" ]]; then
        android_apk_missing=true
        print_warning "Android APK not found at: apps/android/app-release.apk"
    else
        print_success "Android APK found: apps/android/app-release.apk"
    fi
    
    if [[ ! -d "apps/ios/MyApp.app" ]]; then
        ios_app_missing=true
        print_warning "iOS app bundle not found at: apps/ios/MyApp.app"
    else
        print_success "iOS app bundle found: apps/ios/MyApp.app"
    fi
    
    # Provide guidance for missing app files
    if [[ "$android_apk_missing" == true ]] || [[ "$ios_app_missing" == true ]]; then
        echo ""
        print_status "📱 App Files Setup Required:"
        echo ""
        
        if [[ "$android_apk_missing" == true ]]; then
            print_status "Android APK Setup:"
            echo -e "  ${CYAN}Expected location:${NC} apps/android/app-release.apk"
            echo -e "  ${CYAN}How to get:${NC} Build your Android app or download from CI/CD"
            echo -e "  ${CYAN}Command:${NC} cp /path/to/your/app-release.apk apps/android/"
            echo ""
        fi
        
        if [[ "$ios_app_missing" == true ]]; then
            print_status "iOS App Bundle Setup:"
            echo -e "  ${CYAN}Expected location:${NC} apps/ios/MyApp.app"
            echo -e "  ${CYAN}How to get:${NC} Build your iOS app or download from CI/CD"
            echo -e "  ${CYAN}Command:${NC} cp -r /path/to/your/MyApp.app apps/ios/"
            echo ""
        fi
        
        print_status "📋 Next Steps:"
        echo -e "  1. ${GREEN}Build your app${NC} or ${GREEN}download from CI/CD${NC}"
        echo -e "  2. ${GREEN}Place the files${NC} in the correct locations above"
        echo -e "  3. ${GREEN}Run setup again${NC}: ./setup.sh --check-only"
        echo ""
        
        # Skip prompt if non-interactive mode
        if [[ "$NON_INTERACTIVE" == true ]]; then
            print_status "Non-interactive mode: Continuing setup (app files can be added later)"
            return 0
        fi
        
        # Ask user if they want to continue
        read -p "Do you want to continue with setup (app files can be added later)? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Setup paused. Please add app files and run setup again."
            return 1
        fi
    fi
    
    return 0
}

# Function to verify installation
verify_installation() {
    print_step "Verifying installation..."
    
    local issues=0
    
    # Check framework files
    if [[ -f "maestro.yaml" ]]; then
        print_success "maestro.yaml configuration found"
    else
        print_error "maestro.yaml not found"
        issues=$((issues + 1))
    fi
    
    if [[ -f "run-tests.sh" ]] && [[ -x "run-tests.sh" ]]; then
        print_success "run-tests.sh script found and executable"
    else
        print_error "run-tests.sh not found or not executable"
        issues=$((issues + 1))
    fi
    
    if [[ -d "flows" ]]; then
        local flow_count=$(find flows -name "*.yaml" | wc -l)
        print_success "Found $flow_count test flow(s)"
    else
        print_error "flows directory not found"
        issues=$((issues + 1))
    fi
    
    # Setup apps directory and check app files
    if setup_apps_directory; then
        # Apps directory setup successful
        if [[ -f "apps/android/app-release.apk" ]] && [[ -d "apps/ios/MyApp.app" ]]; then
            print_success "All app files are present and ready for testing"
        else
            print_warning "Some app files are missing but setup can continue"
        fi
    else
        print_error "Apps directory setup failed"
        issues=$((issues + 1))
    fi
    
    return $issues
}

# Function to run quick test
run_quick_test() {
    print_step "Running quick test..."
    
    if ! command_exists maestro; then
        print_error "Maestro not available for testing"
        return 1
    fi
    
    # Try to run a simple test
    if [[ -f "flows/guest-user-flow.yaml" ]]; then
        print_status "Testing guest user flow..."
        if ./run-tests.sh --help >/dev/null 2>&1; then
            print_success "Test runner script is working"
        else
            print_error "Test runner script has issues"
            return 1
        fi
    else
        print_warning "No test flows available for quick test"
    fi
    
    return 0
}

# Function to show summary
show_summary() {
    local os=$(detect_os)
    
    echo ""
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                            Setup Summary                              ║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════════════╝${NC}"
    
    print_status "Operating System: $os"
    
    case $os in
        "windows")
            print_status "Supported Testing: Android only"
            ;;
        "macos")
            print_status "Supported Testing: Android + iOS"
            ;;
        "linux")
            print_status "Supported Testing: Android only"
            ;;
    esac
    
    echo ""
    print_status "To run tests:"
    echo -e "  ${CYAN}# Run Android tests${NC}"
    echo -e "  ${GREEN}./run-tests.sh -p android${NC}"
    
    if [[ "$os" == "macos" ]]; then
        echo -e "  ${CYAN}# Run iOS tests${NC}"
        echo -e "  ${GREEN}./run-tests.sh -p ios${NC}"
        echo -e "  ${CYAN}# Run both platforms${NC}"
        echo -e "  ${GREEN}./run-tests.sh -p both${NC}"
    fi
    
    echo ""
    print_status "For more options:"
    echo -e "  ${GREEN}./run-tests.sh --help${NC}"
    
    echo ""
    print_status "Documentation:"
    echo -e "  ${CYAN}Maestro Commands:${NC} https://docs.maestro.dev/api-reference/commands"
    echo -e "  ${CYAN}Advanced Features:${NC} https://docs.maestro.dev/advanced/"
    echo -e "  ${CYAN}Framework README:${NC} ./README.md"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --check-only        Only check requirements, don't install anything"
    echo "  --install-missing   Install missing components automatically"
    echo "  --create-emulator   Create Android emulator after setup"
    echo "  --quick-test        Run a quick test after setup"
    echo "  --non-interactive   Run in non-interactive mode (skip prompts)"
    echo "  --verbose           Enable verbose output"
    echo "  --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                              # Check requirements and show status"
    echo "  $0 --install-missing            # Install missing components"
    echo "  $0 --install-missing --quick-test  # Full setup with test"
    echo "  $0 --non-interactive            # Run without user prompts"
}

# Main function
main() {
    local check_only=false
    local install_missing=false
    local create_emulator=false
    local quick_test=false
    local verbose=false
    local non_interactive=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --check-only)
                check_only=true
                shift
                ;;
            --install-missing)
                install_missing=true
                shift
                ;;
            --create-emulator)
                create_emulator=true
                shift
                ;;
            --quick-test)
                quick_test=true
                shift
                ;;
            --non-interactive)
                non_interactive=true
                NON_INTERACTIVE=true
                shift
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --help)
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
    
    # Show header
    print_header
    
    # Show platform information
    show_platform_info
    
    # Check requirements
    local java_ok=false
    local android_ok=false
    local ios_ok=false
    local maestro_ok=false
    
    # Java check
    if check_java; then
        java_ok=true
    elif [[ "$install_missing" == true ]]; then
        if install_java; then
            java_ok=true
        fi
    fi
    
    # Android SDK check
    if check_android_sdk; then
        android_ok=true
    elif [[ "$install_missing" == true ]]; then
        if install_android_sdk; then
            android_ok=true
        fi
    fi
    
    # iOS check (macOS only)
    if check_ios_requirements; then
        ios_ok=true
    fi
    
    # Maestro check
    if check_maestro; then
        maestro_ok=true
    elif [[ "$install_missing" == true ]]; then
        if install_maestro; then
            maestro_ok=true
        fi
    fi
    
    # Device connectivity check
    check_devices
    
    # Create emulator if requested
    if [[ "$create_emulator" == true ]] && [[ "$android_ok" == true ]]; then
        create_android_emulator
    fi
    
    # Verify installation
    verify_installation
    local verification_result=$?
    
    # Run quick test if requested
    if [[ "$quick_test" == true ]] && [[ "$maestro_ok" == true ]]; then
        run_quick_test
    fi
    
    # Show summary
    show_summary
    
    # Final status
    echo ""
    if [[ "$java_ok" == true ]] && [[ "$android_ok" == true ]] && [[ "$maestro_ok" == true ]] && [[ $verification_result -eq 0 ]]; then
        print_success "Setup completed successfully! 🎉"
        print_status "You can now run tests with: ./run-tests.sh"
    else
        print_warning "Setup completed with some issues"
        print_status "Review the output above and install missing components"
        if [[ "$install_missing" == false ]]; then
            print_status "Run with --install-missing to auto-install components"
        fi
    fi
}

# Run main function
main "$@"
