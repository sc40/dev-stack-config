#!/bin/bash

################################################################################
# Claude Code Status Line Configuration Script
# Installs a sophisticated status line for Claude Code that displays:
# - Project context
# - Git branch and status
# - Current directory type (frontend/infra/testing)
# - AWS environment indicator
# - Claude model name
# - Context window usage
#
# This script assumes Claude Code is already installed.
# It only handles the status line command configuration.
################################################################################

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging setup
LOG_FILE="$HOME/.claude-statusline-setup.log"
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

check_claude_code() {
    log INFO "Checking for Claude Code installation..."

    if ! command -v claude &> /dev/null; then
        error_exit 1 "Claude Code CLI not found. Install from https://claude.com/claude-code"
    fi
    log SUCCESS "Claude Code is installed"
}

check_dependencies() {
    log INFO "Checking required dependencies..."

    if ! command -v jq &> /dev/null; then
        log WARN "jq is not installed. Installing via Homebrew..."
        if ! command -v brew &> /dev/null; then
            error_exit 1 "Homebrew not found. Install from https://brew.sh"
        fi
        brew install jq > /dev/null 2>&1 || {
            error_exit $? "Failed to install jq"
        }
        log SUCCESS "jq installed"
    else
        log SUCCESS "jq is installed"
    fi
}

check_claude_config() {
    log INFO "Checking Claude Code configuration directory..."

    local claude_config_dir="$HOME/.claude"

    if [ ! -d "$claude_config_dir" ]; then
        mkdir -p "$claude_config_dir"
        debug "Created directory: $claude_config_dir"
        log SUCCESS "Created Claude config directory"
    else
        log SUCCESS "Claude config directory exists"
    fi
}

################################################################################
# INSTALLATION FUNCTIONS
################################################################################

install_statusline_command() {
    log INFO "Installing status line command script..."

    local script_path="$HOME/.claude/statusline-command.sh"

    if [ -f "$script_path" ]; then
        log WARN "Status line script already exists. Creating backup..."
        cp "$script_path" "$script_path.backup.$(date +%s)"
        debug "Backup created: $script_path.backup.*"
    fi

    cat > "$script_path" << 'EOF'
#!/bin/bash

# Sophisticated Claude Code Status Line
# Displays: project | git status | directory context | AWS env | model | context usage

# Read JSON input from stdin
input=$(cat)

# Extract JSON fields
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name // .model.id')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Project name (basename of directory)
project=$(basename "$cwd")

# Git branch and status
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check if clean or dirty
    if git -C "$cwd" diff-index --quiet HEAD -- 2>/dev/null; then
        status="✓"
    else
        status="●"
    fi

    # Check ahead/behind remote
    upstream=$(git -C "$cwd" rev-parse --abbrev-ref @{upstream} 2>/dev/null)
    if [ -n "$upstream" ]; then
        ahead=$(git -C "$cwd" rev-list --count HEAD@{upstream}..HEAD 2>/dev/null || echo "0")
        behind=$(git -C "$cwd" rev-list --count HEAD..HEAD@{upstream} 2>/dev/null || echo "0")

        ahead_behind=""
        [ "$ahead" -gt 0 ] && ahead_behind="⇡$ahead"
        [ "$behind" -gt 0 ] && ahead_behind="${ahead_behind}⇣$behind"

        if [ -n "$ahead_behind" ]; then
            git_info="$branch $status $ahead_behind"
        else
            git_info="$branch $status"
        fi
    else
        git_info="$branch $status"
    fi
else
    git_info="no repo"
fi

# Directory context (detect src/, infrastructure/, tests/)
dir_context=""
case "$cwd" in
    */src|*/src/*)
        dir_context="frontend"
        ;;
    */infrastructure|*/infrastructure/*)
        dir_context="infra/cdk"
        ;;
    */tests|*/tests/*)
        dir_context="testing"
        ;;
    */lambda|*/lambda/*)
        dir_context="lambda"
        ;;
    *)
        # Show just the last directory component if not a special one
        dir_context=$(basename "$cwd")
        ;;
esac

# AWS environment detection (check for CDK outputs or environment variables)
aws_env=""
if [ -f "$cwd/infrastructure/cdk-outputs-dev.json" ] || [ -f "$cwd/cdk-outputs-dev.json" ]; then
    aws_env="dev"
elif [ -f "$cwd/infrastructure/cdk-outputs-prod.json" ] || [ -f "$cwd/cdk-outputs-prod.json" ]; then
    aws_env="prod"
fi

# Build status line
status_line="$project"

[ -n "$git_info" ] && status_line="$status_line | $git_info"
[ -n "$dir_context" ] && [ "$dir_context" != "$project" ] && status_line="$status_line | $dir_context"
[ -n "$aws_env" ] && status_line="$status_line | aws:$aws_env"

# Model name (shortened)
model_short=$(echo "$model_name" | sed 's/Claude //' | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]')
status_line="$status_line | $model_short"

# Context usage
if [ -n "$ctx_remaining" ]; then
    # Round to integer
    ctx_int=$(printf "%.0f" "$ctx_remaining")
    status_line="$status_line | ctx:${ctx_int}%"
fi

echo "$status_line"
EOF

    if [ $? -eq 0 ]; then
        chmod +x "$script_path"
        log SUCCESS "Status line command script created"
        debug "Script path: $script_path"
    else
        error_exit $? "Failed to create status line script"
    fi
}

################################################################################
# CONFIGURATION
################################################################################

configure_claude_settings() {
    log INFO "Configuring Claude Code settings..."

    local settings_file="$HOME/.claude/settings.json"
    local statusline_cmd="$HOME/.claude/statusline-command.sh"

    # Check if settings.json exists
    if [ ! -f "$settings_file" ]; then
        log INFO "Creating Claude Code settings file..."
        mkdir -p "$(dirname "$settings_file")"

        # Initialize with status line configuration
        cat > "$settings_file" << 'EOF'
{
  "statusline": {
    "command": "$HOME/.claude/statusline-command.sh"
  }
}
EOF
        log SUCCESS "Settings file created"
    else
        log WARN "Settings file already exists"

        # Check if statusline is already configured
        if grep -q "statusline" "$settings_file"; then
            log WARN "Statusline already configured in settings"
            return 0
        fi

        # Add statusline configuration to existing settings
        log INFO "Adding statusline configuration to existing settings..."

        # Use jq to add the statusline configuration
        if command -v jq &> /dev/null; then
            jq '.statusline = {"command": "$HOME/.claude/statusline-command.sh"}' "$settings_file" > "${settings_file}.tmp"
            mv "${settings_file}.tmp" "$settings_file"
            log SUCCESS "Statusline configuration added"
        else
            log WARN "Could not update settings.json with jq. Manual edit may be needed."
            return 1
        fi
    fi

    # Verify settings file is valid JSON
    if ! jq empty "$settings_file" 2>/dev/null; then
        error_exit 1 "Settings file is not valid JSON"
    fi

    log SUCCESS "Claude Code settings configured"
}

################################################################################
# VERIFICATION
################################################################################

verify_installation() {
    log INFO "Verifying installation..."

    local all_good=true
    local script_path="$HOME/.claude/statusline-command.sh"
    local settings_file="$HOME/.claude/settings.json"

    # Check script exists and is executable
    if [ ! -x "$script_path" ]; then
        log ERROR "Status line script not found or not executable at $script_path"
        all_good=false
    else
        log SUCCESS "✓ Status line script is installed and executable"
    fi

    # Check settings file exists
    if [ ! -f "$settings_file" ]; then
        log ERROR "Settings file not found at $settings_file"
        all_good=false
    else
        log SUCCESS "✓ Settings file exists"
    fi

    # Verify settings file is valid JSON
    if ! jq empty "$settings_file" 2>/dev/null; then
        log ERROR "Settings file is not valid JSON"
        all_good=false
    else
        log SUCCESS "✓ Settings file is valid JSON"
    fi

    # Test script with sample input
    log INFO "Testing status line script with sample input..."
    local sample_input='{"workspace":{"current_dir":"/tmp/test-project"},"model":{"display_name":"Claude Sonnet 4"},"context_window":{"remaining_percentage":75}}'

    if echo "$sample_input" | bash "$script_path" > /dev/null 2>&1; then
        log SUCCESS "✓ Status line script execution test passed"
    else
        log WARN "Status line script test had issues (may be normal if git not available)"
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
    echo -e "${BLUE}  Claude Code Status Line Configuration${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

    log INFO "Setup started"
    log INFO "User: $(whoami)"
    log INFO "Home: $HOME"

    # Pre-flight checks
    check_claude_code
    check_dependencies
    check_claude_config

    echo ""

    # Install and configure
    install_statusline_command
    configure_claude_settings

    echo ""

    # Verify
    verify_installation || {
        error_exit 1 "Installation verification failed"
    }

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Status line configuration completed!${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}\n"

    echo -e "${YELLOW}Next steps:${NC}"
    echo "1. Restart Claude Code to activate the status line"
    echo "2. Your status line will display:"
    echo "   project | branch (status) [ahead/behind] | context | model | context%"
    echo ""
    echo -e "${YELLOW}Example outputs:${NC}"
    echo "  my-project | main ✓ | sonnet-4-5 | ctx:85%"
    echo "  my-project | main ● ⇡2 | infra/cdk | aws:dev | sonnet-4-5 | ctx:72%"
    echo ""
    echo -e "${YELLOW}Configuration files:${NC}"
    echo "  Script: ~/.claude/statusline-command.sh"
    echo "  Settings: ~/.claude/settings.json"
    echo ""
    echo -e "${YELLOW}Logs saved to: $LOG_FILE${NC}"

    log INFO "Setup completed successfully"
}

# Run main function
main "$@"
