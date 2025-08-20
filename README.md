# CNSQ NetOps Mac Setup

Automated setup script for configuring macOS workstations for the CNSQ NetOps team.

## Quick Start

```bash
git clone https://github.com/brndnsvr/cnsq-mac-setup-tool.git
cd cnsq-mac-setup-tool
./setup.sh
```

## Features

- **Interactive Menu System** - Choose individual tasks or run all at once
- **Automatic Detection** - Skips already-installed tools
- **Progress Tracking** - Saves state between sessions
- **Universal Support** - Works on Intel and Apple Silicon Macs
- **Non-Destructive** - Preserves existing configurations
- **Smart Dependencies** - Handles installation order automatically

## What Gets Installed

### Core Components (Tasks 1-5)
1. **Xcode Command Line Tools** - Essential development tools and compilers
2. **Homebrew** - The missing package manager for macOS
3. **Homebrew PATH Configuration** - Ensures brew is accessible
4. **iTerm2** - Feature-rich terminal emulator
5. **Administrator Access** - Sudo verification for installations

### Development Tools (Task 6)
- **Version Control**: git
- **Editors**: neovim, Visual Studio Code
- **Terminal**: tmux
- **Languages**: python@3, node
- **Automation**: ansible, expect

### Network Tools (Task 7)
- **Scanning**: nmap, arp-scan
- **Connectivity**: netcat, telnet, mtr, fping, gping
- **Analysis**: wireshark, ngrep, bandwhich
- **Testing**: iperf3
- **Utilities**: whois, sipcalc, minicom

### Utility Tools (Task 8)
- **JSON/Data**: jq
- **Search**: ripgrep, fzf
- **File Management**: tree, eza, bat, coreutils
- **Downloading**: wget, curl
- **Monitoring**: watch
- **Archives**: p7zip
- **Documentation**: tldr
- **GUI Apps**: AppCleaner, Ghostty
- **Shell Enhancement**: zsh-syntax-highlighting

### Security Tools (Task 9)
- **SSH**: ssh-audit, ssh-copy-id
- **Passwords**: pwgen

### Zsh Configuration (Task 10)
Creates a powerful shell environment with:
- **Eza aliases**: Enhanced ls commands with icons and git integration
- **Neovim aliases**: Quick editing shortcuts
- **Helper functions**: Fuzzy finding, session management, tree navigation
- **Auto-sourcing**: Modular config in ~/.zsh/ directory

## Usage

Run `./setup.sh` and you'll see an interactive menu:

```
Setup Tasks:
  ✓ 1. Install Xcode Command Line Tools
  ✓ 2. Install Homebrew Package Manager
  ✓ 3. Configure Homebrew in Shell
  ✓ 4. Install iTerm2 Terminal
  ○ 5. Verify Administrator Access
  ○ 6. Install Dev Tools (git, neovim, python, VSCode, etc.)
  ○ 7. Install Network Tools (nmap, wireshark, mtr, etc.)
  ○ 8. Install Utility Tools (jq, ripgrep, AppCleaner, etc.)
  ○ 9. Install Security Tools (ssh-audit, pwgen, etc.)
  ○ 10. Configure Zsh (eza/nvim aliases & functions)

Options:
  A. Run All Pending Tasks
  R. Reset All Tasks
  Q. Quit

Enter your choice (1-10, A, R, or Q):
```

Green checkmarks (✓) indicate completed tasks, yellow circles (○) indicate pending tasks.

## Complete Tool List

For detailed descriptions of all tools and configurations, see [APP-LIST.md](APP-LIST.md).

## File Locations

- **Setup State**: `~/.cnsq-setup-state` - Tracks completed tasks
- **Zsh Configs**: `~/.zsh/` - Contains aliases.zsh and functions.zsh
- **Modified Files**: `~/.zshrc` - Updated to source ~/.zsh/*.zsh files

## Requirements

- macOS (Intel or Apple Silicon)
- Administrator (sudo) access
- Internet connection
- Git (for cloning the repository)

## Notes

- The script is idempotent - safe to run multiple times
- Existing tools are detected and won't be reinstalled
- Your existing ~/.zshrc is preserved (new configs added at top)
- Progress is saved, so you can stop and resume anytime
- Each task can be run individually or all together

## Support

For issues or suggestions, please contact the CNSQ NetOps team or submit an issue on GitHub.