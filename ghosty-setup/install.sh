#!/bin/bash

################################################################################
# Ghostty + Starship Installation Script for macOS
# This script installs and configures Ghostty terminal emulator and Starship
# shell prompt with opinionated developer settings.
#
# ⚠️  MAC ONLY - This script is designed exclusively for macOS
#
# Usage: ./install.sh
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging setup
LOG_FILE="$HOME/.ghosty-setup.log"
DEBUG=${DEBUG:-0}

log() {
    local level=$1
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"

    case "$level" in
        INFO)
            echo -e "${BLUE}ℹ${NC} $message"
            ;;
        SUCCESS)
            echo -e "${GREEN}✓${NC} $message"
            ;;
        WARN)
            echo -e "${YELLOW}⚠${NC} $message"
            ;;
        ERROR)
            echo -e "${RED}✗${NC} $message"
            ;;
    esac
}

error_exit() {
    local exit_code=$1
    local message=$2
    log ERROR "$message (exit code: $exit_code)"
    echo -e "\n${RED}Setup failed. Check logs: $LOG_FILE${NC}"
    exit 1
}

debug() {
    if [ "$DEBUG" -eq 1 ]; then
        log "DEBUG" "$@"
    fi
}

################################################################################
# PRE-FLIGHT CHECKS
################################################################################

check_os() {
    log INFO "Checking operating system..."

    if [[ "$OSTYPE" != "darwin"* ]]; then
        error_exit 1 "This script is for macOS only. Detected: $OSTYPE"
    fi
    log SUCCESS "macOS detected"
}

check_homebrew() {
    log INFO "Checking Homebrew installation..."

    if ! command -v brew &> /dev/null; then
        error_exit 1 "Homebrew not found. Install from https://brew.sh"
    fi
    log SUCCESS "Homebrew is installed"
}

check_internet() {
    log INFO "Checking internet connectivity..."

    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        error_exit 1 "No internet connectivity. Required to download packages."
    fi
    log SUCCESS "Internet connection available"
}

################################################################################
# INSTALLATION FUNCTIONS
################################################################################

install_ghosty() {
    log INFO "Installing Ghostty terminal emulator..."

    # Check if Ghostty is already installed
    if [ -d "/Applications/Ghostty.app" ] || command -v ghostty &> /dev/null; then
        log WARN "Ghostty is already installed"
        return 0
    fi

    # Install Ghostty directly from Homebrew (it's in the main repository)
    brew install ghostty > /dev/null 2>&1 || {
        error_exit $? "Failed to install Ghostty via Homebrew. Try running: brew install ghostty"
    }

    log SUCCESS "Ghostty installed successfully"
}

install_starship() {
    log INFO "Installing Starship shell prompt..."

    if command -v starship &> /dev/null; then
        log WARN "Starship is already installed"
        return 0
    fi

    brew install starship > /dev/null 2>&1 || {
        error_exit $? "Failed to install Starship"
    }
    log SUCCESS "Starship installed successfully"
}

install_jq() {
    log INFO "Checking for jq (required for configuration)..."

    if command -v jq &> /dev/null; then
        log WARN "jq is already installed"
        return 0
    fi

    brew install jq > /dev/null 2>&1 || {
        error_exit $? "Failed to install jq"
    }
    log SUCCESS "jq installed successfully"
}

################################################################################
# CONFIGURATION FUNCTIONS
################################################################################

configure_ghosty() {
    log INFO "Configuring Ghostty..."

    local config_dir="$HOME/.config/ghostty"
    local config_file="$config_dir/config"

    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        debug "Created directory: $config_dir"
    fi

    if [ -f "$config_file" ]; then
        log WARN "Ghostty config already exists. Creating backup..."
        cp "$config_file" "$config_file.backup.$(date +%s)"
        debug "Backup created: $config_file.backup.*"
    fi

    cat > "$config_file" << 'EOF'
# Ghostty Configuration - Developer Setup
# ========================================

# Font Configuration
font-family = "JetBrains Mono"
font-size = 14
font-thicken = true

# Window Appearance
background-opacity = 0.92
background-blur-radius = 20
window-padding-x = 12
window-padding-y = 10
window-decoration = true

# Color Theme - Tokyo Night Storm
background = #1a1b26
foreground = #c0caf5
selection-background = #33467c
selection-foreground = #c0caf5

# Normal colors
palette = 0=#15161e
palette = 1=#f7768e
palette = 2=#9ece6a
palette = 3=#e0af68
palette = 4=#7aa2f7
palette = 5=#bb9af7
palette = 6=#7dcfff
palette = 7=#a9b1d6

# Bright colors
palette = 8=#414868
palette = 9=#f7768e
palette = 10=#9ece6a
palette = 11=#e0af68
palette = 12=#7aa2f7
palette = 13=#bb9af7
palette = 14=#7dcfff
palette = 15=#c0caf5

# Cursor
cursor-style = bar
cursor-style-blink = true
cursor-color = #7aa2f7

# Terminal Behavior
scrollback-limit = 50000
copy-on-select = clipboard
confirm-close-surface = false

# macOS specific
macos-titlebar-style = transparent
macos-option-as-alt = true

# Quick terminal (drop-down style)
keybind = global:cmd+grave_accent=toggle_quick_terminal
quick-terminal-position = top
quick-terminal-animation-duration = 0.15
EOF

    if [ $? -eq 0 ]; then
        log SUCCESS "Ghostty configuration created"
        debug "Config file: $config_file"
    else
        error_exit $? "Failed to write Ghostty configuration"
    fi
}

configure_starship() {
    log INFO "Configuring Starship..."

    local config_dir="$HOME/.config"
    local config_file="$config_dir/starship.toml"

    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
        debug "Created directory: $config_dir"
    fi

    if [ -f "$config_file" ]; then
        log WARN "Starship config already exists. Creating backup..."
        cp "$config_file" "$config_file.backup.$(date +%s)"
        debug "Backup created: $config_file.backup.*"
    fi

    cat > "$config_file" << 'EOF'
# Starship Prompt Configuration
# DevOps & Software Developer Setup with Right-Side Timestamps

format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$git_state\
$aws\
$python\
$nodejs\
$rust\
$golang\
$java\
$package\
$cmd_duration\
$line_break\
$character"""

right_format = """$status$time"""

# Adds a blank line between prompts
add_newline = true

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❮](bold green)"

[username]
style_user = "bold cyan"
style_root = "bold red"
format = "[$user]($style) "
disabled = false
show_always = false

[hostname]
ssh_only = true
format = "on [$hostname](bold yellow) "

[directory]
style = "bold blue"
format = "[$path]($style)[$read_only]($read_only_style) "
truncation_length = 4
truncate_to_repo = true
read_only = " "

[git_branch]
symbol = " "
style = "bold purple"
format = "[$symbol$branch(:$remote_branch)]($style) "

[git_status]
format = '([\[$all_status$ahead_behind\]]($style) )'
style = "bold yellow"
conflicted = ""
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "*"
modified = "!${count}"
staged = "+${count}"
renamed = "»"
deleted = "✘"

[git_state]
format = '\([$state( $progress_current/$progress_total)]($style)\) '
style = "bold yellow"

[aws]
symbol = " "
style = "bold #ff9900"
format = '[$symbol($profile)(\($region\))]($style) '
disabled = false

[python]
symbol = " "
style = "bold yellow"
format = '[${symbol}${pyenv_prefix}(${version})(\($virtualenv\))]($style) '

[nodejs]
symbol = " "
style = "bold green"
format = "[$symbol($version)]($style) "

[rust]
symbol = " "
style = "bold #dea584"
format = "[$symbol($version)]($style) "

[golang]
symbol = " "
style = "bold cyan"
format = "[$symbol($version)]($style) "

[java]
symbol = " "
style = "bold #ed8b00"
format = "[$symbol($version)]($style) "

[package]
symbol = "󰏗 "
style = "bold #cb3837"
format = "[$symbol$version]($style) "
display_private = false

[cmd_duration]
min_time = 2000
style = "bold yellow"
format = "took [$duration]($style) "
show_milliseconds = false

[status]
style = "bold red"
symbol = "✘ "
format = '[$symbol$status]($style) '
disabled = false

[time]
disabled = false
format = '[\[$time\]](bold white)'
time_format = "%H:%M:%S"
utc_time_offset = "local"
EOF

    if [ $? -eq 0 ]; then
        log SUCCESS "Starship configuration created"
        debug "Config file: $config_file"
    else
        error_exit $? "Failed to write Starship configuration"
    fi
}

################################################################################
# SHELL INTEGRATION
################################################################################

add_starship_to_shell() {
    log INFO "Configuring shell integration for Starship..."

    local shell_rc=""

    # Detect shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        log WARN "Unknown shell: $SHELL. Skipping shell integration."
        return 1
    fi

    if [ ! -f "$shell_rc" ]; then
        touch "$shell_rc"
        debug "Created: $shell_rc"
    fi

    # Check if Starship is already in the shell config
    if grep -q "eval \"\$(starship init" "$shell_rc"; then
        log WARN "Starship already configured in $shell_rc"
        return 0
    fi

    # Add Starship initialization
    {
        echo ""
        echo "# Starship prompt initialization"
        echo "eval \"\$(starship init $(basename $SHELL))\""
    } >> "$shell_rc"

    log SUCCESS "Added Starship initialization to $shell_rc"
    debug "Updated: $shell_rc"
}

################################################################################
# VERIFICATION
################################################################################

verify_installation() {
    log INFO "Verifying installation..."

    local all_good=true

    # Check for Ghostty (either app or CLI)
    if [ -d "/Applications/Ghostty.app" ] || command -v ghostty &> /dev/null; then
        local version=$(ghostty --version 2>/dev/null || echo "installed")
        log SUCCESS "✓ Ghostty $version"
    else
        log ERROR "Ghostty is not installed"
        all_good=false
    fi

    if ! command -v starship &> /dev/null; then
        log ERROR "Starship is not installed or not in PATH"
        all_good=false
    else
        log SUCCESS "✓ Starship $(starship --version 2>/dev/null)"
    fi

    # Verify config files exist
    if [ ! -f "$HOME/.config/ghostty/config" ]; then
        log ERROR "Ghostty config file not found at ~/.config/ghostty/config"
        all_good=false
    else
        log SUCCESS "✓ Ghostty config exists"
    fi

    if [ ! -f "$HOME/.config/starship.toml" ]; then
        log ERROR "Starship config file not found at ~/.config/starship.toml"
        all_good=false
    else
        log SUCCESS "✓ Starship config exists"
    fi

    if [ "$all_good" = false ]; then
        log WARN "Some checks failed. See $LOG_FILE for details."
        return 1
    fi

    return 0
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  Ghostty + Starship Setup for macOS${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

    log INFO "Setup started"
    log INFO "User: $(whoami)"
    log INFO "Shell: $SHELL"
    log INFO "Home: $HOME"

    # Pre-flight checks
    check_os
    check_homebrew
    check_internet

    echo ""

    # Install tools
    install_ghosty
    install_starship
    install_jq

    echo ""

    # Configure tools
    configure_ghosty
    configure_starship

    echo ""

    # Shell integration
    add_starship_to_shell

    echo ""

    # Verify
    verify_installation || {
        error_exit 1 "Installation verification failed"
    }

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Setup completed successfully!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"

    # Determine shell config file for next steps message
    local shell_rc=""
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"bash"* ]]; then
        shell_rc="$HOME/.bashrc"
    else
        shell_rc="your shell config file"
    fi

    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Launch Ghostty from Applications or use: open -a Ghostty"
    echo "2. Restart your shell or source your config: source $shell_rc"
    echo "3. Your prompt will now display Starship with git/language info"
    echo ""
    echo -e "${YELLOW}Logs saved to: $LOG_FILE${NC}"

    log INFO "Setup completed successfully"
}

# Run main function
main "$@"
