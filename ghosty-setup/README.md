# Ghosty + Starship Setup for macOS

Complete setup script to install and configure Ghosty terminal emulator and Starship shell prompt with opinionated developer-friendly settings.

## ⚠️ macOS Only

This script is **exclusively for macOS**. It uses Homebrew and macOS-specific features.

## What Gets Installed

- **Ghosty** - Fast GPU-accelerated terminal emulator
- **Starship** - Minimal, customizable shell prompt (with git awareness, language versions, AWS profile, timing info)
- **jq** - JSON processor (required for configuration)

## What Gets Configured

### Ghosty Terminal
- **Font**: JetBrains Mono, 14pt
- **Theme**: Tokyo Night Storm (dark blue/purple palette)
- **Appearance**: 92% opacity, 20px blur, glassmorphic effect
- **Behavior**: 50k line scrollback, copy-on-select, blinking bar cursor
- **Features**: Cmd+` for drop-down quick terminal

### Starship Prompt
- **Git info**: Branch name, clean/dirty status, ahead/behind commits
- **Directory**: Truncated path, repo-aware
- **Languages**: Python, Node.js, Rust, Go, Java versions
- **Cloud**: AWS profile and region display
- **Timing**: Command execution time for slow commands (>2s)
- **Status**: Exit code on error, timestamp on right

## Prerequisites

1. **macOS** (10.13 or newer recommended)
2. **Homebrew** - Install from https://brew.sh
3. **Internet connection** - To download packages

## Installation

### Quick Start
```bash
# Clone this repository
git clone https://github.com/sc40/dev-stack-config.git
cd dev-stack-config/ghosty-setup

# Make script executable
chmod +x install.sh

# Run the installer
./install.sh
```

### What Happens
1. Checks that you're on macOS with Homebrew installed
2. Installs Ghosty (GPU-accelerated terminal)
3. Installs Starship (shell prompt)
4. Installs jq (JSON processor)
5. Configures Ghosty with theme, fonts, and behavior settings
6. Configures Starship with git/language/AWS indicators
7. Adds Starship to your shell config (.zshrc or .bashrc)
8. Verifies all installations succeeded

### Troubleshooting

#### Script Errors
Enable debug logging to see detailed output:
```bash
DEBUG=1 ./install.sh
```

Check the log file:
```bash
cat ~/.ghosty-setup.log
```

#### Ghosty Not Found After Install
Brew may not have added it to PATH. Try:
```bash
# Find Ghostty location
brew --prefix ghostty

# Manually add to PATH in ~/.zshrc or ~/.bashrc
export PATH="/opt/homebrew/bin:$PATH"

# Then restart your shell
```

#### Starship Prompt Not Showing
Make sure your shell is sourcing the config file:
```bash
# For zsh
source ~/.zshrc

# For bash
source ~/.bashrc
```

#### Config Backups
If a config file already exists, it's automatically backed up:
- `~/.config/ghostty/config.backup.[timestamp]`
- `~/.config/starship.toml.backup.[timestamp]`

You can revert by copying the backup:
```bash
cp ~/.config/starship.toml.backup.1234567890 ~/.config/starship.toml
```

## Configuration Files

After installation, your configs are at:
- **Ghostty**: `~/.config/ghostty/config`
- **Starship**: `~/.config/starship.toml`

Edit these files directly to customize further.

## Next Steps After Installation

1. **Launch Ghosty**:
   ```bash
   open -a Ghostty
   ```

2. **Restart your shell**:
   ```bash
   source ~/.zshrc    # or ~/.bashrc
   ```

3. **Verify Starship is working**:
   - You should see a colored prompt with git info
   - Try in a git repo: you'll see branch and status

4. **Try the quick terminal**:
   - Press `Cmd + Backtick` to toggle drop-down terminal

## Customization

### Change Ghosty Theme
Edit `~/.config/ghostty/config`:
```bash
# Change font
font-family = "Hack"
font-size = 12

# Change colors (hex format)
background = 1e1e1e
foreground = d4d4d4
```

### Change Starship Prompt
Edit `~/.config/starship.toml`:
```bash
# Hide specific items
[nodejs]
disabled = true

# Change symbols
[git_branch]
symbol = "🌿 "
```

## Support & Issues

- **Ghosty**: https://ghostty.org
- **Starship**: https://starship.rs
- **This Script**: Check `~/.ghosty-setup.log` for detailed logs

## License

MIT - Use freely, modify as needed

---

**Happy coding!** 🚀
