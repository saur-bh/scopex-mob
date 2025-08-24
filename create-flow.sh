#!/bin/bash

# ScopeX Mobile Test Flow Generator
# Creates new test flows with proper template structure

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
    echo -e "${PURPLE}║              ScopeX Mobile Test Flow Generator v1.0                  ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_success() {
    echo -e "${GREEN}[✓ SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗ ERROR]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "ScopeX Mobile Test Flow Generator"
    echo "Usage: $0 <flow-name> [options]"
    echo ""
    echo "Arguments:"
    echo "  flow-name          Name of the new test flow (required)"
    echo ""
    echo "Options:"
    echo "  -t, --tags         Comma-separated list of tags (default: feature,clear-state)"
    echo "  -d, --description  Description for the flow"
    echo "  -p, --post-signup  Create post-signup flow (authenticated user, no clear state)"
    echo "  -c, --clear-state  Include clear state and signup (default: true)"
    echo "  -n, --no-clear     Exclude clear state"
    echo "  -h, --help         Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 payment-flow --post-signup"
    echo "  $0 wallet-balance --tags 'feature,wallet,post-signup' --post-signup"
    echo "  $0 user-profile --description 'Test user profile functionality' --post-signup"
    echo "  $0 onboarding --clear-state"
    echo ""
    echo "Flow Types:"
    echo "  --post-signup: Uses app-launch-no-clear-state.yaml (authenticated user)"
    echo "  --clear-state: Uses signup-flow-clear-state.yaml (signup + test)"
    echo ""
    echo "Available tags:"
    echo "  feature, clear-state, post-signup, critical, guest, authentication"
    echo "  wallet, payment, profile, settings, onboarding, regression, smoke"
    echo "  Recommended defaults: regression, smoke"
}

# Function to validate flow name
validate_flow_name() {
    local flow_name="$1"
    
    # Check if flow name is provided
    if [[ -z "$flow_name" ]]; then
        print_error "Flow name is required"
        show_usage
        exit 1
    fi
    
    # Check if flow name contains valid characters
    if [[ ! "$flow_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Flow name can only contain letters, numbers, hyphens, and underscores"
        exit 1
    fi
    
    # Check if flow already exists
    local flow_file="flows/feature/${flow_name}.yaml"
    if [[ -f "$flow_file" ]]; then
        print_error "Flow file already exists: $flow_file"
        exit 1
    fi
}

# Function to generate flow content
generate_flow_content() {
    local flow_name="$1"
    local flow_title="$2"
    local tags="$3"
    local description="$4"
    local clear_state="$5"
    local post_signup="$6"
    
    # Convert flow name to title case for display
    local display_name=$(echo "$flow_title" | sed 's/-/ /g' | sed 's/_/ /g' | sed 's/\b\w/\U&/g')
    
    # Create the flow file content
    {
        echo "# ${display_name} - ${description}"
        echo "# ${description}"
        echo ""
        echo "# IMPORTANT: Use Maestro Studio to record your test steps!"
        echo "# 1. Run: maestro studio"
        echo "# 2. Record your test actions"
        echo "# 3. Copy the generated commands to replace the placeholder steps below"
        echo ""
        echo "appId: com.scopex.scopexmobilev2"
        echo "name: \"${display_name}\""
        echo "tags: [${tags}]"
        echo ""
        echo "# Environment variables"
        echo "env:"
        echo "  TEST_START_TIME: \"\${Date.now()}\""
        echo "  PLATFORM: \"\${maestro.platform}\""
        echo "  MAX_RETRIES: \"3\""
        echo ""
        echo "# Flow hooks for setup and cleanup"
        echo "onFlowStart:"
        echo "  - evalScript: \"output.testStartTime = Date.now();\""
        echo "  - evalScript: \"output.stepCount = 0;\""
        echo ""
        echo "onFlowComplete:"
        echo "  - evalScript: \"const duration = Date.now() - output.testStartTime;\""
        echo "  - evalScript: \"output.stepCount++;\""
        echo "  - takeScreenshot: \"${flow_name}-complete\""
        echo ""
        echo "---"
        echo "# Start screen recording"
        echo "- startRecording:"
        echo "    path: '${flow_name}'"
        echo "    label: '${display_name} Recording'"
        echo ""
        
        # Choose flow type based on post_signup flag
        if [[ "$post_signup" == "true" ]]; then
            # Post-signup flow (authenticated user, no clear state)
            echo "# Step 1: Launch the app without state clearing"
            echo "- launchApp:"
            echo "    appId: \"com.scopex.scopexmobilev2\""
            echo "    clearState: false"
            echo "    clearKeychain: false"
            echo ""
            echo "# Step 2: Wait for app to load and check for authenticated state"
            echo "- extendedWaitUntil:"
            echo "    visible: \"Send Money\""
            echo "    timeout: 15000"
            echo ""
            echo "# If Send Money is visible, user is authenticated - continue with test"
            echo "# If not visible, run signup flow first"
            echo "- runFlow:"
            echo "    file: flows/feature/signup-flow-clear-state.yaml"
            echo "    when:"
            echo "      notVisible: \"Send Money\""
            echo ""
            echo "# Step 3: Your specific test steps here (REPLACE WITH RECORDED COMMANDS)"
            echo "- evalScript: \"console.log('Step 3: Performing test action...');\""
            echo "# TODO: Replace with commands recorded from Maestro Studio"
            echo "# Example:"
            echo "# - tapOn: \"Your Element\""
            echo "# - inputText: \"Your Text\""
            echo "# - assertVisible: \"Expected Result\""
            echo "- evalScript: \"console.log('Test action completed');\""
            echo ""
            echo "# Step 4: Verify expected results"
            echo "- evalScript: \"console.log('Step 4: Verifying results...');\""
            echo "- assertVisible: \"Expected Result Element\""
            echo "- evalScript: \"console.log('Results verified successfully');\""
            echo ""
            echo "# Step 5: Take screenshot"
            echo "- evalScript: \"console.log('Step 5: Taking screenshot...');\""
            echo "- takeScreenshot: \"${flow_name}-complete\""
            echo ""
            echo "# Step 6: Final verification"
            echo "- evalScript: \"console.log('Step 6: Final verification...');\""
            echo "- assertTrue: \"maestro.appId === 'com.scopex.scopexmobilev2'\""
            echo "- evalScript: \"console.log('${display_name} test completed successfully!');\""
            echo ""
        else
            # Clear state flow (signup + test)
            echo "# Step 1: Launch the app with state clearing"
            echo "- launchApp:"
            echo "    appId: \"com.scopex.scopexmobilev2\""
            echo "    clearState: true"
            echo "    clearKeychain: true"
            echo ""
            echo "# Step 2: Wait for app to load"
            echo "- extendedWaitUntil:"
            echo "    visible: \"Continue\""
            echo "    timeout: 15000"
            echo ""
            echo "# Step 3: Navigate through onboarding"
            echo "# Screen 1: Initial onboarding"
            echo "- assertVisible: \"Continue\""
            echo ""
            echo "# Navigate to next screen"
            echo "- tapOn: \"Continue\""
            echo ""
            echo "# Screen 2: Trusted by thousands"
            echo "- assertVisible: \"Continue\""
            echo ""
            echo "# Navigate to next screen"
            echo "- tapOn: \"Continue\""
            echo ""
            echo "# Screen 3: Designed for love"
            echo "- assertVisible: \"Get Started\""
            echo ""
            echo "# Complete onboarding"
            echo "- tapOn: \"Get Started\""
            echo ""
            echo "# Step 4: Handle signup flow"
            echo "# Verify navigation to signup screen"
            echo "- assertVisible: \"Sign.*\""
            echo "- assertVisible: \"Sign up to continue\""
            echo ""
            echo "# Tap on Sign up"
            echo "- tapOn: \"Sign up to continue\""
            echo ""
            echo "# Verify email input screen"
            echo "- extendedWaitUntil:"
            echo "    visible: \"Email\""
            echo "    timeout: 10000"
            echo ""
            echo "# Enter email"
            echo "- tapOn: \"Email\""
            echo "- inputText: \"teshank.2137@gmail.com\""
            echo ""
            echo "# Tap Next"
            echo "- tapOn: \"Next\""
            echo "- tapOn: \"Next\""
            echo ""
            echo "# Handle OTP flow"
            echo "- tapOn: \"Login with code\""
            echo ""
            echo "# Enter OTP"
            echo "- tapOn:"
            echo "    point: \"11%,41%\""
            echo "- inputText: \"000000\""
            echo ""
            echo "# Complete OTP verification"
            echo "- tapOn: \"Next\""
            echo "- tapOn: \"Next\""
            echo ""
            echo "# Step 5: Verify successful signup"
            echo "- extendedWaitUntil:"
            echo "    visible: \"Send Money\""
            echo "    timeout: 15000"
            echo ""
            echo "# Step 6: Your specific test steps here (REPLACE WITH RECORDED COMMANDS)"
            echo "- evalScript: \"console.log('Step 6: Performing test action...');\""
            echo "# TODO: Replace with commands recorded from Maestro Studio"
            echo "# Example:"
            echo "# - tapOn: \"Your Element\""
            echo "# - inputText: \"Your Text\""
            echo "# - assertVisible: \"Expected Result\""
            echo "- evalScript: \"console.log('Test action completed');\""
            echo ""
            echo "# Step 7: Verify expected results"
            echo "- evalScript: \"console.log('Step 7: Verifying results...');\""
            echo "- assertVisible: \"Expected Result Element\""
            echo "- evalScript: \"console.log('Results verified successfully');\""
            echo ""
            echo "# Step 8: Take screenshot"
            echo "- evalScript: \"console.log('Step 8: Taking screenshot...');\""
            echo "- takeScreenshot: \"${flow_name}-complete\""
            echo ""
            echo "# Step 9: Final verification"
            echo "- evalScript: \"console.log('Step 9: Final verification...');\""
            echo "- assertTrue: \"maestro.appId === 'com.scopex.scopexmobilev2'\""
            echo "- evalScript: \"console.log('${display_name} test completed successfully!');\""
            echo ""
        fi
        
        echo "# Stop recording"
        echo "- evalScript: \"console.log('Recording completed - ${display_name} test finished');\""
        echo "- stopRecording"
        echo ""
        echo "# ============================================================================"
        echo "# INSTRUCTIONS FOR RECORDING TEST STEPS:"
        echo "# ============================================================================"
        echo "# 1. Start Maestro Studio:"
        echo "#    maestro studio"
        echo "#"
        echo "# 2. Record your test actions:"
        echo "#    - Navigate through your app"
        echo "#    - Perform the actions you want to test"
        echo "#    - Maestro will generate the commands"
        echo "#"
        echo "# 3. Copy the generated commands and replace the placeholder steps above"
        echo "#    - Look for the TODO comments"
        echo "#    - Replace with your recorded commands"
        echo "#"
        echo "# 4. Test your flow:"
        echo "#    ./run-tests.sh flows/feature/${flow_name}.yaml"
        echo "# ============================================================================"
    }
}

# Function to create flow file
create_flow_file() {
    local flow_name="$1"
    local flow_title="$2"
    local tags="$3"
    local description="$4"
    local clear_state="$5"
    local post_signup="$6"
    
    local flow_file="flows/feature/${flow_name}.yaml"
    
    print_step "Creating flow file: $flow_file"
    
    # Ensure flows directory exists
    mkdir -p "flows/feature"
    
    # Generate and write flow content
    generate_flow_content "$flow_name" "$flow_title" "$tags" "$description" "$clear_state" "$post_signup" > "$flow_file"
    
    if [[ $? -eq 0 ]]; then
        print_success "Flow file created successfully: $flow_file"
        return 0
    else
        print_error "Failed to create flow file"
        return 1
    fi
}

# Function to validate and run the new flow
test_new_flow() {
    local flow_name="$1"
    local flow_file="flows/feature/${flow_name}.yaml"
    
    print_step "Testing new flow..."
    
    # Check if flow file exists
    if [[ ! -f "$flow_file" ]]; then
        print_error "Flow file not found: $flow_file"
        return 1
    fi
    
    print_success "Flow file created successfully: $flow_file"
    
    # Ask user if they want to run the flow
    echo ""
    read -p "Do you want to run this new flow to test it? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Running new flow for testing..."
        ./run-tests.sh "$flow_file" --format junit
    else
        print_info "Flow created successfully. You can run it later with:"
        print_info "./run-tests.sh $flow_file"
    fi
}

# Function to prompt for tags with defaults
prompt_for_tags() {
    echo "" >&2
    print_step "Tag Selection" >&2
    echo "Available tags: feature, clear-state, post-signup, critical, guest, authentication" >&2
    echo "               wallet, payment, profile, settings, onboarding, regression, smoke" >&2
    echo "" >&2
    echo "Recommended defaults: regression, smoke" >&2
    echo "" >&2
    read -p "Enter tags (comma-separated) or press Enter for defaults [regression,smoke]: " user_tags
    
    if [[ -z "$user_tags" ]]; then
        echo "\"regression\", \"smoke\""
    else
        echo "\"$(echo "$user_tags" | sed 's/,/", "/g')\""
    fi
}

# Function to determine flow type based on app state
determine_flow_type() {
    local flow_name="$1"
    
    echo ""
    print_step "Flow Type Detection"
    echo "Analyzing if signup is required for this flow..."
    echo ""
    echo "Does your test flow expect to see 'Send Money' immediately after app launch?"
    echo "(This indicates the user should already be logged in)"
    echo ""
    read -p "Will 'Send Money' be visible after app launch? (y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "post-signup"  # No signup needed, user already authenticated
    else
        echo "clear-state"  # Signup flow needed
    fi
}

# Main function
main() {
    local flow_name=""
    local tags=""
    local description=""
    local clear_state="true"
    local post_signup="false"
    local interactive_mode="true"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -t|--tags)
                tags="\"$(echo "$2" | sed 's/,/", "/g')\""
                interactive_mode="false"
                shift 2
                ;;
            -d|--description)
                description="$2"
                shift 2
                ;;
            -p|--post-signup)
                post_signup="true"
                clear_state="false"
                tags="\"feature\", \"post-signup\""
                interactive_mode="false"
                shift
                ;;
            -c|--clear-state)
                clear_state="true"
                post_signup="false"
                interactive_mode="false"
                shift
                ;;
            -n|--no-clear)
                clear_state="false"
                post_signup="false"
                interactive_mode="false"
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
                if [[ -z "$flow_name" ]]; then
                    flow_name="$1"
                else
                    print_error "Multiple flow names provided"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Show header
    print_header
    
    # Validate flow name
    validate_flow_name "$flow_name"
    
    # Interactive mode for tag selection and flow type determination
    if [[ "$interactive_mode" == "true" ]]; then
        # Prompt for tags if not provided
        if [[ -z "$tags" ]]; then
            tags=$(prompt_for_tags)
        fi
        
        # Determine flow type based on Send Money visibility
        flow_type=$(determine_flow_type "$flow_name")
        
        if [[ "$flow_type" == "post-signup" ]]; then
            post_signup="true"
            clear_state="false"
            # Add post-signup tag if not already present
            if [[ "$tags" != *"post-signup"* ]]; then
                tags="${tags%, \"*}\", \"post-signup\""
            fi
        else
            post_signup="false"
            clear_state="true"
            # Add clear-state tag if not already present
            if [[ "$tags" != *"clear-state"* ]]; then
                tags="${tags%, \"*}\", \"clear-state\""
            fi
        fi
        
        # Prompt for description if not provided
        if [[ -z "$description" ]]; then
            echo ""
            print_step "Description"
            read -p "Enter a description for this test flow: " description
            if [[ -z "$description" ]]; then
                description="Test flow for ${flow_name}"
            fi
        fi
    else
        # Non-interactive mode - use defaults if not provided
        if [[ -z "$tags" ]]; then
            tags="\"regression\", \"smoke\""
        fi
        
        if [[ -z "$description" ]]; then
            description="Test flow for ${flow_name}"
        fi
    fi
    
    # Create flow file
    if create_flow_file "$flow_name" "$flow_name" "$tags" "$description" "$clear_state" "$post_signup"; then
        print_success "Flow created successfully!"
        echo ""
        print_info "Flow details:"
        print_info "  Name: $flow_name"
        print_info "  File: flows/feature/${flow_name}.yaml"
        print_info "  Tags: $tags"
        print_info "  Clear State: $clear_state"
        print_info "  Post-Signup: $post_signup"
        echo ""
        
        # Test the new flow
        test_new_flow "$flow_name"
        
        echo ""
        print_success "Flow generation completed!"
        echo ""
        print_info "🎯 IMPORTANT: Your flow template is ready, but you need to record the actual test steps!"
        echo ""
        print_info "📝 Next steps:"
        print_info "1. 🎬 Start Maestro Studio to record your test:"
        print_info "   maestro studio"
        echo ""
        print_info "2. 📱 In Maestro Studio:"
        print_info "   - Navigate through your app"
        print_info "   - Perform the actions you want to test"
        print_info "   - Maestro will generate the commands automatically"
        echo ""
        print_info "3. 📋 Copy the generated commands to your flow file:"
        print_info "   flows/feature/${flow_name}.yaml"
        print_info "   (Replace the TODO placeholder steps)"
        echo ""
        print_info "4. 🧪 Test your completed flow:"
        print_info "   ./run-tests.sh flows/feature/${flow_name}.yaml"
        echo ""
        print_success "🚀 Ready to start recording with Maestro Studio!"
    else
        print_error "Failed to create flow"
        exit 1
    fi
}

# Run main function
main "$@"
