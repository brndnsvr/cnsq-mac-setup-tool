#!/bin/bash

#############################################################################
# CNSQ NetOps Mac Setup Script - Unified Edition
# Version: 4.0.0
# Purpose: Complete macOS setup for NetOps team development
# Usage: ./setup.sh [OPTIONS]
#############################################################################

set -uo pipefail

#############################################################################
# Sudo Access Check - Verify user has admin privileges before proceeding
#############################################################################

verify_sudo_access() {
    local CYAN='\033[0;36m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local RED='\033[0;31m'
    local NC='\033[0m'
    local BOLD='\033[1m'
    
    echo -e "${CYAN}==>${NC} ${BOLD}Checking administrator privileges...${NC}"
    
    # Check if user is in admin group
    if ! groups | grep -q admin; then
        echo -e "${RED}[ERROR]${NC} You are not in the admin group."
        echo "This script requires administrator privileges."
        echo "Please contact your system administrator."
        exit 1
    fi
    
    # Test if we already have sudo access
    if sudo -n true 2>/dev/null; then
        echo -e "${GREEN}[✓]${NC} Administrator access confirmed (cached)"
        return 0
    fi
    
    # Inform user why we need sudo
    echo -e "${YELLOW}[INFO]${NC} This script needs administrator access to:"
    echo "  • Install Xcode Command Line Tools (if needed)"
    echo "  • Install and configure Homebrew"
    echo "  • Install system packages and applications"
    echo ""
    
    # Prompt for password
    echo "Please enter your password when prompted:"
    if ! sudo -v; then
        echo -e "${RED}[ERROR]${NC} Failed to authenticate."
        echo "Please ensure you have the correct password and try again."
        exit 1
    fi
    
    # Start background process to keep sudo alive
    ( while true; do sudo -n true; sleep 50; done ) &
    SUDO_PID=$!
    
    # Store PID for cleanup
    echo "$SUDO_PID" > /tmp/.cnsq-sudo-pid-$$
    
    echo -e "${GREEN}[✓]${NC} Administrator access verified successfully"
}

# Script version
SCRIPT_VERSION="4.0.0"

# Default configuration
MODE="auto"                    # auto, interactive, minimal
SKIP_OPTIONAL=false            # Skip optional packages
USE_VENV=true                 # Use Python virtual environment
SEPARATE_WINDOWS=false         # Launch installers in separate windows
RESUME_ENABLED=true           # Enable resume capability
VERBOSE=false                 # Verbose output
DRY_RUN=false                # Dry run mode

# Paths and files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/cnsq-setup.log"
STATE_DIR="$HOME/.cnsq-setup"
STATE_FILE="$STATE_DIR/state"
BACKUP_DIR="$HOME/.cnsq-backup-$(date +%Y%m%d-%H%M%S)"
VENV_PATH="$HOME/.cnsq-venv"

# Architecture detection
ARCH=$(uname -m)
HOMEBREW_PREFIX=$([[ "$ARCH" == "arm64" ]] && echo "/opt/homebrew" || echo "/usr/local")

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

#############################################################################
# Help and Usage
#############################################################################

show_help() {
    cat << EOF
${CYAN}CNSQ NetOps Mac Setup Script${NC}
Version: ${SCRIPT_VERSION}

${BOLD}USAGE:${NC}
    ./setup.sh [OPTIONS]

${BOLD}OPTIONS:${NC}
    -h, --help              Show this help message
    -v, --version           Show version information
    -m, --mode MODE         Installation mode (auto|interactive|minimal)
                           auto: Install with smart defaults
                           interactive: Prompt for all options
                           minimal: Core packages only
    -s, --skip-optional     Skip optional package installation
    -w, --windows           Launch installers in separate terminal windows
    -r, --no-resume         Disable resume capability (fresh install)
    --no-venv              Install Python packages globally (not recommended)
    --verbose              Enable verbose output
    --dry-run              Show what would be installed without doing it
    --reset                Reset saved state and start fresh

${BOLD}EXAMPLES:${NC}
    # Default installation (auto mode with resume)
    ./setup.sh

    # Interactive mode with separate windows
    ./setup.sh -m interactive -w

    # Minimal installation, skip optional packages
    ./setup.sh -m minimal -s

    # Fresh install without resume
    ./setup.sh -r --reset

    # Dry run to see what would be installed
    ./setup.sh --dry-run

${BOLD}PACKAGES INSTALLED:${NC}
    ${GREEN}Core:${NC} Homebrew, Git, Neovim, Tmux, Python3, Ansible
    ${BLUE}Shell:${NC} Zsh, Eza, Ripgrep, Tree
    ${YELLOW}Optional:${NC} iTerm2, Visual Studio Code, Terminal Fonts, and more

${BOLD}FILES CREATED:${NC}
    • ~/.zshrc (backed up if exists)
    • ~/.zsh/ (custom configurations)
    • ~/.cnsq-venv/ (Python virtual environment)
    • ~/.config/nvim/init.vim (Neovim config)

For more information, visit: https://github.com/cnsq/mac-setup
EOF
}

#############################################################################
# Argument Parsing
#############################################################################

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "CNSQ NetOps Mac Setup Script v${SCRIPT_VERSION}"
                exit 0
                ;;
            -m|--mode)
                MODE="$2"
                if [[ ! "$MODE" =~ ^(auto|interactive|minimal)$ ]]; then
                    echo "Error: Invalid mode '$MODE'. Use auto, interactive, or minimal."
                    exit 1
                fi
                shift 2
                ;;
            -s|--skip-optional)
                SKIP_OPTIONAL=true
                shift
                ;;
            -w|--windows)
                SEPARATE_WINDOWS=true
                shift
                ;;
            -r|--no-resume)
                RESUME_ENABLED=false
                shift
                ;;
            --no-venv)
                USE_VENV=false
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --reset)
                rm -rf "$STATE_DIR"
                echo "State reset. Starting fresh installation."
                shift
                ;;
            *)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

#############################################################################
# Logging Functions
#############################################################################

log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Always log to file
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    
    # Display based on level and verbosity
    case "$level" in
        ERROR)
            echo -e "${RED}[ERROR]${NC} $message" >&2
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓]${NC} $message"
            ;;
        WARNING)
            echo -e "${YELLOW}[WARNING]${NC} $message"
            ;;
        INFO)
            if [[ "$VERBOSE" == true ]] || [[ "$level" == "INFO" && "$MODE" != "minimal" ]]; then
                echo -e "${BLUE}[INFO]${NC} $message"
            fi
            ;;
        STEP)
            echo -e "\n${CYAN}==>${NC} ${BOLD}$message${NC}"
            ;;
        DEBUG)
            if [[ "$VERBOSE" == true ]]; then
                echo -e "${MAGENTA}[DEBUG]${NC} $message"
            fi
            ;;
        *)
            echo "$message"
            ;;
    esac
}

#############################################################################
# State Management
#############################################################################

init_state() {
    if [[ "$RESUME_ENABLED" == true ]]; then
        mkdir -p "$STATE_DIR"
        if [[ ! -f "$STATE_FILE" ]]; then
            echo "# CNSQ Setup State File" > "$STATE_FILE"
            echo "# Started: $(date)" >> "$STATE_FILE"
        fi
    fi
}

save_state() {
    if [[ "$RESUME_ENABLED" == true && "$DRY_RUN" == false ]]; then
        local step="$1"
        local status="$2"
        echo "${step}:${status}:$(date +%s)" >> "$STATE_FILE"
        log DEBUG "State saved: $step = $status"
    fi
}

check_state() {
    if [[ "$RESUME_ENABLED" == true && -f "$STATE_FILE" ]]; then
        local step="$1"
        grep -q "^${step}:COMPLETE:" "$STATE_FILE" 2>/dev/null
    else
        return 1
    fi
}

#############################################################################
# System Checks
#############################################################################

check_prerequisites() {
    log STEP "Checking prerequisites..."
    
    # Check macOS version
    local macos_version=$(sw_vers -productVersion)
    log INFO "macOS version: $macos_version"
    
    # Check architecture
    log INFO "Architecture: $ARCH"
    
    # Check internet
    if ! ping -c 1 8.8.8.8 &>/dev/null; then
        log ERROR "No internet connection detected"
        exit 1
    fi
    log SUCCESS "Internet connection available"
    
    # Check disk space
    local available_gb=$(df -g / | awk 'NR==2 {print $4}')
    if [[ $available_gb -lt 5 ]]; then
        log ERROR "Insufficient disk space. Required: 5GB, Available: ${available_gb}GB"
        exit 1
    fi
    log SUCCESS "Sufficient disk space (${available_gb}GB)"
    
    # Check Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        log WARNING "Xcode Command Line Tools not found"
        if [[ "$DRY_RUN" == false ]]; then
            log INFO "Installing Xcode Command Line Tools..."
            xcode-select --install
            echo "Please complete the installation in the popup window, then press Enter..."
            read -r
        fi
    fi
    log SUCCESS "All prerequisites met"
}

#############################################################################
# Process Management for Separate Windows
#############################################################################

launch_in_new_window() {
    local script_content="$1"
    local window_title="$2"
    
    if [[ "$SEPARATE_WINDOWS" != true ]]; then
        # Run inline if not using separate windows
        bash -c "$script_content"
        return $?
    fi
    
    # Create temporary script
    local temp_script="/tmp/cnsq-installer-$$.sh"
    echo "#!/bin/bash" > "$temp_script"
    echo "$script_content" >> "$temp_script"
    chmod +x "$temp_script"
    
    # Try to open in available terminal
    if [[ -d "/Applications/iTerm.app" ]]; then
        osascript -e "tell application \"iTerm\"
            create window with default profile
            tell current session of current window
                write text \"$temp_script && rm -f $temp_script\"
            end tell
        end tell" 2>/dev/null || bash "$temp_script"
    elif [[ -d "/Applications/Terminal.app" ]]; then
        osascript -e "tell application \"Terminal\"
            do script \"$temp_script && rm -f $temp_script\"
        end tell" 2>/dev/null || bash "$temp_script"
    else
        # Fallback to current terminal
        bash "$temp_script"
    fi
    
    # Wait for completion marker
    local marker="/tmp/cnsq-complete-$$"
    local timeout=300
    local elapsed=0
    
    if [[ "$SEPARATE_WINDOWS" == true ]]; then
        echo -n "Waiting for $window_title to complete"
        while [[ ! -f "$marker" && $elapsed -lt $timeout ]]; do
            echo -n "."
            sleep 2
            elapsed=$((elapsed + 2))
        done
        echo ""
        rm -f "$marker"
    fi
}

#############################################################################
# Installation Functions
#############################################################################

install_homebrew() {
    log STEP "Setting up Homebrew..."
    
    if check_state "HOMEBREW"; then
        log INFO "Homebrew already set up (cached)"
        return 0
    fi
    
    if command -v brew &>/dev/null; then
        log SUCCESS "Homebrew already installed"
        [[ "$DRY_RUN" == false ]] && brew update
        save_state "HOMEBREW" "COMPLETE"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY RUN] Would install Homebrew"
        return 0
    fi
    
    local install_script='
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Homebrew installation complete"
        touch /tmp/cnsq-complete-$$
    '
    
    if [[ "$MODE" == "interactive" ]] || [[ "$SEPARATE_WINDOWS" == true ]]; then
        launch_in_new_window "$install_script" "Homebrew Installation"
    else
        eval "$install_script"
    fi
    
    # Add to PATH
    eval "$($HOMEBREW_PREFIX/bin/brew shellenv)" 2>/dev/null || true
    
    save_state "HOMEBREW" "COMPLETE"
    log SUCCESS "Homebrew installed"
}

install_packages() {
    log STEP "Installing packages..."
    
    if check_state "PACKAGES"; then
        log INFO "Packages already installed (cached)"
        return 0
    fi
    
    # Core packages (always installed)
    local core_packages=(
        "git"
        "neovim"
        "tmux"
        "python@3"
        "ansible"
        "jq"
        "ripgrep"
        "tree"
    )
    
    # Shell enhancement packages
    local shell_packages=(
        "eza"
        "zsh-syntax-highlighting"
        "zsh-autosuggestions"
    )
    
    # Optional packages
    local optional_packages=(
        "gh"
        "lazygit"
        "htop"
        "wget"
        "watch"
        "nmap"
        "gping"
        "mactop"
        "ncdu"
        "pandoc"
        "ssh-audit"
        "pwgen"
        "sipcalc"
        "ascii-image-converter"
        "coreutils"
        "curl"
        "expect"
        "fswatch"
        "httping"
        "netcat"
        "telnet"
        "ssh-copy-id"
        "mas"
    )
    
    # Combine package lists based on mode
    local packages_to_install=("${core_packages[@]}")
    
    if [[ "$MODE" != "minimal" ]]; then
        packages_to_install+=("${shell_packages[@]}")
    fi
    
    # Always install all optional packages unless minimal mode or explicitly skipped
    if [[ "$SKIP_OPTIONAL" != true && "$MODE" != "minimal" ]]; then
        packages_to_install+=("${optional_packages[@]}")
    fi
    
    # Install packages
    for package in "${packages_to_install[@]}"; do
        if [[ "$DRY_RUN" == true ]]; then
            log INFO "[DRY RUN] Would install $package"
        elif brew list "$package" &>/dev/null; then
            log DEBUG "$package already installed"
        else
            log INFO "Installing $package..."
            brew install "$package" || log WARNING "Failed to install $package"
        fi
    done
    
    save_state "PACKAGES" "COMPLETE"
    log SUCCESS "Package installation complete"
}

setup_python() {
    log STEP "Setting up Python environment..."
    
    if check_state "PYTHON"; then
        log INFO "Python environment already set up (cached)"
        return 0
    fi
    
    local python_packages=(
        "paramiko"
        "cryptography"
        "pyyaml"
        "jinja2"
        "requests"
        "ansible-core"
    )
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY RUN] Would set up Python environment"
        [[ "$USE_VENV" == true ]] && log INFO "[DRY RUN] Would create virtual environment at $VENV_PATH"
        for pkg in "${python_packages[@]}"; do
            log INFO "[DRY RUN] Would install Python package: $pkg"
        done
        return 0
    fi
    
    if [[ "$USE_VENV" == true ]]; then
        # Use virtual environment
        if [[ ! -d "$VENV_PATH" ]]; then
            log INFO "Creating Python virtual environment..."
            python3 -m venv "$VENV_PATH"
        fi
        
        log INFO "Installing Python packages in virtual environment..."
        "$VENV_PATH/bin/pip" install --quiet --upgrade pip
        
        for package in "${python_packages[@]}"; do
            "$VENV_PATH/bin/pip" install --quiet "$package" || log WARNING "Failed to install $package"
        done
    else
        # Use system Python (not recommended on macOS)
        log WARNING "Installing Python packages globally (not recommended)"
        for package in "${python_packages[@]}"; do
            python3 -m pip install --user "$package" || log WARNING "Failed to install $package"
        done
    fi
    
    save_state "PYTHON" "COMPLETE"
    log SUCCESS "Python environment configured"
}

setup_ansible() {
    log STEP "Setting up Ansible..."
    
    if check_state "ANSIBLE"; then
        log INFO "Ansible already set up (cached)"
        return 0
    fi
    
    local collections=(
        "ansible.netcommon"
        "ansible.utils"
        "ansible.posix"
    )
    
    if [[ "$MODE" != "minimal" ]]; then
        collections+=(
            "cisco.ios"
            "cisco.iosxr"
            "junipernetworks.junos"
        )
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY RUN] Would install Ansible collections"
        for collection in "${collections[@]}"; do
            log INFO "[DRY RUN] Would install collection: $collection"
        done
        return 0
    fi
    
    # Create Ansible directories
    mkdir -p "$HOME/.ansible/roles"
    mkdir -p "$HOME/.ansible/collections"
    
    # Install collections
    for collection in "${collections[@]}"; do
        log INFO "Installing Ansible collection: $collection"
        ansible-galaxy collection install "$collection" --force || log WARNING "Failed to install $collection"
    done
    
    save_state "ANSIBLE" "COMPLETE"
    log SUCCESS "Ansible configured"
}

configure_shell() {
    log STEP "Configuring shell environment..."
    
    if check_state "SHELL"; then
        log INFO "Shell already configured (cached)"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY RUN] Would configure shell environment"
        log INFO "[DRY RUN] Would backup and append to ~/.zshrc"
        log INFO "[DRY RUN] Would create ~/.zsh/ directory with custom configs"
        return 0
    fi
    
    # Backup existing .zshrc if it exists
    if [[ -f "$HOME/.zshrc" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp "$HOME/.zshrc" "$BACKUP_DIR/.zshrc.backup"
        log INFO "Backed up existing .zshrc to $BACKUP_DIR"
    fi
    
    # Create .zsh directory for modular configs
    mkdir -p "$HOME/.zsh"
    
    # Create CNSQ configuration file (always in separate file)
    cat > "$HOME/.zsh/cnsq-config.zsh" << 'EOF'
# CNSQ NetOps Shell Configuration
# This file is managed by the CNSQ setup script

# Homebrew configuration
EOF
    echo "eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\" 2>/dev/null || true" >> "$HOME/.zsh/cnsq-config.zsh"
    
    if [[ "$USE_VENV" == true ]]; then
        cat >> "$HOME/.zsh/cnsq-config.zsh" << 'EOF'

# Python virtual environment aliases
alias cnsq-env='source $HOME/.cnsq-venv/bin/activate'
alias cnsq-python='source $HOME/.cnsq-venv/bin/activate && python'
EOF
    fi
    
    # Only add history config if not already present in .zshrc
    if ! grep -q "HISTSIZE" "$HOME/.zshrc" 2>/dev/null; then
        cat >> "$HOME/.zsh/cnsq-config.zsh" << 'EOF'

# History configuration
export HISTSIZE=10000
export SAVEHIST=20000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
export HISTFILE=~/.zsh_history
EOF
    fi
    
    # Add loader for .zsh directory files
    cat >> "$HOME/.zsh/cnsq-config.zsh" << 'EOF'

# Load other zsh configurations
for config in $HOME/.zsh/*.zsh(N); do
    # Skip self to avoid recursion
    [[ "$config" == "$HOME/.zsh/cnsq-config.zsh" ]] && continue
    source "$config"
done

# iTerm2 integration (if available)
[[ -f "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"
EOF
    
    # Create aliases file (only if it doesn't exist)
    if [[ ! -f "$HOME/.zsh/aliases.zsh" ]]; then
        log INFO "Creating aliases file"
        cat > "$HOME/.zsh/aliases.zsh" << 'EOF'
# CNSQ NetOps Aliases

# Safety nets
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Git shortcuts
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias gd='git diff'
alias gl='git log --oneline --graph'
EOF
    
    if [[ "$MODE" != "minimal" ]]; then
        cat >> "$HOME/.zsh/aliases.zsh" << 'EOF'

# Modern replacements
alias ll='eza -lh --git --group-directories-first --icons'
alias ls='eza --icons'
alias tree='eza --tree --icons'
alias vi='nvim'
alias vim='nvim'
EOF
        fi
    else
        log INFO "Aliases file already exists, preserving user customizations"
    fi
    
    # Create functions file (only if it doesn't exist)
    if [[ ! -f "$HOME/.zsh/functions.zsh" ]]; then
        log INFO "Creating functions file"
        cat > "$HOME/.zsh/functions.zsh" << 'EOF'
# CNSQ NetOps Functions

# Weather lookup
weather() {
  case $1 in
    nyc)     curl "wttr.in/New+York+NY?u" ;;
    dallas)  curl "wttr.in/Dallas+TX?u" ;;
    la)      curl "wttr.in/Los+Angeles+CA?u" ;;
    chicago) curl "wttr.in/Chicago+IL?u" ;;
    *)       echo "Usage: weather {nyc|dallas|la|chicago}" ;;
  esac
}

# Initialize SSH agent and load keys
init_ssh_agent() {
  if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
  fi
  
  if [ -f "$SSHKEYPATH" ]; then
    ssh-add "$SSHKEYPATH"
  else
    echo "SSH key not found at $SSHKEYPATH"
  fi
}

# Quick SSH with common username
sshto() {
  if [ -z "$1" ]; then
    echo "Usage: sshto <hostname or IP>"
    return 1
  fi
  ssh "${SSHUSER:-$USER}@$1"
}

# Ping multiple hosts
pingall() {
  for host in "$@"; do
    echo -n "$host: "
    ping -c 1 -W 1 "$host" &>/dev/null && echo "✓ UP" || echo "✗ DOWN"
  done
}

# Make directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Show listening ports
ports() {
  if [ "$1" = "-a" ]; then
    sudo lsof -i -P -n
  else
    sudo lsof -i -P -n | grep LISTEN
  fi
}

# Show IP addresses
myip() {
  echo "Local:    $(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1)"
  echo "External: $(curl -s ifconfig.me)"
}

# Universal archive extractor
extract() {
  if [ -f "$1" ]; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
EOF
    else
        log INFO "Functions file already exists, preserving user customizations"
    fi
    
    # Configure Neovim (only if config doesn't exist)
    if [[ ! -f "$HOME/.config/nvim/init.vim" ]]; then
        log INFO "Creating Neovim configuration"
        mkdir -p "$HOME/.config/nvim"
        cat > "$HOME/.config/nvim/init.vim" << 'EOF'
" CNSQ NetOps Neovim Configuration
set number
set relativenumber
set expandtab
set tabstop=2
set shiftwidth=2
set autoindent
set smartindent
set clipboard=
set mouse=
EOF
    else
        log INFO "Neovim config already exists, preserving user customizations"
    fi
    
    # Add CNSQ config to .zshrc (append only, never overwrite)
    # Check if we need to add our configuration to .zshrc
    if ! grep -q "source.*cnsq-config.zsh" "$HOME/.zshrc" 2>/dev/null; then
        log INFO "Adding CNSQ configuration to .zshrc"
        
        # Create .zshrc if it doesn't exist
        if [[ ! -f "$HOME/.zshrc" ]]; then
            echo "# Zsh configuration file" > "$HOME/.zshrc"
            echo "" >> "$HOME/.zshrc"
        fi
        
        # Append our configuration source line
        cat >> "$HOME/.zshrc" << 'EOF'

# CNSQ NetOps Setup - Added by setup script
# Source CNSQ configurations if they exist
[[ -f "$HOME/.zsh/cnsq-config.zsh" ]] && source "$HOME/.zsh/cnsq-config.zsh"
EOF
        log SUCCESS "Added CNSQ configuration to .zshrc"
    else
        log INFO "CNSQ configuration already present in .zshrc"
    fi
    
    save_state "SHELL" "COMPLETE"
    log SUCCESS "Shell environment configured"
}

install_gui_apps() {
    log STEP "Installing GUI applications..."
    
    if [[ "$MODE" == "minimal" ]] || [[ "$SKIP_OPTIONAL" == true ]]; then
        log INFO "Skipping GUI applications (minimal mode or --skip-optional)"
        return 0
    fi
    
    if check_state "GUI_APPS"; then
        log INFO "GUI applications already installed (cached)"
        return 0
    fi
    
    local gui_apps=(
        "iterm2:Terminal emulator"
        "visual-studio-code:Code editor"
        "appcleaner:Application uninstaller"
        "wireshark:Network protocol analyzer"
    )
    
    # Install all GUI apps without prompting
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY RUN] Would install all GUI applications"
    else
        for app_desc in "${gui_apps[@]}"; do
            IFS=':' read -r app description <<< "$app_desc"
            log INFO "Installing $app ($description)..."
            brew install --cask "$app" || log WARNING "Failed to install $app"
        done
    fi
    
    save_state "GUI_APPS" "COMPLETE"
    log SUCCESS "GUI applications installation complete"
}

install_terminal_fonts() {
    log STEP "Installing terminal fonts..."
    
    if [[ "$MODE" == "minimal" ]] || [[ "$SKIP_OPTIONAL" == true ]]; then
        log INFO "Skipping terminal fonts (minimal mode or --skip-optional)"
        return 0
    fi
    
    if check_state "TERMINAL_FONTS"; then
        log INFO "Terminal fonts already installed (cached)"
        return 0
    fi
    
    # Popular Nerd Fonts for programming
    local nerd_fonts=(
        "font-fira-code-nerd-font:Ligatures and icons"
        "font-hack-nerd-font:Clean and readable"
        "font-jetbrains-mono-nerd-font:Excellent for coding"
        "font-meslo-lg-nerd-font:Popular terminal font"
        "font-inconsolata-nerd-font:Monospaced clarity"
    )
    
    # Install all Nerd Fonts without prompting
    echo -e "\n${CYAN}Installing terminal fonts (Nerd Fonts with icons and ligatures)...${NC}"
    
    if [[ "$DRY_RUN" == true ]]; then
        log INFO "[DRY RUN] Would install all Nerd Fonts"
    else
        for font_desc in "${nerd_fonts[@]}"; do
            IFS=':' read -r font description <<< "$font_desc"
            log INFO "Installing $font ($description)..."
            brew install --cask "$font" || log WARNING "Failed to install $font"
        done
    fi
    
    save_state "TERMINAL_FONTS" "COMPLETE"
    log SUCCESS "Terminal fonts installation complete"
}


#############################################################################
# Summary and Verification
#############################################################################

verify_installation() {
    log STEP "Verifying installation..."
    
    local checks_passed=0
    local checks_failed=0
    
    # Check commands
    local commands_to_check=("brew" "git" "python3")
    
    [[ "$MODE" != "minimal" ]] && commands_to_check+=("nvim" "tmux" "ansible")
    
    for cmd in "${commands_to_check[@]}"; do
        if command -v "$cmd" &>/dev/null; then
            log SUCCESS "$cmd is available"
            ((checks_passed++))
        else
            log ERROR "$cmd is not available"
            ((checks_failed++))
        fi
    done
    
    # Check Python environment
    if [[ "$USE_VENV" == true && -d "$VENV_PATH" ]]; then
        log SUCCESS "Python virtual environment exists"
        ((checks_passed++))
    elif [[ "$USE_VENV" == false ]]; then
        log INFO "Python packages installed globally"
        ((checks_passed++))
    else
        log WARNING "Python virtual environment not found"
        ((checks_failed++))
    fi
    
    if [[ $checks_failed -eq 0 ]]; then
        log SUCCESS "All verification checks passed! ($checks_passed/$checks_passed)"
    else
        log WARNING "Some checks failed ($checks_failed failed, $checks_passed passed)"
    fi
}

show_summary() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════╗"
    echo -e "║                                                          ║"
    echo -e "║              🎉 Installation Complete! 🎉               ║"
    echo -e "║                                                          ║"
    echo -e "╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}Installation Summary:${NC}"
    echo "  • Mode: $MODE"
    echo "  • Log file: $LOG_FILE"
    [[ -d "$BACKUP_DIR" ]] && echo "  • Backups: $BACKUP_DIR"
    [[ "$USE_VENV" == true ]] && echo "  • Python venv: $VENV_PATH"
    
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    
    [[ "$USE_VENV" == true ]] && echo "  2. Activate Python environment: cnsq-env"
    
    if [[ -d "/Applications/iTerm.app" ]]; then
        echo "  3. Open iTerm2 and set as default terminal"
        echo "  4. In iTerm2 > Preferences > Profiles > Text, select a Nerd Font"
    fi
    
    echo ""
    echo -e "${GREEN}Your NetOps development environment is ready!${NC}"
}

#############################################################################
# Main Execution
#############################################################################

main() {
    # Parse command-line arguments
    parse_arguments "$@"
    
    # Verify sudo access (skip for dry run or help)
    if [[ "$DRY_RUN" == false ]]; then
        verify_sudo_access
    fi
    
    # Initialize
    echo "CNSQ NetOps Setup v${SCRIPT_VERSION} - Started at $(date)" > "$LOG_FILE"
    
    # Initialize state management
    init_state
    
    # Check for resume
    if [[ "$RESUME_ENABLED" == true && -f "$STATE_FILE" && "$DRY_RUN" == false ]]; then
        echo -e "${YELLOW}Previous installation detected.${NC}"
        echo -n "Resume from where you left off? (y/n): "
        read -r resume
        if [[ ! "$resume" =~ ^[Yy]$ ]]; then
            rm -rf "$STATE_DIR"
            init_state
        fi
    fi
    
    # Show welcome
    if [[ ! -f "$STATE_FILE" ]] || [[ "$DRY_RUN" == true ]]; then
        echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║         CNSQ NetOps Mac Setup - Unified Edition         ║${NC}"
        echo -e "${CYAN}║                    Version ${SCRIPT_VERSION}                     ║${NC}"
        echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo "Mode: $MODE"
        [[ "$DRY_RUN" == true ]] && echo -e "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
        echo ""
        
        if [[ "$MODE" == "interactive" ]]; then
            echo -n "Ready to begin? (y/n): "
            read -r response
            [[ ! "$response" =~ ^[Yy]$ ]] && exit 0
        fi
    fi
    
    # Create backup directory if needed
    [[ "$DRY_RUN" == false ]] && mkdir -p "$BACKUP_DIR"
    
    # Run installation steps
    check_prerequisites
    install_homebrew
    install_packages
    setup_python
    setup_ansible
    configure_shell
    install_gui_apps
    install_terminal_fonts
    
    # Verification and summary
    [[ "$DRY_RUN" == false ]] && verify_installation
    show_summary
    
    # Clean up state if successful
    [[ "$DRY_RUN" == false && "$RESUME_ENABLED" == true ]] && rm -rf "$STATE_DIR"
    
    log SUCCESS "Setup completed at $(date)"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    
    # Kill the sudo keepalive process if it exists
    if [[ -f "/tmp/.cnsq-sudo-pid-$$" ]]; then
        local pid=$(cat "/tmp/.cnsq-sudo-pid-$$" 2>/dev/null)
        if [[ -n "$pid" ]]; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "/tmp/.cnsq-sudo-pid-$$"
    fi
    
    # Show message if interrupted
    if [[ $exit_code -ne 0 ]] && [[ $exit_code -ne 130 ]]; then
        echo -e "\n${YELLOW}Installation interrupted. Run with --help for options.${NC}"
    fi
}

# Trap interruptions and exits
trap cleanup EXIT INT TERM

# Run main function
main "$@"