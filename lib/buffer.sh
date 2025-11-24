#!/bin/bash

show_buffer_contents() {
    if [[ "$USE_SYMLINKS" == "true" ]]; then
        echo "Buffer is disabled in symlink mode"
        return
    fi
    
    echo "Buffer contents ($BUFFER_DIR):"
    local backups=($(ls -1t "$BUFFER_DIR" 2>/dev/null || true))
    if [[ ${#backups[@]} -eq 0 ]]; then
        echo "  (empty)"
    else
        for backup in "${backups[@]}"; do
            echo "  - $backup"
        done
    fi
}

backup_current_config() {
    if [[ "$USE_SYMLINKS" == "true" ]]; then
        return 0
    fi
    
    local current_config="$HOME/.config"
    
    if [[ ! -d "$current_config" ]]; then
        echo "No existing .config found, skipping backup"
        return 0
    fi
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="config_backup_$timestamp"
    local backup_path="$BUFFER_DIR/$backup_name"
    
    echo "Moving current .config to buffer: $backup_name"
    mv "$current_config" "$backup_path"
    
    cleanup_old_backups
}

cleanup_old_backups() {
    local backups=($(ls -1t "$BUFFER_DIR" | grep "^config_backup_" 2>/dev/null || true))
    local count=${#backups[@]}
    
    if [[ $count -gt $BUFFER_SIZE ]]; then
        local to_delete=$((count - BUFFER_SIZE))
        echo "Cleaning up $to_delete old backup(s)..."
        for ((i=count-1; i>=count-to_delete; i--)); do
            local backup_to_delete="${backups[i]}"
            echo "Removing old backup: $backup_to_delete"
            rm -rf "$BUFFER_DIR/$backup_to_delete"
        done
    fi
}

restore_from_buffer() {
    if [[ "$USE_SYMLINKS" == "true" ]]; then
        echo "Restore not available in symlink mode"
        return 1
    fi
    
    local backup_name="$1"
    local backup_path="$BUFFER_DIR/$backup_name"
    local current_config="$HOME/.config"
    
    if [[ ! -d "$backup_path" ]]; then
        echo "Backup '$backup_name' not found in buffer"
        return 1
    fi
    
    if [[ -d "$current_config" ]]; then
        if ! confirm "Current .config will be moved to buffer. Continue?"; then
            return 1
        fi
        backup_current_config
    fi
    
    echo "Restoring $backup_name to .config"
    mv "$backup_path" "$current_config"
    echo "✅ Config restored from buffer"
}