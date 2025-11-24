#!/bin/bash

show_interactive_menu() {
    while true; do
        choice=$(dialog --clear \
            --backtitle "Config Switcher" \
            --title "Main Menu" \
            --menu "Choose an option:" \
            17 55 6 \
            "1" "Switch Config" \
            "2" "List Available Configs" \
            "3" "View Buffer Contents" \
            "4" "Settings" \
            "5" "Help" \
            "6" "Exit" \
            2>&1 >/dev/tty)
        
        clear
        
        case $choice in
            1)
                show_config_selection_menu
                ;;
            2)
                list_available_configs
                read -p "Press enter to continue..."
                ;;
            3)
                show_buffer_contents
                read -p "Press enter to continue..."
                ;;
            4)
                show_settings_menu
                ;;
            5)
                show_help
                read -p "Press enter to continue..."
                ;;
            6)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
    done
}

show_config_selection_menu() {
    local configs=()
    local count=0
    
    for config in "$RICES_DIR"/*; do
        if [[ -d "$config" ]]; then
            count=$((count + 1))
            configs+=("$count" "$(basename "$config")")
        fi
    done
    
    if [[ $count -eq 0 ]]; then
        dialog --msgbox "No configs found in $RICES_DIR" 8 50
        return
    fi
    
    choice=$(dialog --clear \
        --backtitle "Config Switcher" \
        --title "Select Config" \
        --menu "Choose a config to switch to:" \
        20 60 10 \
        "${configs[@]}" \
        2>&1 >/dev/tty)
    
    clear
    
    if [[ -n "$choice" ]]; then
        local config_index=$((choice - 1))
        local config_names=($(ls "$RICES_DIR"))
        local selected_config="${config_names[$config_index]}"
        
        if [[ -n "$selected_config" ]]; then
            switch_to_config "$selected_config"
            read -p "Press enter to continue..."
        fi
    fi
}