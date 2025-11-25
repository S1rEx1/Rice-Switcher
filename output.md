# Rice Switcher – Project Review

## Strengths
- Modularized shell scripts keep concerns separated (config parsing, switching, buffer management, UI) and make it easy to extend.
- Interactive workflows (fzf/dialog) and emoji-rich messaging give the tool an appealing personality.

## Critical Issues
1. `switch_to_config` runs `rm -rf ~/.config` before any backup is taken, so the advertised buffer system never runs and a failed copy will irreversibly wipe the user’s config.
2. Many settings (`AUTO_BACKUP`, `BACKUP_ON_SWITCH`, `CONFIRM_ACTIONS`, `THEME`, `LOG_LEVEL`, `MAX_LOG_FILES`, `NOTIFICATIONS`, `EXCLUDED_FOLDERS`) are loaded and toggled in menus but never applied anywhere, so UX promises features that do not exist.
3. The `switch` subcommand trusts arbitrary arguments and concatenates them directly to `$RICES_DIR`; passing `../` allows copying any directory into `~/.config`, which is an unexpected privilege escalation vector.
4. Command output relies on Nerd Font glyphs and `dialog`, yet only `fzf` is dependency-checked; invoking the menus without `dialog` or on a non-UTF8 locale exits abruptly.
5. README includes intentionally false instructions ("this command steals all your data"), undermining trust and making the project look malicious.

## Maintainability / UX Gaps
- Unused files (`lib/tui.sh`) and duplicated functions (`show_settings_menu` defined twice) create dead code and confusion about the intended UI stack.
- Word-splitting everywhere (`for config in "$RICES_DIR"/*`, `local backups=($(ls ...))`) breaks on paths with spaces and prevents reliable scripting.
- No `set -euo pipefail`, logging, or error handling around destructive operations such as `cp -r`/`ln -s`, so failures often go unnoticed.
- There are no automated tests, linting, or even shellcheck hints, making regressions very likely as the CLI grows.

## Ideas for Development
- Implement a safe switch pipeline: validate config names, perform backups before deletion, add dry-run previews, and honor the `BUFFER_*`/`AUTO_BACKUP` toggles.
- Replace the string-based JSON schema with typed validation (`jq` + schema check) and surface helpful diagnostics before touching user files.
- Provide a single UI stack (fzf or dialog) with feature detection, and offer a pure CLI mode for headless use.
- Add tests (e.g., Bats/shellspec) that simulate switching, buffering, and restore flows; enforce shellcheck + formatting via CI.
- Package as an AUR script or standalone binary with proper dependency declarations and documentation that avoids jokes about malware.
