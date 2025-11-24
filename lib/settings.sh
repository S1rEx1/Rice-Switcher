#!/bin/bash

show_current_settings() {
    echo "Current Settings:"
    echo "================="
    echo "Rices Directory: $RICES_DIR"
    echo "Buffer Directory: $BUFFER_DIR"
    echo "Buffer Size: $BUFFER_SIZE"
    echo "Use Symlinks: $USE_SYMLINKS"
    echo "Auto Backup: $AUTO_BACKUP"
    echo "Backup on Switch: $BACKUP_ON_SWITCH"
    echo "Confirm Actions: $CONFIRM_ACTIONS"
    echo "Theme: $THEME"
    echo "Log Level: $LOG_LEVEL"
    echo "Max Log Files: $MAX_LOG_FILES"
    echo "Notifications: $NOTIFICATIONS"
    echo "Excluded Folders: ${EXCLUDED_FOLDERS[*]}"
}

update_setting() {
    local key="$1"
    local value="$2"
    local config_path=$(expand_path "$CONFIG_FILE")
    
    if [[ ! -f "$config_path" ]]; then
        fatal "Config file not found: $config_path"
    fi
    
    case "$key" in
        "rices_dir"|"buffer_dir")
            value=$(expand_path "$value")
            ;;
        "buffer_size"|"max_log_files")
            if ! [[ "$value" =~ ^[0-9]+$ ]]; then
                fatal "Value must be a number: $key"
            fi
            ;;
        "use_symlinks"|"auto_backup"|"backup_on_switch"|"confirm_actions"|"notifications")
            if [[ "$value" != "true" && "$value" != "false" ]]; then
                fatal "Value must be 'true' or 'false': $key"
            fi
            ;;
        "log_level")
            if [[ "$value" != "error" && "$value" != "warn" && "$value" != "info" && "$value" != "debug" ]]; then
                fatal "Log level must be: error, warn, info, or debug"
            fi
            ;;
    esac
    
    jq ".$key = \"$value\"" "$config_path" > "${config_path}.tmp" && mv "${config_path}.tmp" "$config_path"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Updated $key to $value"
        load_config
    else
        fatal "Failed to update setting: $key"
    fi
}

show_settings_menu() {
    while true; do
        choice=$(dialog --clear \
            --backtitle "Config Switcher - Settings" \
            --title "Settings Menu" \
            --menu "Choose a setting to modify:" \
            20 60 12 \
            "1" "Rices Directory: $RICES_DIR" \
            "2" "Buffer Directory: $BUFFER_DIR" \
            "3" "Buffer Size: $BUFFER_SIZE" \
            "4" "Use Symlinks: $USE_SYMLINKS" \
            "5" "Auto Backup: $AUTO_BACKUP" \
            "6" "Backup on Switch: $BACKUP_ON_SWITCH" \
            "7" "Confirm Actions: $CONFIRM_ACTIONS" \
            "8" "Log Level: $LOG_LEVEL" \
            "9" "Max Log Files: $MAX_LOG_FILES" \
            "10" "Notifications: $NOTIFICATIONS" \
            "11" "View All Settings" \
            "12" "Back to Main Menu" \
            2>&1 >/dev/tty)
        
        clear
        
        case $choice in
            1)
                read -p "Enter new rices directory: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "rices_dir" "$new_value"
                fi
                ;;
            2)
                read -p "Enter new buffer directory: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "buffer_dir" "$new_value"
                fi
                ;;
            3)
                read -p "Enter new buffer size: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "buffer_size" "$new_value"
                fi
                ;;
            4)
                new_value=$([[ "$USE_SYMLINKS" == "true" ]] && echo "false" || echo "true")
                update_setting "use_symlinks" "$new_value"
                ;;
            5)
                new_value=$([[ "$AUTO_BACKUP" == "true" ]] && echo "false" || echo "true")
                update_setting "auto_backup" "$new_value"
                ;;
            6)
                new_value=$([[ "$BACKUP_ON_SWITCH" == "true" ]] && echo "false" || echo "true")
                update_setting "backup_on_switch" "$new_value"
                ;;
            7)
                new_value=$([[ "$CONFIRM_ACTIONS" == "true" ]] && echo "false" || echo "true")
                update_setting "confirm_actions" "$new_value"
                ;;
            8)
                read -p "Enter log level (error/warn/info/debug): " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "log_level" "$new_value"
                fi
                ;;
            9)
                read -p "Enter max log files: " new_value
                if [[ -n "$new_value" ]]; then
                    update_setting "max_log_files" "$new_value"
                fi
                ;;
            10)
                new_value=$([[ "$NOTIFICATIONS" == "true" ]] && echo "false" || echo "true")
                update_setting "notifications" "$new_value"
                ;;
            11)
                show_current_settings
                read -p "Press enter to continue..."
                ;;
            12)
                return
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
        
        read -p "Press enter to continue..."
    done
}

reset_settings() {
    if confirm "This will reset all settings to defaults. Continue?"; then
        local default_config='{
  "rices_dir": "~/Rices",
  "buffer_dir": "~/.config_buffer",
  "buffer_size": 2,
  "use_symlinks": false,
  "auto_backup": true,
  "backup_on_switch": true,
  "confirm_actions": true,
  "theme": "default",
  "log_level": "info",
  "max_log_files": 5,
  "excluded_folders": [""],
  "notifications": true
}'
        echo "$default_config" > "$(expand_path "$CONFIG_FILE")"
        load_config
        echo "✅ Settings reset to defaults"
    fi
}