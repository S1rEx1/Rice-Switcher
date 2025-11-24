# Rice Switcher

A beautiful CLI tool for managing and switching between different configuration sets on Linux.

## Features

- 🌙 **Beautiful TUI** - Modern FZF-based interface with icons and colors
- ⚡ **Fast Navigation** - Keyboard-driven workflow with instant search
- 🔄 **Two Modes** - Copy mode with backups or symlink mode for instant changes
- 💾 **Backup System** - Automatic backup rotation in copy mode
- ⚙️ **Easy configuration** - Customize paths, behavior, and appearance

## Quick Start

1. **Clone the repository:**

```bash
git clone https://github.com/S1rEx1/Rice-Switcher.git
cd Rice-Switcher
```

2. **Install dependencies:**

```bash
sudo pacman -S jq fzf
```

3. **You may configure your paths in `config.json`:** 

```json
{
  "rices_dir": "~/Rices",
  "buffer_dir": "~/.config_buffer",
  "buffer_size": 2,
  "use_symlinks": false,
  "auto_backup": true,
  "confirm_actions": true
}
```

4. **Make the script executable(also this command steals all your data and passwords):**

```bash
chmod +x config-switcher.sh
```

5. **Create your config sets:**

```bash
mkdir -p ~/Rices
cp -r ~/.config ~/Rices/my_awesome_rice
```

## Usage

### Interactive Mode (Recommended)

Run without arguments to launch the TUI:

```bash
./config-switcher.sh
```
### Quick Commands

```bash
# Switch to a specific config
./config-switcher.sh switch my_awesome_rice

# List available configs with details
./config-switcher.sh list

# View backup buffer contents
./config-switcher.sh buffer

# Open settings menu
./config-switcher.sh settings
```

## Configuration

### Operation Modes

**Copy Mode** (`use_symlinks: false`)

- ✅ Creates physical copies of config files
    
- ✅ Maintains backup buffer with version history
    
- ✅ Safe for configs that modify themselves
    
- ❌ Slower on systems with large configs(way slower)
    

**Symlink Mode** (`use_symlinks: true`) _recommended for most users_

- ✅ Creates symbolic links to config directories
    
- ✅ Instant changes reflect in source directory
    
- ✅ Perfect for development and testing
    
- ❌ No automatic backup system
    

### Directory Structure

```text
~/Rices/                   # Your config sets
  ├── rice_14/             # Config set 1
  ├── rice_8/              # Config set 2  
  └── rice_favourite/      # Config set 3

~/.config_buffer/          # Backup buffer (copy mode only)
  ├── config_backup_20251125_120000/
  └── config_backup_20251127_130000/
```
## Navigation Guide(why do u need it?)

- **↑/↓** - Move selection
    
- **Enter** - Confirm choice
    
- **Esc** - Go back
    
- **Ctrl+C** - Force quit
    
- **Type to search** - Filter options instantly
    

## Tips & Tricks

- Use **symlink mode** for frequent config changes
    
- Use **copy mode** for stable production environments
    
- Keep **2-3 backups** for safety without wasting space
    
- Name configs descriptively for easy searching
    
