#!/bin/bash

#############################################################################
# CNSQ NetOps Mac Setup Script
# Version: 1.0.0
# Purpose: Automated macOS setup for NetOps team development
#############################################################################

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Script information
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="CNSQ NetOps Mac Setup"

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
    echo ""
    echo -e "${BOLD}${BLUE}$SCRIPT_NAME - v$SCRIPT_VERSION${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
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
    (while true; do sudo -n true; sleep 50; done) &
    SUDO_PID=$!
    
    # Store PID for cleanup
    echo "$SUDO_PID" > /tmp/.cnsq-sudo-pid-$$
    
    print_success "Administrator access verified successfully"
    return 0
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
    # Print header
    print_header
    
    # Verify sudo access
    if ! verify_sudo_access; then
        print_error "Setup cannot continue without administrator privileges."
        exit 1
    fi
    
    print_success "Initial checks completed successfully!"
    echo ""
    print_info "Setup script is ready for next steps."
    echo "    (This is just the beginning - more functionality coming soon)"
    echo ""
}

# Run main function
main "$@"