# CNSQ NetOps Mac Setup

Automated setup script for configuring macOS workstations for the CNSQ NetOps team.

## Prerequisites

Before running the setup script, you need to install these third-party tools manually:

### 1. Install Xcode Command Line Tools
```bash
xcode-select --install
```

### 2. Install Homebrew
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 3. Add Homebrew to PATH (for Apple Silicon Macs)
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc
```

### 4. Verify Homebrew installation
```bash
brew --version
```

### 5. Install iTerm2
```bash
brew install --cask iterm2
```

## Setup

Once prerequisites are installed:

```bash
git clone https://github.com/brndnsvr/cnsq-mac-setup-tool.git
cd cnsq-mac-setup-tool/
chmod +x setup.sh
./setup.sh
```

## Development

This tool is under active development. The setup script will evolve to include:
- Package installation
- Shell configuration
- Development environment setup
- Network tools installation