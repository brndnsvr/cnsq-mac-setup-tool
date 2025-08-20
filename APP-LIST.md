# CNSQ Mac Setup Tool - Complete Application List

## Core Prerequisites (Tasks 1-5)

### 1. Xcode Command Line Tools
Essential development tools and compilers for macOS

### 2. Homebrew
The missing package manager for macOS

### 3. Homebrew Shell Configuration
Adds Homebrew to PATH in ~/.zshrc

### 4. iTerm2
Feature-rich terminal emulator replacement for Terminal.app

### 5. Administrator Access Verification
Ensures sudo access for installations

## Development Tools (Task 6)

### Command Line Tools
- **git** - Distributed version control system
- **neovim** - Hyperextensible Vim-based text editor
- **tmux** - Terminal multiplexer for managing multiple terminal sessions
- **python@3** - Python programming language interpreter
- **ansible** - Automation platform for configuration management
- **expect** - Programmed dialogue with interactive programs
- **node** - JavaScript runtime built on Chrome's V8 engine

### GUI Applications (Casks)
- **visual-studio-code** - Source code editor with debugging support

### Python Configuration
- **pip** - Python package installer (upgraded automatically)

## Network Tools (Task 7)

- **nmap** - Network exploration tool and security scanner
- **netcat** - Utility for reading/writing network connections
- **telnet** - User interface to TELNET protocol
- **gping** - Ping with graph visualization
- **mtr** - Network diagnostic tool combining ping and traceroute
- **fping** - Scriptable ping program for parallel pinging
- **iperf3** - Network bandwidth measurement tool
- **whois** - Whois directory service client
- **arp-scan** - ARP scanning and fingerprinting tool
- **ngrep** - Network packet analyzer with grep capabilities
- **wireshark** (cask) - Network protocol analyzer GUI
- **minicom** - Serial communication program
- **sipcalc** - IP subnet calculator
- **bandwhich** - Terminal bandwidth utilization tool

## Utility Tools (Task 8)

### Command Line Tools
- **jq** - Lightweight command-line JSON processor
- **ripgrep** - Recursively search directories with regex patterns
- **tree** - Display directory structure as tree
- **eza** - Modern replacement for ls with icons and git integration
- **zsh-syntax-highlighting** - Fish-like syntax highlighting for Zsh
- **wget** - Internet file retriever
- **curl** - Transfer data from or to servers
- **watch** - Execute programs periodically
- **p7zip** - 7-Zip file archiver with high compression ratio
- **coreutils** - GNU core utilities (gls, gcp, gmv, etc.)
- **fzf** - Command-line fuzzy finder
- **tldr** - Simplified and community-driven man pages
- **bat** - Cat clone with syntax highlighting and Git integration

### GUI Applications (Casks)
- **appcleaner** - Thoroughly uninstall unwanted apps
- **ghostty** - Fast, feature-rich terminal emulator

### Zsh Syntax Highlighting Configuration
Automatically configures syntax highlighting in ~/.zshrc

## Security Tools (Task 9)

- **ssh-audit** - SSH server & client security auditing
- **ssh-copy-id** - Install SSH keys on remote servers
- **pwgen** - Password generator

## Zsh Configuration (Task 10)

### Directory Structure Created
```
~/.zsh/
├── aliases.zsh     # Eza and Neovim aliases
└── functions.zsh   # Helper functions for file navigation and editing
```

### Eza Aliases (in ~/.zsh/aliases.zsh)
- `ls` - eza with icons and directories first
- `ll` - Long format with headers
- `la` - All files including hidden
- `lt` - Tree view (2 levels)
- `lsd` - Directories only
- `lsf` - Files only
- `lsize` - Sort by size
- `ltime` - Sort by modification time
- `lg` - List with git status

### Neovim Aliases (in ~/.zsh/aliases.zsh)
- `v`, `vi`, `vim`, `nv` - All map to nvim
- `nvt` - Open files in tabs
- `view` - Read-only mode
- `nvimrc` - Edit Neovim config
- `zshrc` - Edit Zsh config
- `bashrc` - Edit Bash config

### Helper Functions (in ~/.zsh/functions.zsh)
- `vf()` - Fuzzy find and edit files with fzf + eza preview
- `vfh()` - Fuzzy find from home directory
- `nvedit()` - Create directories if needed and edit file
- `nvs()` - Neovim session management (save/load/list)
- `lv()` - List files with eza and pick one to edit
- `tv()` - Tree view and pick file to edit

### Zsh Configuration
Automatically adds the following to ~/.zshrc:
```bash
# Load all zsh configuration files from ~/.zsh/
for config_file in ~/.zsh/*.zsh; do
    [[ -f "$config_file" ]] && source "$config_file"
done
```

## Installation Notes

- All tools are installed via Homebrew unless otherwise noted
- GUI applications are installed as Homebrew Casks
- The script handles both Intel and Apple Silicon Macs
- Progress is saved in `~/.cnsq-setup-state`
- Sudo access is cached for the session when needed
- Tools already installed are automatically detected and skipped