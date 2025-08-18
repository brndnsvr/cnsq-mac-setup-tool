# CNSQ NetOps Mac Setup - Complete Overview

## Table of Contents
1. [What This Script Does](#what-this-script-does)
2. [Pre-Installation Requirements](#pre-installation-requirements)
3. [Installation Process](#installation-process)
4. [Complete Application List](#complete-application-list)
5. [Shell Environment Configuration](#shell-environment-configuration)
6. [Post-Installation](#post-installation)
7. [Safety Features](#safety-features)

---

## What This Script Does

The `setup.sh` script is a comprehensive, **non-destructive** macOS setup automation tool designed specifically for Network Operations teams. It installs and configures a complete development and network management environment.

### Key Features
- ✅ **Non-destructive**: Never overwrites existing configurations
- ✅ **Resumable**: Can continue from interruptions
- ✅ **Modular**: Configurations stored in `~/.zsh/` directory
- ✅ **Safe**: Creates backups before any modifications
- ✅ **Automatic**: Installs everything without prompts (in default mode)
- ✅ **NetOps Focused**: Optimized for network engineering workflows

---

## Pre-Installation Requirements

### System Requirements
- macOS 12.0 (Monterey) or later
- 5GB free disk space
- Internet connection
- Administrator access (sudo)

### Automatic Checks
The script automatically:
1. Verifies sudo access before starting
2. Checks for Xcode Command Line Tools
3. Validates internet connectivity
4. Ensures sufficient disk space
5. Detects system architecture (Intel/Apple Silicon)

---

## Installation Process

### Quick Start
```bash
# Clone the repository
git clone <repository-url>
cd cnsq-mac-setup

# Run the setup
./setup.sh
```

### Installation Modes

#### Auto Mode (Default)
- Installs all 68 packages automatically
- No user interaction required
- Complete NetOps environment setup

#### Minimal Mode
```bash
./setup.sh --mode minimal
```
- Core packages only (18 total)
- No GUI apps or fonts
- Basic functionality

#### Dry Run Mode
```bash
./setup.sh --dry-run
```
- Shows what would be installed
- Makes no actual changes
- Useful for reviewing

---

## Complete Application List

### Summary: 68 Total Applications

| Category | Count | Description |
|----------|-------|-------------|
| **Homebrew Packages** | 43 | Command-line tools and utilities |
| **GUI Applications** | 4 | iTerm2, VS Code, AppCleaner, Wireshark |
| **Terminal Fonts** | 5 | Nerd Fonts with ligatures and icons |
| **Python Packages** | 10 | Network automation libraries |
| **Ansible Collections** | 6 | Network vendor modules |

### Detailed Breakdown

#### 🛠️ Core Tools (Always Installed)
- **git** - Version control
- **neovim** - Modern text editor
- **tmux** - Terminal multiplexer
- **python@3** - Python runtime
- **ansible** - Automation framework
- **jq** - JSON processor
- **ripgrep** - Fast search tool
- **tree** - Directory visualizer

#### 🌐 Network Diagnostics
- **mtr** - Combined ping/traceroute
- **fping** - Fast multi-host ping
- **iperf3** - Bandwidth testing
- **socat** - Port forwarding/tunnels
- **whois** - Domain/IP lookup
- **arp-scan** - Layer 2 discovery
- **ngrep** - Network packet grep
- **gping** - Graphical ping
- **nmap** - Network mapper
- **netcat** - TCP/UDP utility
- **telnet** - Legacy device access

#### 🔍 DNS & SNMP Tools
- **ldns** - Advanced DNS debugging (includes drill)
- **net-snmp** - SNMP utilities (snmpwalk, snmpget)

#### 📡 Serial/Console Access
- **minicom** - Serial communication for routers/switches
- **lrzsz** - ZMODEM file transfer over serial

#### 🔐 Security & SSH
- **ssh-audit** - SSH configuration auditor
- **ssh-copy-id** - SSH key deployment
- **pwgen** - Secure password generator

#### 📦 File & Archive Tools
- **p7zip** - 7-Zip archive support
- **unrar** - RAR archive support
- **coreutils** - GNU core utilities

#### 🖥️ GUI Applications
- **iTerm2** - Advanced terminal emulator
- **Visual Studio Code** - Code editor
- **AppCleaner** - Complete app uninstaller
- **Wireshark** - Network protocol analyzer (includes tshark CLI)

#### 🔤 Terminal Fonts (All 5 Nerd Fonts)
- **FiraCode Nerd Font** - Programming ligatures
- **Hack Nerd Font** - Clean and readable
- **JetBrains Mono Nerd Font** - IDE-optimized
- **Meslo LG Nerd Font** - Apple-style
- **Inconsolata Nerd Font** - Monospaced clarity

#### 🐍 Python Network Libraries
- **netmiko** - Multi-vendor SSH library
- **napalm** - Network automation abstraction
- **textfsm** - CLI output parser
- **paramiko** - SSH2 protocol library
- **pyyaml** - YAML parser
- **jinja2** - Template engine
- **requests** - HTTP library
- **cryptography** - Security operations

#### 📚 Ansible Collections
- **ansible.netcommon** - Network common modules
- **ansible.utils** - Utility modules
- **ansible.posix** - POSIX system modules
- **cisco.ios** - Cisco IOS modules
- **cisco.iosxr** - Cisco IOS XR modules
- **junipernetworks.junos** - Juniper modules

---

## Shell Environment Configuration

### Directory Structure Created
```
~/
├── .zsh/                      # All custom configurations
│   ├── cnsq-config.zsh       # Main CNSQ configuration
│   ├── aliases.zsh           # Command aliases
│   └── functions.zsh         # Shell functions
├── .zshrc                    # Modified to source .zsh/ configs
├── .cnsq-venv/              # Python virtual environment
└── .config/nvim/init.vim   # Neovim configuration
```

### Zsh Enhancements

#### Enhanced History
- 50,000 entry history (increased from default)
- Duplicate prevention
- Shared between sessions
- Ignores commands starting with space

#### Shell Options
- **AUTO_CD** - Type directory name to cd
- **CORRECT** - Command spelling correction
- **NO_BEEP** - Silent operation
- **Better completion** - Case-insensitive, menu selection
- **PATH deduplication** - Automatic cleanup

#### Network-Focused Aliases
```bash
# Network shortcuts
listening      # Show listening ports
openports      # Show open ports
showip         # Display external IP
ping6          # IPv6 ping

# Process management
topmem         # Top 10 memory consumers
topcpu         # Top 10 CPU consumers
psg <pattern>  # Grep processes

# Quick edits
zshrc          # Edit ~/.zshrc
hosts          # Edit /etc/hosts

# Ansible shortcuts
ap             # ansible-playbook
av             # ansible-vault
ag             # ansible-galaxy
```

#### NetOps Functions
```bash
# Network testing
nettest        # Test gateway, DNS, internet connectivity
netinfo        # Display all network interface info
testport       # Test TCP port: testport host port
dnscheck       # Query multiple DNS servers
routes         # Show IPv4/IPv6 routing tables

# Utilities
mssh           # SSH to multiple hosts in tmux
backup         # Backup file with timestamp
portuser       # Find process using port
extract        # Universal archive extractor

# Enhanced functions
pingall        # Ping multiple hosts
myip           # Show local and external IP
weather        # Get weather for major cities
```

### Environment Variables Set
- `EDITOR='nvim'` - Default editor
- `VISUAL='nvim'` - Visual editor
- `HISTFILE=~/.zsh_history` - History location
- `LESS` options for better paging
- Colored man pages

---

## Post-Installation

### Automatic Configuration
After installation, the script:
1. ✅ Backs up existing configurations
2. ✅ Creates modular zsh config structure
3. ✅ Sets up Python virtual environment
4. ✅ Configures Ansible directories
5. ✅ Installs all Ansible collections
6. ✅ Configures Neovim

### Manual Steps Required

#### 1. Restart Terminal
```bash
source ~/.zshrc
# Or simply close and reopen terminal
```

#### 2. Configure Wireshark for Non-Root Capture
```bash
sudo dseditgroup -o edit -a $(whoami) -t user access_bpf
# Then logout and login again
```

#### 3. Select Terminal Font
In iTerm2:
- Go to Settings → Profiles → Text
- Select a Nerd Font (e.g., "Hack Nerd Font Mono")
- Recommended size: 12-14pt

#### 4. Activate Python Environment (When Needed)
```bash
cnsq-env  # Alias to activate virtual environment
```

---

## Safety Features

### Backup System
- Creates timestamped backups in `~/.cnsq-backup-YYYYMMDD-HHMMSS/`
- Backs up `.zshrc` before modification
- Preserves all existing configurations

### Non-Destructive Installation
- **Never overwrites** existing `.zshrc` (only appends)
- **Checks before creating** files in `~/.zsh/`
- **Preserves user customizations**
- **Safe to run multiple times**

### State Management
- Resume capability if interrupted
- Tracks completed steps
- Can reset with `--reset` flag

### Sudo Management
- Verifies admin access before starting
- Keeps sudo alive during installation
- Proper cleanup on exit

### What Gets Added to .zshrc
Only this single block (if not present):
```bash
## Source custom functions and aliases from ~/.zsh directory
if [ -d "$HOME/.zsh" ]; then
  for config_file in "$HOME/.zsh/"*.zsh; do
    source "$config_file"
  done
fi
```

---

## Command Reference

### Script Options
```bash
./setup.sh [OPTIONS]

OPTIONS:
  -h, --help              Show help message
  -v, --version           Show version
  -m, --mode MODE         Installation mode (auto|minimal)
  -s, --skip-optional     Skip optional packages
  -r, --no-resume         Disable resume capability
  --verbose              Enable verbose output
  --dry-run              Preview without installing
  --reset                Clear saved state
```

### Verification
After installation, verify with:
```bash
# Check installations
brew --version
ansible --version
python3 --version
nvim --version

# Test network functions
nettest        # Test connectivity
netinfo        # Show network config
which tshark   # Verify Wireshark CLI
```

---

## Troubleshooting

### Common Issues

#### Homebrew Installation Fails
- Ensure Xcode Command Line Tools are installed
- Check internet connectivity
- Verify disk space

#### Python Package Errors
- Virtual environment is at `~/.cnsq-venv/`
- Activate with `cnsq-env` alias
- Check logs at `~/cnsq-setup.log`

#### Zsh Configuration Issues
- Backup stored in `~/.cnsq-backup-*/`
- Remove CNSQ config: Delete `~/.zsh/cnsq-config.zsh`
- Remove from .zshrc: Delete the source block

### Log Files
- Installation log: `~/cnsq-setup.log`
- State file: `~/.cnsq-setup/state`

### Getting Help
1. Check the log file for errors
2. Run with `--verbose` for detailed output
3. Use `--dry-run` to preview changes
4. Review backups in `~/.cnsq-backup-*/`

---

## Files Created/Modified

### Created
- `~/.zsh/cnsq-config.zsh` - Main configuration
- `~/.zsh/aliases.zsh` - Command aliases
- `~/.zsh/functions.zsh` - Shell functions
- `~/.cnsq-venv/` - Python virtual environment
- `~/.config/nvim/init.vim` - Neovim config
- `~/cnsq-setup.log` - Installation log

### Modified (Append Only)
- `~/.zshrc` - One source block added

### Never Touched
- Existing Powerlevel10k configurations
- Oh-my-zsh settings
- User's custom aliases/functions
- Existing PATH modifications

---

*This setup creates a powerful, NetOps-optimized environment while respecting existing configurations.*