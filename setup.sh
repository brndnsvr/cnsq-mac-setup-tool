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

check_sudo_active() {
    # Check if sudo is currently cached/active in this session
    sudo -n true 2>/dev/null
}

check_dev_tools_installed() {
    # Check if key development tools are installed (including VSCode)
    command -v git &>/dev/null && command -v nvim &>/dev/null && command -v python3 &>/dev/null && [[ -d "/Applications/Visual Studio Code.app" ]]
}

check_network_tools_installed() {
    # Check if key network tools are installed
    command -v nmap &>/dev/null && command -v mtr &>/dev/null
}

check_utility_tools_installed() {
    # Check if key utility tools are installed
    command -v jq &>/dev/null && command -v rg &>/dev/null
}

check_security_tools_installed() {
    # Check if key security tools are installed
    command -v ssh-audit &>/dev/null && command -v pwgen &>/dev/null
}

check_zsh_config_installed() {
    # Check if zsh configuration files exist
    [[ -f "$HOME/.zsh/aliases.zsh" ]] && [[ -f "$HOME/.zsh/functions.zsh" ]]
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
    local task_ids=("xcode" "homebrew" "homebrew_path" "iterm2" "sudo" "dev_tools" "network_tools" "utility_tools" "security_tools" "zsh_config")
    local task_names=(
        "Install Xcode Command Line Tools"
        "Install Homebrew Package Manager"
        "Configure Homebrew in Shell"
        "Install iTerm2 Terminal"
        "Verify Administrator Access"
        "Install Dev Tools (git, neovim, python, VSCode, etc.)"
        "Install Network Tools (nmap, wireshark, mtr, etc.)"
        "Install Utility Tools (jq, ripgrep, AppCleaner, etc.)"
        "Install Security Tools (ssh-audit, pwgen, etc.)"
        "Configure Zsh (eza/nvim aliases & functions)"
    )
    local check_functions=(
        "check_xcode_installed"
        "check_homebrew_installed"
        "check_homebrew_path_configured"
        "check_iterm2_installed"
        "check_sudo_active"  # Check if sudo is currently active in session
        "check_dev_tools_installed"
        "check_network_tools_installed"
        "check_utility_tools_installed"
        "check_security_tools_installed"
        "check_zsh_config_installed"
    )
    
    local num=1
    local i=0
    for task_id in "${task_ids[@]}"; do
        local check_func="${check_functions[$i]}"
        
        # Special handling for sudo (task 5)
        if [[ "$task_id" == "sudo" ]]; then
            if check_sudo_active; then
                # Sudo is currently active in this session
                echo -e "  ${GREEN}✓${NC} ${DIM}$num. ${task_names[$i]} (session active)${NC}"
            else
                # Sudo not active
                echo -e "  ${YELLOW}○${NC} $num. ${task_names[$i]}"
            fi
        else
            # Regular tasks (installations)
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
    echo -n "Enter your choice (1-10, A, R, or Q): "
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
    
    # Ensure we have sudo access cached (but don't run installer with sudo)
    print_info "Homebrew installer needs administrator privileges"
    print_warning "You'll be prompted for your password to cache admin access"
    if ! verify_sudo_access; then
        print_error "Cannot install Homebrew without administrator access"
        return 1
    fi
    
    print_info "Starting Homebrew installation (this may take a few minutes)..."
    echo ""
    
    # Create a temporary script for unattended installation
    # NOTE: We do NOT run this with sudo - Homebrew refuses to run as root
    cat > /tmp/brew_install.sh << 'EOF'
#!/bin/bash
export NONINTERACTIVE=1
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
EOF
    
    chmod +x /tmp/brew_install.sh
    
    # Run the installation as regular user (sudo is cached for when installer needs it)
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
    
    # Ensure we have sudo access for cask installation
    print_info "iTerm2 installation may require administrator privileges"
    if ! verify_sudo_access; then
        print_error "Cannot install iTerm2 without administrator access"
        return 1
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

# Install Development Tools
install_dev_tools() {
    print_info "Installing Development Tools..."
    
    # Ensure brew is available
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew is not available. Please install Homebrew first."
        return 1
    fi
    
    local tools=(
        "git"
        "neovim"
        "tmux"
        "python@3"
        "ansible"
        "expect"
        "node"
    )
    
    local cask_tools=(
        "visual-studio-code"
    )
    
    local failed_tools=()
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        if brew install "$tool" 2>/dev/null || brew upgrade "$tool" 2>/dev/null; then
            print_success "$tool installed"
        else
            print_warning "$tool may already be installed or failed"
            failed_tools+=("$tool")
        fi
    done
    
    # Install cask tools (VSCode)
    for tool in "${cask_tools[@]}"; do
        print_info "Installing $tool..."
        if brew install --cask "$tool" 2>/dev/null || brew upgrade --cask "$tool" 2>/dev/null; then
            print_success "$tool installed"
            
            # Setup VSCode 'code' command if it was just installed
            if [[ "$tool" == "visual-studio-code" ]] && [[ -d "/Applications/Visual Studio Code.app" ]]; then
                print_info "Setting up 'code' command in terminal..."
                local vscode_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
                if ! grep -q "Visual Studio Code" "$HOME/.zshrc" 2>/dev/null; then
                    echo "" >> "$HOME/.zshrc"
                    echo "# Visual Studio Code" >> "$HOME/.zshrc"
                    echo "export PATH=\"\$PATH:$vscode_path\"" >> "$HOME/.zshrc"
                    print_success "Added 'code' command to PATH"
                fi
            fi
        else
            print_warning "$tool may already be installed or failed"
            failed_tools+=("$tool")
        fi
    done
    
    # Install Python packages
    print_info "Setting up Python environment..."
    if command -v python3 &>/dev/null; then
        python3 -m pip install --upgrade pip 2>/dev/null || true
        print_success "Python environment configured"
    fi
    
    if [ ${#failed_tools[@]} -eq 0 ]; then
        mark_complete "dev_tools"
        print_success "All development tools installed successfully"
        return 0
    else
        print_warning "Some tools may have had issues: ${failed_tools[*]}"
        mark_complete "dev_tools"
        return 0
    fi
}

# Install Network Tools
install_network_tools() {
    print_info "Installing Network Tools..."
    
    # Ensure brew is available
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew is not available. Please install Homebrew first."
        return 1
    fi
    
    local tools=(
        "nmap"
        "netcat"
        "telnet"
        "gping"
        "mtr"
        "fping"
        "iperf3"
        "whois"
        "arp-scan"
        "ngrep"
        "wireshark"
        "minicom"
        "sipcalc"
        "bandwhich"
    )
    
    local failed_tools=()
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        if [[ "$tool" == "wireshark" ]]; then
            # Wireshark is a cask
            if brew install --cask "$tool" 2>/dev/null || brew upgrade --cask "$tool" 2>/dev/null; then
                print_success "$tool installed"
            else
                print_warning "$tool may already be installed or failed"
                failed_tools+=("$tool")
            fi
        else
            if brew install "$tool" 2>/dev/null || brew upgrade "$tool" 2>/dev/null; then
                print_success "$tool installed"
            else
                print_warning "$tool may already be installed or failed"
                failed_tools+=("$tool")
            fi
        fi
    done
    
    if [ ${#failed_tools[@]} -eq 0 ]; then
        mark_complete "network_tools"
        print_success "All network tools installed successfully"
        return 0
    else
        print_warning "Some tools may have had issues: ${failed_tools[*]}"
        mark_complete "network_tools"
        return 0
    fi
}

# Install Utility Tools
install_utility_tools() {
    print_info "Installing Utility Tools..."
    
    # Ensure brew is available
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew is not available. Please install Homebrew first."
        return 1
    fi
    
    local tools=(
        "jq"
        "ripgrep"
        "tree"
        "eza"
        "zsh-syntax-highlighting"
        "wget"
        "curl"
        "watch"
        "p7zip"
        "coreutils"
        "fzf"
        "tldr"
        "bat"
    )
    
    local cask_tools=(
        "appcleaner"
        "ghostty"
    )
    
    local failed_tools=()
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        if brew install "$tool" 2>/dev/null || brew upgrade "$tool" 2>/dev/null; then
            print_success "$tool installed"
        else
            print_warning "$tool may already be installed or failed"
            failed_tools+=("$tool")
        fi
    done
    
    # Install cask tools
    for tool in "${cask_tools[@]}"; do
        print_info "Installing $tool..."
        if brew install --cask "$tool" 2>/dev/null || brew upgrade --cask "$tool" 2>/dev/null; then
            print_success "$tool installed"
        else
            print_warning "$tool may already be installed or failed"
            failed_tools+=("$tool")
        fi
    done
    
    # Setup zsh-syntax-highlighting if installed
    if [[ -d "/opt/homebrew/share/zsh-syntax-highlighting" ]] || [[ -d "/usr/local/share/zsh-syntax-highlighting" ]]; then
        local zsh_highlight_path=""
        if [[ -d "/opt/homebrew/share/zsh-syntax-highlighting" ]]; then
            zsh_highlight_path="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        else
            zsh_highlight_path="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        fi
        
        if ! grep -q "zsh-syntax-highlighting.zsh" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "# Zsh syntax highlighting" >> "$HOME/.zshrc"
            echo "source $zsh_highlight_path" >> "$HOME/.zshrc"
            print_success "Configured zsh-syntax-highlighting"
        fi
    fi
    
    if [ ${#failed_tools[@]} -eq 0 ]; then
        mark_complete "utility_tools"
        print_success "All utility tools installed successfully"
        return 0
    else
        print_warning "Some tools may have had issues: ${failed_tools[*]}"
        mark_complete "utility_tools"
        return 0
    fi
}

# Install Security Tools
install_security_tools() {
    print_info "Installing Security Tools..."
    
    # Ensure brew is available
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew is not available. Please install Homebrew first."
        return 1
    fi
    
    local tools=(
        "ssh-audit"
        "ssh-copy-id"
        "pwgen"
    )
    
    local failed_tools=()
    
    for tool in "${tools[@]}"; do
        print_info "Installing $tool..."
        if brew install "$tool" 2>/dev/null || brew upgrade "$tool" 2>/dev/null; then
            print_success "$tool installed"
        else
            print_warning "$tool may already be installed or failed"
            failed_tools+=("$tool")
        fi
    done
    
    if [ ${#failed_tools[@]} -eq 0 ]; then
        mark_complete "security_tools"
        print_success "All security tools installed successfully"
        return 0
    else
        print_warning "Some tools may have had issues: ${failed_tools[*]}"
        mark_complete "security_tools"
        return 0
    fi
}

# Setup Zsh configuration for eza and nvim
setup_zsh_config() {
    print_info "Setting up Zsh configuration for eza and nvim..."
    
    # Create ~/.zsh directory if it doesn't exist
    if [[ ! -d "$HOME/.zsh" ]]; then
        mkdir -p "$HOME/.zsh"
        print_success "Created ~/.zsh directory"
    fi
    
    # Create ~/.zsh/aliases.zsh
    print_info "Creating ~/.zsh/aliases.zsh..."
    cat > "$HOME/.zsh/aliases.zsh" << 'EOF'
# Enhanced eza aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -l --icons --group-directories-first --header'
alias la='eza -la --icons --group-directories-first --header'
alias lt='eza --tree --icons --level=2'
alias lsd='eza -lD --icons'  # Directories only
alias lsf='eza -lf --icons --color=always | grep -v /'  # Files only
alias lsize='eza -l --icons --sort=size --reverse'
alias ltime='eza -l --icons --sort=modified --reverse'
alias lg='eza -la --git --icons --group-directories-first'

# Neovim aliases
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias nv='nvim'
alias nvt='nvim -p'  # Open in tabs
alias view='nvim -R'  # Read-only mode

# Quick config editing
alias nvimrc='nvim ~/.config/nvim/init.vim'
alias zshrc='nvim ~/.zshrc'
alias bashrc='nvim ~/.bashrc'
EOF
    print_success "Created ~/.zsh/aliases.zsh"
    
    # Create ~/.zsh/functions.zsh
    print_info "Creating ~/.zsh/functions.zsh..."
    cat > "$HOME/.zsh/functions.zsh" << 'EOF'
# Fuzzy find and edit files with fzf + eza preview
vf() {
    local file
    file=$(eza -a --icons --color=always | fzf --ansi --preview 'if [[ -f {} ]]; then bat --color=always {}; else eza -la --icons --color=always {}; fi' --preview-window=right:60%)
    [[ -n "$file" ]] && nvim "$file"
}

# Fuzzy find from home directory
vfh() {
    local file
    cd ~
    file=$(eza -a --icons --color=always | fzf --ansi --preview 'if [[ -f {} ]]; then bat --color=always {}; else eza -la --icons --color=always {}; fi' --preview-window=right:60%)
    [[ -n "$file" ]] && nvim "$file"
    cd - > /dev/null
}

# Create directories if needed and edit file
nvedit() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: nvedit <file_path>"
        return 1
    fi
    
    local file_path="$1"
    local dir_path=$(dirname "$file_path")
    
    if [[ ! -d "$dir_path" ]]; then
        mkdir -p "$dir_path"
        echo "Created directory: $dir_path"
    fi
    
    nvim "$file_path"
}

# Neovim session management
nvs() {
    local session_dir="$HOME/.local/share/nvim/sessions"
    mkdir -p "$session_dir"
    
    if [[ $# -eq 0 ]]; then
        # List sessions
        echo "Available sessions:"
        ls -1 "$session_dir" | sed 's/\.vim$//'
    elif [[ "$1" == "save" ]]; then
        # Save session
        local session_name="${2:-default}"
        nvim -c "mksession! $session_dir/$session_name.vim" -c "qa"
        echo "Session saved: $session_name"
    elif [[ "$1" == "load" ]]; then
        # Load session
        local session_name="${2:-default}"
        if [[ -f "$session_dir/$session_name.vim" ]]; then
            nvim -S "$session_dir/$session_name.vim"
        else
            echo "Session not found: $session_name"
        fi
    else
        echo "Usage: nvs [save|load] [session_name]"
    fi
}

# List files with eza and pick one to edit
lv() {
    local file
    file=$(eza -la --icons --color=always | fzf --ansi --header-lines=1 | awk '{print $NF}')
    [[ -n "$file" ]] && nvim "$file"
}

# Tree view and pick file to edit
tv() {
    local file
    file=$(eza --tree --icons --color=always --level=3 | fzf --ansi | sed 's/^[│├└─ ]*//g')
    [[ -n "$file" ]] && nvim "$file"
}
EOF
    print_success "Created ~/.zsh/functions.zsh"
    
    # Update ~/.zshrc to source ~/.zsh/*.zsh files
    print_info "Updating ~/.zshrc to source ~/.zsh/*.zsh files..."
    
    # Check if the sourcing line already exists
    if ! grep -q "for config_file in ~/.zsh/\*.zsh" "$HOME/.zshrc" 2>/dev/null; then
        # Create a temp file with the new content at the top
        local temp_zshrc="/tmp/zshrc_temp_$$"
        
        # Add the new sourcing block at the beginning
        cat > "$temp_zshrc" << 'EOF'
# Load all zsh configuration files from ~/.zsh/
for config_file in ~/.zsh/*.zsh; do
    [[ -f "$config_file" ]] && source "$config_file"
done

EOF
        
        # Append existing .zshrc content if it exists
        if [[ -f "$HOME/.zshrc" ]]; then
            cat "$HOME/.zshrc" >> "$temp_zshrc"
        fi
        
        # Move temp file to .zshrc
        mv "$temp_zshrc" "$HOME/.zshrc"
        print_success "Updated ~/.zshrc to source ~/.zsh/*.zsh files"
    else
        print_success "~/.zshrc already sources ~/.zsh/*.zsh files"
    fi
    
    mark_complete "zsh_config"
    print_success "Zsh configuration for eza and nvim completed"
    return 0
}

# Run all pending tasks
run_all_tasks() {
    local tasks_run=false
    
    # Get sudo access upfront for all tasks
    if ! is_complete "homebrew" || ! is_complete "iterm2"; then
        echo ""
        print_info "Some tasks require administrator privileges"
        if ! verify_sudo_access; then
            print_error "Cannot continue without administrator access"
            read -p "Press Enter to continue..."
            return 1
        fi
        # Don't mark sudo as complete - it's per-session only
        tasks_run=true
        echo ""
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
    
    if ! is_complete "dev_tools"; then
        echo ""
        install_dev_tools
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "network_tools"; then
        echo ""
        install_network_tools
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "utility_tools"; then
        echo ""
        install_utility_tools
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "security_tools"; then
        echo ""
        install_security_tools
        tasks_run=true
        echo ""
        read -p "Press Enter to continue..."
    fi
    
    if ! is_complete "zsh_config"; then
        echo ""
        setup_zsh_config
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
                verify_sudo_access  # Don't mark as complete - it's per-session
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                echo ""
                install_dev_tools
                echo ""
                read -p "Press Enter to continue..."
                ;;
            7)
                echo ""
                install_network_tools
                echo ""
                read -p "Press Enter to continue..."
                ;;
            8)
                echo ""
                install_utility_tools
                echo ""
                read -p "Press Enter to continue..."
                ;;
            9)
                echo ""
                install_security_tools
                echo ""
                read -p "Press Enter to continue..."
                ;;
            10)
                echo ""
                setup_zsh_config
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