# Dev Stack Config

Opinionated setup scripts for a sophisticated developer environment on macOS. Get a beautiful, productive terminal with intelligent prompts and IDE-level awareness.

## What's Included

Two carefully crafted setup tools to enhance your development workflow:

### 1. 🖥️ [Ghosty + Starship Terminal Setup](./ghosty-setup/)

Complete macOS terminal configuration combining:
- **Ghosty** - Fast GPU-accelerated terminal emulator with glassmorphic design
- **Starship** - Intelligent shell prompt with git awareness and language detection

**Features:**
- Tokyo Night Storm dark theme (easy on the eyes)
- Git branch, status, and remote tracking
- Programming language version display (Python, Node.js, Rust, Go, Java)
- AWS profile and region indicator
- Command execution timing
- Drop-down quick terminal with `Cmd+Backtick`
- 50k line scrollback history

**Installation:**
```bash
cd ghosty-setup
./install.sh
```

[→ Full documentation](./ghosty-setup/README.md)

---

### 2. 🤖 [Claude Code Status Line](./claude-statusline/)

Sophisticated status line for Claude Code that displays:
- Project and git context at a glance
- Directory awareness (frontend/infra/testing/lambda)
- AWS environment indicator (dev/prod)
- Claude model in use
- Remaining conversation context

**Example:**
```
my-project | main ✓ | infra/cdk | aws:dev | sonnet-4-5 | ctx:85%
```

**Installation:**
```bash
cd claude-statusline
./install.sh
```

[→ Full documentation](./claude-statusline/README.md)

---

## ⚠️ Disclaimer: macOS Only

Both scripts are designed **exclusively for macOS**. They:
- Use Homebrew for package management
- Rely on macOS-specific features
- Require Homebrew to be installed
- Are optimized for Apple Silicon and Intel Macs

## Prerequisites

- **macOS** 10.13 or newer
- **Homebrew** - Install from https://brew.sh
- **Internet connection** - To download packages
- **Claude Code CLI** (for status line setup)

## Quick Start

```bash
# Clone or download this repository
git clone https://github.com/sc40/dev-stack-config.git
cd dev-stack-config

# Option 1: Setup Ghosty + Starship terminal
cd ghosty-setup && ./install.sh

# Option 2: Setup Claude Code status line
cd ../claude-statusline && ./install.sh

# Or do both!
```

## Features Explained

### Terminal Workflow
- **Fast**: GPU-accelerated Ghosty, Rust-powered Starship
- **Contextual**: Automatic git status, language versions, AWS profile
- **Discoverable**: Quick visual feedback on repo state
- **Productive**: 50k scrollback, copy-on-select, quick terminal

### Development Awareness
The prompt shows:
- Which project you're in
- Git branch and status (clean/dirty)
- How many commits ahead/behind remote
- Active programming languages and versions
- AWS profile and region (if applicable)
- Command execution time (slow commands only)
- Exit status (red ✘ if last command failed)

### Claude Code Integration
The status line provides:
- Project context awareness
- Git-aware development indicators
- AWS environment at a glance
- Active Claude model display
- Conversation context usage tracking

## Configuration

Both scripts create configuration files you can edit:

**Ghosty:**
- `~/.config/ghostty/config` - Terminal appearance, colors, keyboard bindings
- `~/.config/starship.toml` - Shell prompt format and modules

**Claude Code:**
- `~/.claude/settings.json` - Claude settings
- `~/.claude/statusline-command.sh` - Status line script

Edit these files directly to customize further.

## Troubleshooting

### General
- Enable debug: `DEBUG=1 ./install.sh`
- Check logs: `cat ~/.ghosty-setup.log` or `cat ~/.claude-statusline-setup.log`
- Restart your application after installation

### Ghosty Not Found After Install
```bash
# Add Homebrew to PATH if needed
export PATH="/opt/homebrew/bin:$PATH"
```

### Starship Prompt Not Showing
```bash
# Restart your shell
source ~/.zshrc    # or ~/.bashrc
```

### Claude Status Line Not Appearing
```bash
# Restart Claude Code
# Check that ~/.claude/settings.json exists and is valid JSON
```

## Customization

Both setups are highly customizable. See the individual README files for:
- Theme changes
- Font customization
- Prompt format modification
- Adding/removing status indicators
- Color scheme customization

## What's Different

This is **not** your typical dotfiles repo. Instead:
- ✅ Automated installation via scripts
- ✅ Comprehensive error handling and logging
- ✅ Backup creation for existing configs
- ✅ Verification after installation
- ✅ Interactive troubleshooting
- ✅ Opinionated but customizable defaults

## Contributing

These are personal setup scripts, but feel free to:
- Fork and customize for your needs
- Report issues or suggestions
- Share improvements

## License

MIT - Use freely, modify as needed

---

## Learn More

- **Ghosty**: https://ghostty.org
- **Starship**: https://starship.rs
- **Claude Code**: https://claude.com/claude-code
- **Homebrew**: https://brew.sh

---

**Made with ❤️ for developers who like their tools configured just right.**
