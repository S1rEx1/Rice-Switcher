#!/bin/bash

CONFIG_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config.json"

RICES_DIR=""
BUFFER_DIR=""
BUFFER_SIZE=2
USE_SYMLINKS=false

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
    echo "  interactive      Launch interactive TUI"
    echo "  menu             Launch interactive TUI"
    echo "  help             Show this help"
    echo ""
    echo "If no command is provided, launches interactive mode"
    echo ""
    echo "Configure paths in: $CONFIG_FILE"
}