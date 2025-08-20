#!/bin/bash

#############################################################################
# CNSQ NetOps Mac Setup Script
# Version: 2.0.1
# Purpose: Automated macOS setup for NetOps team development
#############################################################################

set -uo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color
BOLD='\033[1m'
DIM='\033[2m'

# Script information
SCRIPT_VERSION="2.0.1"
SCRIPT_NAME="CNSQ NetOps Mac Setup"
# State file stores task completion history (one task ID per line)
# This is separate from actual detection - we check both!
STATE_FILE="$HOME/.cnsq-setup-state"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#############################################################################
# Functions
#############################################################################

# Print colored output
print_info() {
    echo -e "${CYAN}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Print header
print_header() {
    clear
    echo ""
    echo -e "${BOLD}${BLUE}$SCRIPT_NAME - v$SCRIPT_VERSION${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Mark task as complete
mark_complete() {
    local task_id="$1"
    if ! grep -q "^${task_id}$" "$STATE_FILE" 2>/dev/null; then
        echo "$task_id" >> "$STATE_FILE"
    fi
}

# Check if task is complete
is_complete() {
    local task_id="$1"
    grep -q "^${task_id}$" "$STATE_FILE" 2>/dev/null
}

# Check actual installation status of components
check_xcode_installed() {
    xcode-select -p &>/dev/null
}

check_homebrew_installed() {
    command -v brew &>/dev/null || [[ -f "/opt/homebrew/bin/brew" ]] || [[ -f "/usr/local/bin/brew" ]]
}

check_homebrew_path_configured() {
    command -v brew &>/dev/null
}

check_iterm2_installed() {
    [[ -d "/Applications/iTerm.app" ]]
}

# Initialize completion status based on actual installations
initialize_completion_status() {
    local updated=false
    
    # Check Xcode Command Line Tools
    if check_xcode_installed && ! is_complete "xcode"; then
        mark_complete "xcode"
        updated=true
    fi
    
    # Check Homebrew
    if check_homebrew_installed && ! is_complete "homebrew"; then
        mark_complete "homebrew"
        updated=true
    fi
    
    # Check Homebrew PATH
    if check_homebrew_path_configured && ! is_complete "homebrew_path"; then
        mark_complete "homebrew_path"
        updated=true
    fi
    
    # Check iTerm2
    if check_iterm2_installed && ! is_complete "iterm2"; then
        mark_complete "iterm2"
        updated=true
    fi
    
    # Note: We don't auto-complete sudo since it's a per-session verification
    
    if $updated; then
        return 0
    fi
    return 1
}

# Display menu
show_menu() {
    print_header
    echo -e "${BOLD}Setup Tasks:${NC}"
    echo ""
    
    # Task definitions
    local task_ids=("xcode" "homebrew" "homebrew_path" "iterm2" "sudo")
    local task_names=(
        "Install Xcode Command Line Tools"
        "Install Homebrew Package Manager"
        "Configure Homebrew in Shell"
        "Install iTerm2 Terminal"
        "Verify Administrator Access"
    )
    local check_functions=(
        "check_xcode_installed"
        "check_homebrew_installed"
        "check_homebrew_path_configured"
        "check_iterm2_installed"
        "false"  # sudo doesn't have a permanent install check
    )
    
    local num=1
    local i=0
    for task_id in "${task_ids[@]}"; do
        local check_func="${check_functions[$i]}"
        
        # Check if actually installed vs just marked complete
        if $check_func; then
            # Actually installed (regardless of tracking)
            echo -e "  ${GREEN}✓${NC} ${DIM}$num. ${task_names[$i]}${NC}"
            # Silently mark as complete if not already
            if ! is_complete "$task_id"; then
                mark_complete "$task_id"
            fi
        elif is_complete "$task_id"; then
            # Marked complete but not actually installed (shouldn't happen)
            echo -e "  ${YELLOW}⚠${NC}  $num. ${task_names[$i]} ${DIM}(needs reinstall)${NC}"
        else
            # Not installed and not marked
            echo -e "  ${YELLOW}○${NC} $num. ${task_names[$i]}"
        fi
        ((num++))
        ((i++))
    done
    
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  A. Run All Pending Tasks"
    echo "  R. Reset All Tasks"
    echo "  Q. Quit"
    echo ""
    echo -n "Enter your choice (1-5, A, R, or Q): "
}

# Verify sudo access
verify_sudo_access() {
    print_info "Checking administrator privileges..."
    
    # Check if user is in admin group
    if ! groups | grep -q admin; then
        print_error "You are not in the admin group."
        echo "    This script requires administrator privileges."
        echo "    Please contact your system administrator."
        return 1
    fi
    
    # Test if we already have sudo access (cached)
    if sudo -n true 2>/dev/null; then
        print_success "Administrator access confirmed (cached)"
        return 0
    fi
    
    # Inform user why we need sudo
    print_warning "This script needs administrator access to:"
    echo "    • Install system packages"
    echo "    • Configure development environment"
    echo "    • Set up network tools"
    echo ""
    
    # Prompt for password
    echo "Please enter your password when prompted:"
    if ! sudo -v; then
        print_error "Failed to authenticate."
        echo "    Please ensure you have the correct password and try again."
        return 1
    fi
    
    # Keep sudo alive in background
    (while true; do sudo -n true; sleep 50; done 2>/dev/null) &
    SUDO_PID=$!
    
    # Store PID for cleanup
    echo "$SUDO_PID" > /tmp/.cnsq-sudo-pid-$$
    
    print_success "Administrator access verified successfully"
    return 0
}

# Install Xcode Command Line Tools
install_xcode_tools() {
    print_info "Installing Xcode Command Line Tools..."
    
    # Check if already installed
    if check_xcode_installed; then
        print_success "Xcode Command Line Tools already installed"
        mark_complete "xcode"
        return 0
    fi
    
    print_warning "This will open a system dialog for Xcode installation"
    echo "    Please follow the prompts in the installer window"
    echo ""
    
    # Trigger the installation
    xcode-select --install 2>/dev/null || true
    
    # Wait for user to complete installation
    echo "Press Enter once the installation is complete..."
    read -r
    
    # Verify installation
    if check_xcode_installed; then
        print_success "Xcode Command Line Tools installed successfully"
        mark_complete "xcode"
        return 0
    else
        print_error "Xcode Command Line Tools installation failed or was cancelled"
        return 1
    fi
}

# Install Homebrew
install_homebrew() {
    print_info "Installing Homebrew Package Manager..."
    
    # Check if already installed
    if check_homebrew_installed; then
        print_success "Homebrew is already installed"
        mark_complete "homebrew"
        return 0
    fi
    
    print_warning "Homebrew installation will begin"
    echo "    You may need to enter your password"
    echo ""
    
    # Create a temporary script for unattended installation
    cat > /tmp/brew_install.sh << 'EOF'
#!/bin/bash
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
EOF
    
    chmod +x /tmp/brew_install.sh
    
    # Run the installation
    if /tmp/brew_install.sh; then
        print_success "Homebrew installed successfully"
        mark_complete "homebrew"
        rm -f /tmp/brew_install.sh
        return 0
    else
        print_error "Homebrew installation failed"
        rm -f /tmp/brew_install.sh
        return 1
    fi
}

# Configure Homebrew in shell
configure_homebrew_path() {
    print_info "Configuring Homebrew in shell environment..."
    
    # Check if brew is already in PATH
    if check_homebrew_path_configured; then
        print_success "Homebrew is already configured in PATH"
        mark_complete "homebrew_path"
        return 0
    fi
    
    # Determine brew location (Apple Silicon vs Intel)
    local brew_path=""
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        brew_path="/opt/homebrew/bin/brew"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        brew_path="/usr/local/bin/brew"
    else
        print_error "Homebrew not found. Please install Homebrew first."
        return 1
    fi
    
    # Add brew to shell config if not present
    local brew_shellenv="eval \"\$(${brew_path} shellenv)\""
    
    if ! grep -q "brew shellenv" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# Homebrew configuration" >> "$HOME/.zshrc"
        echo "$brew_shellenv" >> "$HOME/.zshrc"
        print_success "Added Homebrew to ~/.zshrc"
    fi
    
    # Source for current session
    eval "$(${brew_path} shellenv)" 2>/dev/null || true
    
    if command -v brew &>/dev/null; then
        print_success "Homebrew configured successfully"
        mark_complete "homebrew_path"
        return 0
    else
        print_warning "Homebrew configuration added but requires shell restart"
        mark_complete "homebrew_path"
        return 0
    fi
}

# Install iTerm2
install_iterm2() {
    print_info "Installing iTerm2..."
    
    # Check if already installed
    if check_iterm2_installed; then
        print_success "iTerm2 is already installed"
        mark_complete "iterm2"
        return 0
    fi
    
    # Ensure brew is available
    if ! command -v brew &>/dev/null; then
        # Try to source brew if it's installed but not in PATH
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            eval "$(/usr/local/bin/brew shellenv)"
        else
            print_error "Homebrew is not available. Please install Homebrew first."
            return 1
        fi
    fi
    
    print_info "Installing iTerm2 via Homebrew..."
    if brew install --cask iterm2; then
        print_success "iTerm2 installed successfully"
        mark_complete "iterm2"
        
        # Check if we're not already in iTerm2
        if [[ "${TERM_PROGRAM:-}" != "iTerm.app" ]]; then
            print_warning "iTerm2 has been installed!"
            echo ""
            echo "To continue with the best experience:"
            echo "  1. Open iTerm2 from Applications or Spotlight"
            echo "  2. Navigate to: cd $SCRIPT_DIR"
            echo "  3. Run: ./setup.sh"
            echo ""
            echo "Your progress has been saved and will continue in iTerm2."
            echo ""
            read -p "Press Enter to open iTerm2 now, or Ctrl+C to exit... "
            
            # Open iTerm2 and run the script
            osascript <<EOF 2>/dev/null
                tell application "iTerm"
                    activate
                    create window with default profile
                    tell current session of current window
                        write text "cd '$SCRIPT_DIR' && ./setup.sh"
                    end tell
                end tell
EOF
            exit 0
        fi
        
        return 0
    else
        print_error "Failed to install iTerm2"
        return 1
    fi
}

# Run all pending tasks
run_all_tasks() {
    local tasks_run=false
    
    if ! is_complete "sudo"; then
        echo ""
        verify_sudo_access && mark_complete "sudo"
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "xcode"; then
        echo ""
        install_xcode_tools
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "homebrew"; then
        echo ""
        install_homebrew
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "homebrew_path"; then
        echo ""
        configure_homebrew_path
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "iterm2"; then
        echo ""
        install_iterm2
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! $tasks_run; then
        print_success "All tasks are already complete!"
        echo ""
        read -p "Press Enter to continue..."
    fi
}

# Reset all tasks
reset_tasks() {
    print_warning "This will reset all task completion states."
    echo -n "Are you sure? (y/N): "
    read -r confirm
    
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        rm -f "$STATE_FILE"
        print_success "All tasks have been reset"
    else
        print_info "Reset cancelled"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# Cleanup function
cleanup() {
    # Kill sudo keepalive if it exists
    if [[ -f /tmp/.cnsq-sudo-pid-$$ ]]; then
        SUDO_PID=$(cat /tmp/.cnsq-sudo-pid-$$)
        if kill -0 "$SUDO_PID" 2>/dev/null; then
            kill "$SUDO_PID" 2>/dev/null || true
        fi
        rm -f /tmp/.cnsq-sudo-pid-$$
    fi
}

# Set up trap for cleanup
trap cleanup EXIT INT TERM

#############################################################################
# Main Execution
#############################################################################

main() {
    # Create state file if it doesn't exist
    touch "$STATE_FILE" 2>/dev/null || true
    
    # Initialize completion status based on actual installations
    if initialize_completion_status; then
        print_header
        print_info "Detected existing installations and updated status"
        echo ""
        sleep 2
    fi
    
    # Check if we're in iTerm2 and show a welcome message
    if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]] && is_complete "iterm2"; then
        print_header
        print_success "Welcome to iTerm2! Continuing setup..."
        echo ""
        sleep 2
    fi
    
    # Main menu loop
    while true; do
        show_menu
        read -r choice
        
        case "$choice" in
            1)
                echo ""
                install_xcode_tools
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                echo ""
                install_homebrew
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                configure_homebrew_path
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                echo ""
                install_iterm2
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                verify_sudo_access && mark_complete "sudo"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            [Aa])
                run_all_tasks
                ;;
            [Rr])
                reset_tasks
                ;;
            [Qq])
                print_info "Exiting setup script..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                sleep 2
                ;;
        esac
    done
}

# Run main function
main "$@"