#!/bin/bash

switch_to_config() {
    local config_name="$1"
    local config_path="$RICES_DIR/$config_name"
    local current_config="$HOME/.config"
    
    if [[ ! -d "$config_path" ]]; then
        fatal "Config '$config_name' not found in $RICES_DIR\nAvailable configs: $(ls "$RICES_DIR" 2>/dev/null || echo "none")"
    fi
    
    echo "Switching to config: $config_name"
    echo "Mode: $([[ "$USE_SYMLINKS" == "true" ]] && echo "symlinks" || echo "copy")"
    
    if [[ -d "$current_config" ]] || [[ -L "$current_config" ]]; then
        if ! confirm "This will replace your current .config. Continue?"; then
            echo "Aborted"
            return 1
        fi
    fi
    
    if [[ -e "$current_config" ]]; then
        rm -rf "$current_config"
    fi
    
    if [[ "$USE_SYMLINKS" == "true" ]]; then
        apply_config_symlink "$config_path" "$current_config"
    else
        apply_config_copy "$config_path" "$current_config"
    fi
    
    echo "✅ Successfully switched to $config_name"
}

apply_config_symlink() {
    local source="$1"
    local target="$2"
    
    echo "Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

apply_config_copy() {
    local source="$1"
    local target="$2"
    
    if [[ -d "$target" ]]; then
        backup_current_config
    fi
    
    echo "Copying config: $source to $target"
    cp -r "$source" "$target"
}

validate_config() {
    local config_name="$1"
    local config_path="$RICES_DIR/$config_name"
    
    if [[ ! -d "$config_path" ]]; then
        return 1
    fi
    
    return 0
}