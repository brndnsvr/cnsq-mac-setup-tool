# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is the CNSQ NetOps Mac Setup Tool - an automated Bash script for configuring macOS workstations for network operations teams. The repository contains a single comprehensive setup script that installs 68+ tools and configures the development environment.

## Key Commands

### Running the Setup Script
```bash
# Default installation (auto mode - installs everything)
./setup.sh

# Preview what would be installed (dry run)
./setup.sh --dry-run

# Minimal installation (core packages only)
./setup.sh --mode minimal

# Show all available options
./setup.sh --help

# Reset state and start fresh
./setup.sh --reset

# Verbose output for debugging
./setup.sh --verbose
```

### Testing and Verification
```bash
# Verify script syntax (no formal test suite)
bash -n setup.sh

# Check if script is executable
ls -la setup.sh

# View installation log after running
cat ~/cnsq-setup.log

# Check saved state (if resumable)
cat ~/.cnsq-setup/state
```

## Architecture and Code Structure

### Single Script Design
The entire tool is implemented in `/setup.sh` - a 1300+ line Bash script with the following architecture:

1. **Configuration Section (lines 66-98)**: Default settings, paths, color codes
2. **Prerequisite Functions (lines 16-63, 297-337)**: Sudo verification, system checks
3. **Core Installation Functions**:
   - `install_homebrew()` (line 393): Homebrew package manager setup
   - `install_packages()` (line 433): Installs 43 Homebrew packages
   - `setup_python()` (line 549): Python virtual environment and packages
   - `setup_ansible()` (line 606): Ansible collections installation
   - `configure_shell()` (line 650): Zsh configuration and enhancements
   - `install_gui_apps()` (line 1106): GUI applications via Homebrew Cask
   - `install_terminal_fonts()` (line 1146): Nerd Fonts installation

4. **State Management (lines 265-295)**: Resume capability for interrupted installations
5. **Main Execution Flow (line 1264)**: Orchestrates the installation process

### Key Design Patterns

- **Non-destructive**: Never overwrites existing configurations, only appends
- **Modular Configuration**: Shell configs stored in `~/.zsh/` directory
- **State Persistence**: Tracks completed steps in `~/.cnsq-setup/state`
- **Architecture Aware**: Detects ARM64 vs Intel and adjusts Homebrew paths
- **Comprehensive Logging**: All actions logged to `~/cnsq-setup.log`

### Installation Modes

- **auto** (default): Installs all 68 packages without prompts
- **minimal**: Core packages only (18 packages)
- **interactive**: Same as auto (legacy compatibility)

### Created Directory Structure
```
~/
├── .zsh/                    # Custom shell configurations
│   ├── cnsq-config.zsh     # Main configuration
│   ├── aliases.zsh         # Command aliases
│   └── functions.zsh       # Shell functions
├── .cnsq-venv/             # Python virtual environment
├── .cnsq-setup/            # State management
└── .config/nvim/           # Neovim configuration
```

## Important Implementation Details

### Package Categories
- **Core (8)**: git, neovim, tmux, python, ansible, jq, ripgrep, tree
- **Network Tools (20+)**: nmap, mtr, iperf3, wireshark, netcat, etc.
- **Shell Enhancements (3)**: eza, zsh-syntax-highlighting, zsh-autosuggestions
- **GUI Apps (4)**: iTerm2, VS Code, AppCleaner, Wireshark
- **Fonts (5)**: FiraCode, Hack, JetBrains Mono, Meslo, Inconsolata (all Nerd Fonts)

### Critical Functions for Network Operations
The script adds numerous network-focused aliases and functions:
- `nettest`: Test gateway, DNS, and internet connectivity
- `netinfo`: Display all network interface information
- `testport`: Test TCP port connectivity
- `mssh`: SSH to multiple hosts in tmux panes
- `dnscheck`: Query multiple DNS servers
- Network aliases: `listening`, `openports`, `showip`

### Error Handling
- All functions use proper error checking with `|| return 1`
- Comprehensive prerequisite checks before installation
- Automatic sudo keepalive during installation
- Detailed logging of all operations

## Development Workflow

When modifying this script:

1. **Test changes with dry run**: `./setup.sh --dry-run`
2. **Check syntax**: `bash -n setup.sh`
3. **Test in minimal mode first**: `./setup.sh --mode minimal`
4. **Review logs**: `tail -f ~/cnsq-setup.log`
5. **Use verbose mode for debugging**: `./setup.sh --verbose`

## Common Maintenance Tasks

### Adding New Packages
1. Add to appropriate array in `install_packages()` function:
   - `CORE_PACKAGES` for essential tools
   - `SHELL_PACKAGES` for shell enhancements
   - `OPTIONAL_PACKAGES` for optional tools
2. Update package count in documentation
3. Test installation in dry-run mode

### Modifying Shell Configuration
1. Edit the `configure_shell()` function (starting at line 650)
2. Configurations are written to `~/.zsh/` directory
3. Test by sourcing: `source ~/.zshrc`

### Updating Python Packages
1. Modify `PYTHON_PACKAGES` array in `setup_python()` function
2. Consider virtual environment implications
3. Test with: `python3 -c "import package_name"`

## Known Constraints

- Requires macOS 12.0 (Monterey) or later
- Needs administrator (sudo) access
- Requires 5GB free disk space
- Internet connection essential for downloads
- No built-in rollback mechanism (uses backups instead)