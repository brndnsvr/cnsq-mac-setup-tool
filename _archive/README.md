# CNSQ NetOps Mac Setup

Automated setup script for configuring macOS workstations for the CNSQ NetOps team.

## Quick Setup Commands

Run these commands in order on a fresh Mac:

**1. Install Xcode Command Line Tools**
```bash
xcode-select --install
```

**2. Install Homebrew**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**3. Add Homebrew to PATH (for Apple Silicon Macs)**
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

**4. Verify Homebrew installation**
```bash
brew --version
```

**5. Install iTerm2**
```bash
brew install --cask iterm2
```

**6. Clone this repository and run setup**
```bash
git clone https://github.com/brndnsvr/cnsq-mac-setup-tool.git
cd cnsq-mac-setup-tool/
chmod +x setup.sh
./setup.sh
```

## Overview

This script automates the installation and configuration of essential tools for network operations and automation on macOS. It provides a consistent development environment across all team members' machines with flexible installation modes and comprehensive command-line options.

## Features

- **Multiple installation modes**: Auto, Interactive, or Minimal
- **Command-line driven**: Full control via arguments
- **State management**: Automatic resume on interruption
- **Dry run mode**: Preview changes before making them
- **Architecture aware**: Supports both Apple Silicon (M1/M2/M3) and Intel Macs
- **Terminal fonts**: Includes Nerd Fonts with programming ligatures and icons
- **Comprehensive logging**: All actions logged to `~/cnsq-setup.log`
- **Backup system**: Creates backups before modifying existing files

## Prerequisites

- macOS 12.0 (Monterey) or later
- Administrator access (for Xcode Command Line Tools)
- Internet connection
- At least 5GB free disk space

## Quick Start

1. Clone or download this repository:
```bash
git clone https://github.com/brndnsvr/cnsq-mac-setup-tool.git
cd cnsq-mac-setup-tool/
```

2. Make the script executable:
```bash
chmod +x setup.sh
```

3. Run the setup script:
```bash
# Default installation (auto mode)
./setup.sh

# Or see all options
./setup.sh --help
```

## Installation Modes

### Auto Mode (Default)
```bash
./setup.sh
# or explicitly:
./setup.sh --mode auto
```
- Installs ALL packages automatically (no prompts)
- Includes all optional utilities
- Installs all 4 GUI apps (iTerm2, VS Code, AppCleaner, Wireshark)
- Installs all 5 Nerd Fonts
- Complete setup without interaction

### Interactive Mode
```bash
./setup.sh --mode interactive
```
- Same as Auto mode (installs everything automatically)
- No longer prompts for individual packages
- Complete installation without user interaction

### Minimal Mode
```bash
./setup.sh --mode minimal
```
- Core packages only
- No shell enhancements
- No GUI applications
- Fastest installation

## Command-Line Options

```bash
./setup.sh [OPTIONS]

OPTIONS:
  -h, --help              Show help message
  -v, --version           Show version information
  -m, --mode MODE         Installation mode (auto|interactive|minimal)
  -s, --skip-optional     Skip optional package installation
  -w, --windows           Launch installers in separate terminal windows
  -r, --no-resume         Disable resume capability (fresh install)
  --skip-optional        Skip optional GUI applications
  --verbose              Enable verbose output
  --dry-run              Show what would be installed without doing it
  --reset                Reset saved state and start fresh
```

## Usage Examples

```bash
# Preview what would be installed
./setup.sh --dry-run

# Interactive mode with verbose output
./setup.sh -m interactive --verbose

# Minimal installation, skip all optional packages
./setup.sh -m minimal -s

# Fresh install (ignore previous state)
./setup.sh --reset -r

# Launch installers in separate windows
./setup.sh -w

# See detailed logging
./setup.sh --verbose
```

## What Gets Installed

### Core Packages (All Modes)
- **Version Control**: Git
- **Editor**: Neovim
- **Terminal**: tmux
- **Languages**: Python 3
- **Automation**: Ansible
- **Utilities**: jq, ripgrep, tree

### Shell Enhancements (Auto & Interactive)
- **Modern CLI**: eza (better ls)
- **Syntax highlighting**: zsh-syntax-highlighting
- **Auto-suggestions**: zsh-autosuggestions

### Optional Packages (Auto & Interactive)
- **Development**: GitHub CLI, lazygit, pandoc, expect
- **System Monitoring**: htop, mactop, ncdu, fswatch
- **Network Tools**: wget, nmap, gping, sipcalc, httping, netcat, telnet, curl
- **Security**: ssh-audit, pwgen, ssh-copy-id
- **Core Utilities**: coreutils, watch, mas, ascii-image-converter

### GUI Applications (Non-minimal modes)
- **iTerm2**: Terminal emulator
- **Visual Studio Code**: Code editor
- **AppCleaner**: Complete application uninstaller
- **Wireshark**: Network protocol analyzer

### Terminal Fonts (Non-minimal modes)
All 5 Nerd Fonts are installed automatically:
- **FiraCode**: Programming ligatures and icons
- **Hack**: Clean and readable
- **JetBrains Mono**: Excellent for coding
- **Meslo LG**: Popular terminal font
- **Inconsolata**: Monospaced clarity
- **Features**: Programming ligatures, icons, powerline symbols
- **Benefits**: Enhanced readability, file type icons, git status symbols

### Python Environment
- Installs Python packages globally via pip3
- Includes: ansible, netmiko, napalm, paramiko, textfsm, pyyaml, jinja2, requests, cryptography
- Ready to use immediately after installation

### Ansible Collections
- **Core**: ansible.netcommon, ansible.utils, ansible.posix
- **Network** (non-minimal): cisco.ios, cisco.iosxr, junipernetworks.junos

## Configuration Details

### Shell Environment

The script configures Zsh with:
- Custom aliases (`ll`, `ls`, `vi` mapped to modern alternatives)
- Optimized history settings (10,000 entries)
- Python virtual environment aliases
- Git shortcuts (`gs`, `gp`, `gc`, `gd`, `gl`)

### Directory Structure

```
~/
├── .zsh/
│   └── aliases.zsh       # Command aliases
├── .cnsq-setup/         # Setup state management
├── .ansible/
│   ├── collections/      # Ansible collections
│   └── roles/           # Ansible roles
├── .config/
│   └── nvim/            # Neovim configuration
└── .cnsq-setup/         # Setup state files (if resume enabled)
```

### State Management

When resume is enabled (default), the script:
- Tracks completed steps in `~/.cnsq-setup/state`
- Can resume from interruption
- Skips already completed steps
- Use `--reset` to clear state and start fresh

## Post-Installation

After the script completes:

1. **Restart your terminal** or run:
   ```bash
   source ~/.zshrc
   ```

2. **Test Python packages**:
   ```bash
   python3 -c "import netmiko; print('netmiko installed')"
   ansible --version
   ```

3. **Configure terminal font** (if fonts installed):
   - Open iTerm2
   - Go to: iTerm2 → Settings → Profiles → Text
   - Select a Nerd Font (e.g., "Hack Nerd Font Mono")
   - Recommended size: 12-14pt

4. **Set iTerm2 as default** (if installed):
   - Go to: iTerm2 → Make iTerm2 Default Term

5. **Verify installation**:
   ```bash
   brew --version
   ansible --version
   python3 --version
   git --version
   ```

## Troubleshooting

### Script Fails at Xcode Installation
- Complete the Xcode Command Line Tools installation manually
- Rerun the script - it will skip already completed steps

### Homebrew Installation Issues
- On Apple Silicon Macs, ensure Rosetta 2 is installed:
  ```bash
  softwareupdate --install-rosetta
  ```

### Python Package Installation Errors
- Python packages are installed globally via pip3
- If problems persist, check the log file at `~/cnsq-setup.log`

### Resume Not Working
- Check state file: `cat ~/.cnsq-setup/state`
- Clear state and restart: `./setup.sh --reset`

### Want to See What Would Happen
- Use dry run mode: `./setup.sh --dry-run`
- Nothing will be installed, just displayed

## Testing

For testing in a clean environment:

1. **Use dry run first**: `./setup.sh --dry-run`
2. **Create a macOS VM** using UTM (free) or VMware Fusion
3. **Take a snapshot** before running the script
4. **Test different modes**:
   ```bash
   ./setup.sh -m minimal --dry-run
   ./setup.sh -m auto --dry-run
   ./setup.sh -m interactive --dry-run
   ```

## Logs and Backups

- **Log file**: `~/cnsq-setup.log` - Contains detailed installation information
- **Backups**: `~/.cnsq-backup-[timestamp]/` - Original files before modification
- **State**: `~/.cnsq-setup/state` - Installation progress (if resume enabled)

## Support

For issues or questions:
1. Check the log file for detailed error messages
2. Try verbose mode: `./setup.sh --verbose`
3. Use dry run to diagnose: `./setup.sh --dry-run`
4. Review the troubleshooting section above
5. Contact the NetOps team

## Version History

- **v4.0.0** (2025) - Unified single-script version
  - Consolidated all functionality into one script
  - Added command-line argument support
  - Multiple installation modes
  - Dry run capability
  - State management with resume

- **v1.0.0** (2025) - Initial release
  - Full automation for NetOps team setup
  - Support for Apple Silicon and Intel Macs
  - Comprehensive tool installation

## License

Internal use only - CNSQ NetOps Team

## Authors

CNSQ NetOps Team

---

*A unified, flexible setup script for consistent NetOps development environments across all macOS workstations.*
