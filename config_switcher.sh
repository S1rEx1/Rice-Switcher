#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/switch.sh"
source "$SCRIPT_DIR/lib/buffer.sh"
source "$SCRIPT_DIR/lib/tui.sh"

main() {
    load_config
    
    if [[ $# -eq 0 ]]; then
        if command -v dialog &> /dev/null; then
            show_interactive_menu
        else
            show_simple_menu
        fi
        return
    fi
    
    case "${1:-}" in
        "switch")
            if [[ -z "${2:-}" ]]; then
                if command -v dialog &> /dev/null; then
                    show_config_selection_menu
                else
                    echo "Usage: $0 switch <config_name>"
                    list_available_configs
                    exit 1
                fi
            else
                switch_to_config "$2"
            fi
            ;;
        "list")
            list_available_configs
            ;;
        "buffer")
            show_buffer_contents
            ;;
        "interactive"|"menu")
            if command -v dialog &> /dev/null; then
                show_interactive_menu
            else
                show_simple_menu
            fi
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            echo "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

show_simple_menu() {
    echo "=== Config Switcher ==="
    echo "1) Switch Config"
    echo "2) List Configs"
    echo "3) View Buffer"
    echo "4) Exit"
    read -p "Choose [1-4]: " choice
    
    case $choice in
        1)
            list_available_configs
            read -p "Enter config name: " config
            switch_to_config "$config"
            ;;
        2)
            list_available_configs
            ;;
        3)
            show_buffer_contents
            ;;
        4)
            exit 0
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

main "$@"