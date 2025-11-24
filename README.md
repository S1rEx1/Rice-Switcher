# Rice-Switcher

# Config Switcher

A CLI tool for managing and switching between different configuration sets on Linux.

## Features

-   Switch between multiple config sets
-   Two operation modes: copy and symlink
-   Automatic backup rotation in copy mode
-   Simple TUI

## Quick Start

1. Clone the repository:

```bash
git clone https://github.com/S1rEx1/Rice-Switcher.git
cd Rice-Switcher
```

2. Install dependencies:

```bash
sudo pacman -S jq dialog
```

3. Configure your paths in `config.json`:

```json
{
    "rices_dir": "~/Rices",
    "buffer_dir": "~/.config_buffer",
    ...
}
```

4. Make the script executable:

```bash
chmod +x config-switcher.sh
```

5. Create your config sets in the Rices directory:

```bash
mkdir -p ~/Rices
cp -r ~/.config ~/Rices/my_config
```

## Usage

### Interactive Mode (Recommended)

Run without arguments to launch the interactive menu:

```bash
./config-switcher.sh
```

### Command Line

```bash
# Switch to a specific config
./config-switcher.sh switch name_of_config

# List available configs
./config-switcher.sh list

# View backup buffer
./config-switcher.sh buffer
```

## Configuration

### Operation Modes

**Copy Mode** (`use_symlinks: false`)

-   Creates physical copies of config files
-   Maintains backup buffer with version history
-   Safe for configs that modify themselves

-   Very slow on well-configured systems

**Symlink Mode** (`use_symlinks: true`) _recommended_

-   Creates symbolic links to config directories
-   No backup buffer needed
-   Instant changes reflect in source directory

### Directory Structure

```text
~/Rices/                   # Your config sets
  ├── rice_14/             # Config set 1 }
  ├── rice_8/              # Config set 2 } they are renamed .config/
  └── rice_favourite/      # Config set 3 }

~/.config_buffer/        # Backup buffer (copy mode only)
  ├── config_backup_20251125_120000/
  └── config_backup_20251127_130000/
```
