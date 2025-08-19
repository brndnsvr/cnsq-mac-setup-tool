# CNSQ Mac Setup - Application List

This document provides a comprehensive breakdown of all applications installed by the `setup.sh` script, organized by installation method.

## Installation Methods Overview

- **Homebrew (brew)**: Package manager for macOS - installs command-line tools and GUI applications
- **Homebrew Cask (brew --cask)**: Extension for installing GUI applications
- **Python pip**: Python package installer
- **Ansible Galaxy**: Ansible collections and roles installer
- **cURL**: Direct download via HTTP/HTTPS

---

## Homebrew (brew)

### Core Packages (Required)
Always installed regardless of mode.

| Package | Description | Purpose |
|---------|-------------|---------|
| `git` | Version control system | Source code management |
| `neovim` | Modern text editor | Code editing |
| `tmux` | Terminal multiplexer | Session management |
| `python@3` | Python programming language | Scripting and automation |
| `ansible` | IT automation tool | Configuration management |
| `jq` | JSON processor | Data parsing |
| `ripgrep` | Fast text search tool | Code searching |
| `tree` | Directory tree visualizer | File system navigation |

### Shell Enhancement Packages
Installed in non-minimal modes.

| Package | Description | Purpose |
|---------|-------------|---------|
| `eza` | Modern replacement for ls | Enhanced file listing |
| `zsh-syntax-highlighting` | Syntax highlighting for Zsh | Shell enhancement |
| `zsh-autosuggestions` | Fish-like autosuggestions | Shell productivity |

### Optional Packages - Network Operations Focused
Installed automatically in non-minimal modes (organized by category).

#### Development & Version Control
| Package | Description | Purpose |
|---------|-------------|---------|
| `gh` | GitHub CLI | GitHub operations |
| `lazygit` | Terminal UI for git | Git management |

#### System Monitoring
| Package | Description | Purpose |
|---------|-------------|---------|
| `htop` | Interactive process viewer | System monitoring |
| `ncdu` | NCurses disk usage analyzer | Disk space analysis |
| `fswatch` | File system monitor | Watch file changes |

#### Core Network Tools
| Package | Description | Purpose |
|---------|-------------|---------|
| `wget` | Network downloader | File downloads |
| `curl` | Data transfer tool | API testing & downloads |
| `watch` | Command repeater | Command monitoring |
| `nmap` | Network mapper | Network discovery |
| `sipcalc` | IP subnet calculator | Network planning |
| `netcat` | Network utility | TCP/UDP connections |
| `telnet` | Telnet client | Legacy device access |

#### Network Diagnostics
| Package | Description | Purpose |
|---------|-------------|---------|
| `gping` | Ping with graph visualization | Network diagnostics |
| `mtr` | Combined ping/traceroute | Path quality analysis |
| `fping` | Fast multi-host ping | Bulk connectivity testing |
| `iperf3` | Bandwidth testing tool | Network performance |
| `socat` | Multipurpose relay | Port forwarding/tunnels |
| `whois` | Domain/IP lookup | Ownership information |
| `arp-scan` | Layer 2 discovery | Find hosts on L2 segment |
| `ngrep` | Network grep | Packet payload search |

#### DNS Tools
| Package | Description | Purpose |
|---------|-------------|---------|
| `ldns` | DNS library with drill | Advanced DNS debugging |

#### SNMP Tools
| Package | Description | Purpose |
|---------|-------------|---------|
| `net-snmp` | SNMP utilities | Device polling/monitoring |

#### Serial/Console Access
| Package | Description | Purpose |
|---------|-------------|---------|
| `minicom` | Serial communication | Router/switch console |
| `lrzsz` | ZMODEM file transfer | Serial file transfers |

#### Security & SSH
| Package | Description | Purpose |
|---------|-------------|---------|
| `ssh-audit` | SSH configuration auditor | Security auditing |
| `ssh-copy-id` | SSH key installer | Remote key deployment |
| `pwgen` | Password generator | Secure passwords |

#### File & Archive Tools
| Package | Description | Purpose |
|---------|-------------|---------|
| `p7zip` | 7-Zip archiver | Extract .7z files |
| `unrar` | RAR archive extractor | Extract .rar files |
| `coreutils` | GNU core utilities | Enhanced Unix tools |

#### Automation
| Package | Description | Purpose |
|---------|-------------|---------|
| `expect` | Automation tool | Script interactive programs |

#### Optional/Nice-to-have
| Package | Description | Purpose |
|---------|-------------|---------|
| `mas` | Mac App Store CLI | Automate app installs |
| `pandoc` | Document converter | Convert file formats |
| `httping` | HTTP request pinger | Web service monitoring |
| `mactop` | macOS system monitor | Apple Silicon monitoring |
| `ascii-image-converter` | Image to ASCII | Terminal graphics |

---

## Homebrew Cask (brew --cask)

### GUI Applications (Optional)
Installed automatically in non-minimal modes.

| Application | Description | Installation Condition |
|-------------|-------------|----------------------|
| `iterm2` | Advanced terminal emulator | Auto/Interactive mode |
| `visual-studio-code` | Source code editor | Auto/Interactive mode |
| `appcleaner` | Complete app uninstaller | Auto/Interactive mode |
| `wireshark` | Network protocol analyzer (includes tshark CLI) | Auto/Interactive mode |

**Note:** Wireshark includes `tshark` for CLI packet capture. To capture without root:
```bash
sudo dseditgroup -o edit -a $(whoami) -t user access_bpf
# Then logout and login again
```

### Terminal Fonts (Optional)
Nerd Fonts include programming ligatures and icon support for enhanced terminal experience.

#### Available Fonts (Interactive Mode)
| Font Package | Description | Features |
|--------------|-------------|----------|
| `font-fira-code-nerd-font` | Ligatures and icons | Programming ligatures, extensive icon set |
| `font-hack-nerd-font` | Clean and readable | Excellent readability, powerline symbols |
| `font-jetbrains-mono-nerd-font` | Excellent for coding | Created by JetBrains, great for IDEs |
| `font-meslo-lg-nerd-font` | Popular terminal font | Apple-style, widely compatible |
| `font-inconsolata-nerd-font` | Monospaced clarity | Clean monospace, good for terminals |

#### Recommended Fonts (Auto Mode)
In auto mode, these three fonts are installed automatically:
- `font-fira-code-nerd-font`
- `font-hack-nerd-font`
- `font-jetbrains-mono-nerd-font`

---

## cURL Downloads

### System Tools

| Tool | Source URL | Purpose |
|------|------------|---------|
| Homebrew | `https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh` | Package manager installation |

---

## Python Packages (pip)

Installed via pip in virtual environment (`~/.cnsq-venv`) or globally.

### Core Packages
| Package | Description | Purpose |
|---------|-------------|---------|
| `pip` | Package installer (upgraded) | Python package management |
| `paramiko` | SSH2 protocol library | SSH connections |
| `cryptography` | Cryptographic recipes | Security operations |
| `pyyaml` | YAML parser and emitter | Configuration files |
| `jinja2` | Template engine | Template processing |
| `requests` | HTTP library | API interactions |
| `ansible-core` | Ansible core functionality | Automation framework |

### Network Automation Libraries
| Package | Description | Purpose |
|---------|-------------|---------|
| `netmiko` | Multi-vendor SSH library | Network device automation |
| `napalm` | Network automation abstraction | Unified device management |
| `textfsm` | Template-based text parser | Parse CLI output |

---

## Ansible Galaxy Collections

### Core Collections (Required)

| Collection | Description | Purpose |
|------------|-------------|---------|
| `ansible.netcommon` | Network common modules | Network automation basics |
| `ansible.utils` | Utility modules | General utilities |
| `ansible.posix` | POSIX system modules | Unix/Linux operations |

### Network Vendor Collections (Non-minimal)

| Collection | Description | Purpose |
|------------|-------------|---------|
| `cisco.ios` | Cisco IOS modules | Cisco IOS device management |
| `cisco.iosxr` | Cisco IOS XR modules | Cisco IOS XR device management |
| `junipernetworks.junos` | Juniper Junos modules | Juniper device management |

---

## System Requirements

### Pre-requisites (Not installed by script)

| Component | Check Method | Required For |
|-----------|--------------|--------------|
| macOS | `sw_vers -productVersion` | Base operating system |
| Xcode Command Line Tools | `xcode-select -p` | Compilation tools |
| Internet Connection | `ping -c 1 8.8.8.8` | Downloads |
| 5GB Free Disk Space | `df -g /` | Installation space |

---

## Installation Modes Summary

### Minimal Mode
- **Homebrew**: Core packages only
- **Python**: Core packages in venv
- **Ansible**: Core collections only
- **GUI Apps**: None
- **Shell Enhancements**: None

### Auto Mode (Default)
- **Homebrew**: All packages (Core + Shell + Optional) - no prompts
- **Python**: All packages in venv
- **Ansible**: All collections
- **GUI Apps**: All 4 apps (iTerm2, VS Code, AppCleaner, Wireshark)
- **Terminal Fonts**: All 5 Nerd Fonts installed automatically
- **Shell Enhancements**: All

### Interactive Mode
- **Homebrew**: All packages installed automatically (same as Auto)
- **Python**: All packages in venv
- **Ansible**: All collections
- **GUI Apps**: All 4 apps installed automatically
- **Terminal Fonts**: All 5 Nerd Fonts installed automatically
- **Shell Enhancements**: All

---

## Total Application Count

| Category | Required | Optional | Total |
|----------|----------|----------|-------|
| Homebrew Packages | 8 | 35 | 43 |
| Homebrew Cask Apps | 0 | 4 | 4 |
| Homebrew Cask Fonts | 0 | 5 | 5 |
| Python Packages | 7 | 3 | 10 |
| Ansible Collections | 3 | 3 | 6 |
| **Grand Total** | **18** | **50** | **68** |

---

## New Utility Highlights

### Network & System Monitoring
- **gping**: Visualizes ping latency with real-time graphs in the terminal
- **mactop**: Apple Silicon-optimized system monitor showing CPU, GPU, memory usage
- **ncdu**: Interactive disk usage analyzer with NCurses interface for finding space hogs
- **httping**: Like ping but for HTTP requests - tests web service availability
- **fswatch**: Monitor file system changes in real-time

### Core Unix Tools & Automation
- **coreutils**: GNU versions of core utilities (gls, gdate, etc.) with more features
- **expect**: Automate interactive applications and SSH sessions
- **netcat**: Swiss-army knife for TCP/UDP - port scanning, file transfers, debugging
- **telnet**: Classic protocol for accessing legacy network equipment

### Documentation & Security
- **pandoc**: Swiss-army knife for converting between document formats (Markdown, HTML, PDF, etc.)
- **ssh-audit**: Audits SSH server and client configurations for security vulnerabilities
- **ssh-copy-id**: Securely install SSH keys on remote servers
- **pwgen**: Generates secure, pronounceable passwords with customizable complexity

### Network Planning & Utilities
- **sipcalc**: Advanced IP subnet calculator for network planning and CIDR calculations
- **curl**: Essential tool for testing APIs and downloading files with protocol support
- **mas**: Mac App Store CLI for scripting app installations
- **ascii-image-converter**: Converts images to ASCII art for terminal display

---

## Notes

1. **Virtual Environment**: Python packages are installed in `~/.cnsq-venv` by default (recommended)
2. **Architecture Detection**: Script automatically detects ARM64 vs x86_64 and adjusts Homebrew paths
3. **Resume Capability**: Script can resume interrupted installations
4. **Backup**: Existing configurations are backed up to `~/.cnsq-backup-[timestamp]`
5. **Dry Run**: Use `--dry-run` flag to preview what would be installed