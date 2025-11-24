#!/bin/bash

CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config.json"

RICES_DIR=""
BUFFER_DIR=""
BUFFER_SIZE=2
USE_SYMLINKS=false
AUTO_BACKUP=true
BACKUP_ON_SWITCH=true
CONFIRM_ACTIONS=true
THEME="default"
LOG_LEVEL="info"
MAX_LOG_FILES=5
EXCLUDED_FOLDERS=()
NOTIFICATIONS=true

load_config() {
    check_dependencies
    
    local config_path=$(expand_path "$CONFIG_FILE")
    if [[ ! -f "$config_path" ]]; then
        fatal "Config file not found: $config_path"
    fi
    
    RICES_DIR=$(expand_path "$(jq -r '.rices_dir' "$config_path")")
    BUFFER_DIR=$(expand_path "$(jq -r '.buffer_dir' "$config_path")")
    BUFFER_SIZE=$(jq -r '.buffer_size' "$config_path")
    USE_SYMLINKS=$(jq -r '.use_symlinks' "$config_path")
    AUTO_BACKUP=$(jq -r '.auto_backup' "$config_path")
    BACKUP_ON_SWITCH=$(jq -r '.backup_on_switch' "$config_path")
    CONFIRM_ACTIONS=$(jq -r '.confirm_actions' "$config_path")
    THEME=$(jq -r '.theme' "$config_path")
    LOG_LEVEL=$(jq -r '.log_level' "$config_path")
    MAX_LOG_FILES=$(jq -r '.max_log_files' "$config_path")
    NOTIFICATIONS=$(jq -r '.notifications' "$config_path")
    
    EXCLUDED_FOLDERS=()
    while IFS= read -r folder; do
        EXCLUDED_FOLDERS+=("$folder")
    done < <(jq -r '.excluded_folders[]?' "$config_path")
    
    mkdir -p "$RICES_DIR"
    if [[ "$USE_SYMLINKS" == "false" ]]; then
        mkdir -p "$BUFFER_DIR"
    fi
}

list_available_configs() {
    echo "Available configs in $RICES_DIR:"
    for config in "$RICES_DIR"/*; do
        if [[ -d "$config" ]]; then
            echo "  - $(basename "$config")"
        fi
    done
}

show_help() {
    echo "Config Switcher - Manage your dotfiles"
    echo ""
    echo "Commands:"
    echo "  switch <name>    Switch to specified config"
    echo "  list             List available configs" 
    echo "  buffer           Show buffer contents"
    echo "  settings         Manage application settings"
    echo "  interactive      Launch interactive TUI"
    echo "  menu             Launch interactive TUI"
    echo "  help             Show this help"
    echo ""
    echo "If no command is provided, launches interactive mode"
    echo ""
    echo "Configure paths in: $CONFIG_FILE"
}