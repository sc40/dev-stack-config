# Claude Code Status Line Configuration

Setup script to configure a sophisticated status line for Claude Code that displays relevant development information at a glance.

## What Gets Installed

The status line displays:
- **Project name** - Current working directory
- **Git branch & status** - Branch name with clean/dirty indicator
- **Commits ahead/behind** - Shows if you're ahead or behind remote (⇡2 ⇣1)
- **Directory context** - Auto-detects context (frontend, infra/cdk, testing, etc.)
- **AWS environment** - Shows dev or prod based on CDK files
- **Claude model** - Currently active Claude model
- **Context usage** - Remaining conversation context percentage
- **Session cost** - Real-time cumulative cost in USD

## Prerequisites

1. **Claude Code CLI** - Installed and authenticated
2. **jq** - Will be auto-installed if missing (requires Homebrew)

## Installation

### Quick Start
```bash
# Clone this repository (or extract it)
cd dev-stack-config/claude-statusline

# Make script executable
chmod +x install.sh

# Run the installer
./install.sh
```

### What Happens
1. Checks Claude Code is installed
2. Installs jq if needed (via Homebrew)
3. Creates Claude Code config directory if missing
4. Installs the status line command script
5. Configures Claude Code settings
6. Verifies everything works

## Example Status Line Outputs

In different contexts, your status line will look like:

```
my-project | main ✓ | sonnet-4-5 | ctx:85% | $0.12
```

In infrastructure directory with uncommitted changes:
```
my-project | main ● ⇡2 | infra/cdk | aws:dev | sonnet-4-5 | ctx:72% | $1.45
```

In testing directory:
```
my-project | main ✓ ⇣1 | testing | sonnet-4-5 | ctx:91% | $0.08
```

In frontend with pending changes:
```
my-project | main ● | frontend | sonnet-4-5 | ctx:68% | $0.34
```

## Status Line Components

- **Project**: Current directory name
- **Git Branch**: Branch name with status indicator
  - `✓` = Clean (no uncommitted changes)
  - `●` = Dirty (has uncommitted changes)
- **Commits**: Ahead/behind remote
  - `⇡2` = 2 commits ahead of remote
  - `⇣1` = 1 commit behind remote
- **Directory Context**: Auto-detects based on path
  - `frontend` - When in `src/` directory
  - `infra/cdk` - When in `infrastructure/` directory
  - `testing` - When in `tests/` directory
  - `lambda` - When in `lambda/` directory
- **AWS Environment**: Based on CDK output files
  - `aws:dev` or `aws:prod`
- **Model**: Shortened Claude model name (e.g., `sonnet-4-5`)
- **Context**: Remaining conversation context (e.g., `ctx:85%`)
- **Cost**: Cumulative session cost in USD (e.g., `$0.12` or `$1.45`)
  - Shows 4 decimal places for costs under $0.01
  - Shows 2 decimal places for costs $0.01 and above

## Configuration Files

After installation, configs are at:
- **Status line script**: `~/.claude/statusline-command.sh`
- **Claude settings**: `~/.claude/settings.json`

### View Current Configuration
```bash
cat ~/.claude/settings.json
cat ~/.claude/statusline-command.sh
```

### Customize Directory Context
Edit `~/.claude/statusline-command.sh` to add more directory patterns:

```bash
case "$cwd" in
    */src|*/src/*)
        dir_context="frontend"
        ;;
    */api|*/api/*)
        dir_context="api"  # Add custom context
        ;;
    *)
        dir_context=$(basename "$cwd")
        ;;
esac
```

### Customize AWS Detection
Modify the AWS environment detection logic:

```bash
# Check for environment variables
if [ "$AWS_PROFILE" = "prod" ]; then
    aws_env="prod"
elif [ "$AWS_PROFILE" = "dev" ]; then
    aws_env="dev"
fi
```

## Troubleshooting

### Status Line Not Showing
1. **Restart Claude Code**
   ```bash
   # Close Claude Code and restart it
   ```

2. **Check if settings are applied**
   ```bash
   cat ~/.claude/settings.json | jq .statusline
   ```

3. **Verify script is executable**
   ```bash
   ls -la ~/.claude/statusline-command.sh
   ```

### Script Errors
Enable debug logging:
```bash
DEBUG=1 ./install.sh
```

Check the log file:
```bash
cat ~/.claude-statusline-setup.log
```

### Git Information Not Showing
If you're not in a git repository, the status line will show `no repo` instead of branch info. This is normal.

### Model Name Not Displaying
Make sure Claude Code has been used at least once to establish the model context.

### Context Percentage Shows 0%
This can happen early in a conversation. The value updates as you use Claude Code.

### Cost Not Displaying
The cost will only appear after Claude Code has made at least one API call. Early in a session, this field may not be present yet.

## Reinstall / Reset

To reinstall or reset the status line configuration:

```bash
# Remove current installation
rm ~/.claude/statusline-command.sh
rm ~/.claude/settings.json

# Run the installer again
./install.sh
```

Or revert to a backup if one was created:
```bash
cp ~/.claude/settings.json.backup.TIMESTAMP ~/.claude/settings.json
```

## How It Works

The status line is a shell script that:
1. Reads JSON context from Claude Code (including cost telemetry)
2. Detects git repository and branch info
3. Determines directory context
4. Checks AWS environment
5. Extracts session cost from Claude Code's telemetry
6. Formats and displays the information

The script runs with minimal dependencies (bash, git, jq) and completes in milliseconds.

## Advanced: Custom Formatting

To customize the output format, edit the status line script:

```bash
# Change separator from " | " to " • "
status_line="$status_line • $git_info"

# Add emojis
status_line="🚀 $project | 🌿 $git_info"

# Change order of components
status_line="$model_short | $project | $git_info"
```

## Support & Issues

- **Claude Code**: https://claude.com/claude-code
- **This Script**: Check `~/.claude-statusline-setup.log` for logs

## License

MIT - Use freely, modify as needed

---

**Tip**: This works best alongside a sophisticated terminal like Ghosty and Starship. See the `ghosty-setup` folder for companion installation.
