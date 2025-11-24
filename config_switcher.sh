#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh" 
source "$SCRIPT_DIR/lib/switch.sh"
source "$SCRIPT_DIR/lib/buffer.sh"
source "$SCRIPT_DIR/lib/tui.sh"
source "$SCRIPT_DIR/lib/settings.sh"

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
        "settings")
            if command -v dialog &> /dev/null; then
                show_settings_menu
            else
                show_simple_settings_menu
            fi
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
    while true; do
        echo "=== Config Switcher ==="
        echo "1) Switch Config"
        echo "2) List Configs"
        echo "3) View Buffer"
        echo "4) Settings"
        echo "5) Help"
        echo "6) Exit"
        read -p "Choose [1-6]: " choice
        
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
                show_simple_settings_menu
                ;;
            5)
                show_help
                ;;
            6)
                exit 0
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
        
        read -p "Press enter to continue..."
        clear
    done
}

show_simple_settings_menu() {
    while true; do
        echo "=== Settings ==="
        echo "1) View Current Settings"
        echo "2) Change Rices Directory"
        echo "3) Change Buffer Directory"
        echo "4) Toggle Symlinks Mode"
        echo "5) Change Buffer Size"
        echo "6) Toggle Auto Backup"
        echo "7) Toggle Confirmations"
        echo "8) Reset to Defaults"
        echo "9) Back to Main Menu"
        read -p "Choose [1-9]: " choice
        
        case $choice in
            1)
                show_current_settings
                ;;
            2)
                read -p "Enter new rices directory: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "rices_dir" "$new_value"
                fi
                ;;
            3)
                read -p "Enter new buffer directory: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "buffer_dir" "$new_value"
                fi
                ;;
            4)
                new_value=$([[ "$USE_SYMLINKS" == "true" ]] && echo "false" || echo "true")
                update_setting "use_symlinks" "$new_value"
                ;;
            5)
                read -p "Enter new buffer size: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "buffer_size" "$new_value"
                fi
                ;;
            6)
                new_value=$([[ "$AUTO_BACKUP" == "true" ]] && echo "false" || echo "true")
                update_setting "auto_backup" "$new_value"
                ;;
            7)
                new_value=$([[ "$CONFIRM_ACTIONS" == "true" ]] && echo "false" || echo "true")
                update_setting "confirm_actions" "$new_value"
                ;;
            8)
                reset_settings
                ;;
            9)
                return
                ;;
            *)
                echo "Invalid choice"
                ;;
        esac
        
        read -p "Press enter to continue..."
        clear
    done
}

main "$@"