#!/bin/bash

FZF_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$FZF_LIB_DIR/rices.sh" ]]; then
  # shellcheck disable=SC1090
  source "$FZF_LIB_DIR/rices.sh"
fi

check_fzf_dependency() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is required but not installed."
    echo "Install with: sudo pacman -S fzf"
    exit 1
  fi
}

show_main_menu() {
  local preview_cmd='
        if [[ {} =~ "List Configs" ]]; then
            echo "󰈙 Available Configs:"
            echo "──────────────────"
            ls -1 "'"$RICES_DIR"'" 2>/dev/null | head -5
            echo ""
            echo "Total: $(ls -1 "'"$RICES_DIR"'" 2>/dev/null | wc -l) configs"
        elif [[ {} =~ "Switch Config" ]]; then
            echo "󰚌 Switch to a different config"
            echo ""
            echo "Current mode: $([[ "'"$USE_SYMLINKS"'" == "true" ]] && echo "symlinks" || echo "copy")"
        elif [[ {} =~ "Install Rice" ]]; then
            echo "󰏘 Install community rices"
            echo ""
            echo "Shows curated list with screenshots"
        elif [[ {} =~ "Settings" ]]; then
            echo "󰒓 Configure application settings"
            echo ""
            echo "Symlinks: $([[ "'"$USE_SYMLINKS"'" == "true" ]] && echo "󰄲" || echo "󰄱")"
            echo "Buffer: '"$BUFFER_SIZE"' backups"
        elif [[ {} =~ "Help" ]]; then
            echo " Show help and usage information"
        else
            echo "󰗼 Exit the application"
        fi
    '

  local choice=$(printf "󰚌 Switch Config\n󰈙 List Configs\n󰏘 Install Rice\n󰒓 Settings\n Help\n󰗼 Exit" | fzf \
    --height=15 \
    --header="🌙 Config Switcher" \
    --prompt="❯ " \
    --ansi \
    --preview="$preview_cmd" \
    --preview-window=right:60%:wrap)

  case "$choice" in
  *"Switch Config")
    show_config_menu
    ;;
  *"List Configs")
    clear
    show_enhanced_config_list
    read -p "Press enter to continue..."
    clear
    show_main_menu
    ;;
  *"Install Rice")
    clear
    show_install_rice_catalog
    clear
    show_main_menu
    ;;
  *"Settings")
    show_settings_menu
    ;;
  *"Help")
    clear
    show_enhanced_help
    read -p "Press enter to continue..."
    clear
    show_main_menu
    ;;
  *"Exit")
    echo "󰗼 Goodbye!"
    exit 0
    ;;
  *)
    show_main_menu
    ;;
  esac
}

show_config_menu() {
  if [[ ! -d "$RICES_DIR" ]]; then
    echo "󰚌 Error: Rices directory not found: $RICES_DIR"
    read -p "Press enter to continue..."
    show_main_menu
    return
  fi

  local configs=()
  for config in "$RICES_DIR"/*; do
    if [[ -d "$config" ]]; then
      configs+=("$(basename "$config")")
    fi
  done

  if [[ ${#configs[@]} -eq 0 ]]; then
    echo "󰚌 No configs found in $RICES_DIR"
    read -p "Press enter to continue..."
    show_main_menu
    return
  fi

  local selected_config=$(printf "%s\n" "${configs[@]}" | fzf \
    --height=15 \
    --header="󰚌 Select Config (Enter to select, ESC to go back)" \
    --prompt="❯ " \
    --preview="echo '󰚌 Preview: {}'; ls -la '$RICES_DIR/{}' 2>/dev/null | head -20" \
    --preview-window=right:60%:wrap \
    --ansi)

  if [[ -n "$selected_config" ]]; then
    switch_to_config "$selected_config"
    read -p "󰚌 Press enter to continue..."
  fi

  show_main_menu
}

show_settings_menu() {
  local symlink_status=$([[ "$USE_SYMLINKS" == "true" ]] && echo "󰄲" || echo "󰄱")
  local backup_status=$([[ "$AUTO_BACKUP" == "true" ]] && echo "󰄲" || echo "󰄱")
  local confirm_status=$([[ "$CONFIRM_ACTIONS" == "true" ]] && echo "󰄲" || echo "󰄱")

  local choice=$(printf "󰒓 View Current Settings\n� Change Rices Directory\n󰆵 Change Buffer Directory\n󰒓 Toggle Symlinks Mode [$symlink_status]\n󰆊 Change Buffer Size [$BUFFER_SIZE]\n󰒓 Toggle Auto Backup [$backup_status]\n󰒓 Toggle Confirmations [$confirm_status]\n󰔄 Reset to Defaults\n󰗼 Back to Main Menu" | fzf --height=15 --header="Settings" --ansi)

  case "$choice" in
  *"View Current Settings")
    clear
    show_current_settings
    read -p "Press enter to continue..."
    show_settings_menu
    ;;
  *"Change Rices Directory")
    change_rices_directory
    ;;
  *"Change Buffer Directory")
    change_buffer_directory
    ;;
  *"Toggle Symlinks Mode"*)
    toggle_symlinks_mode
    ;;
  *"Change Buffer Size"*)
    change_buffer_size
    ;;
  *"Toggle Auto Backup"*)
    toggle_auto_backup
    ;;
  *"Toggle Confirmations"*)
    toggle_confirmations
    ;;
  *"Reset to Defaults")
    reset_settings
    read -p "Press enter to continue..."
    show_settings_menu
    ;;
  *"Back to Main Menu")
    show_main_menu
    ;;
  *)
    show_settings_menu
    ;;
  esac
}

show_enhanced_config_list() {
  echo "󰈙 Available Configs in $RICES_DIR:"
  echo "────────────────────────────────"
  for config in "$RICES_DIR"/*; do
    if [[ -d "$config" ]]; then
      local config_name=$(basename "$config")
      local file_count=$(find "$config" -type f | wc -l)
      local size=$(du -sh "$config" 2>/dev/null | cut -f1)
      echo "  󰚌 $config_name"
      echo "    󰉋 Files: $file_count | 󰃢 Size: $size"
      echo ""
    fi
  done
}

show_enhanced_help() {
  echo "󰄨 Config Switcher Help"
  echo "─────────────────────"
  echo ""
  echo "󰚌 Switch Config - Change current .config to selected rice"
  echo "󰈙 List Configs - Show all available configs with details"
  echo "󰏘 Install Rice - Browse curated presets with screenshots"
  echo "󰒓 Settings - Configure application behavior"
  echo "󰗼 Exit - Close the application"
  echo ""
  echo "󰘔 Navigation:"
  echo "  ↑↓ - Move selection"
  echo "  Enter - Confirm choice"
  echo "  Esc - Go back/Exit"
  echo "  Ctrl+C - Force quit"
  echo ""
  echo "󰒓 Current Mode: $([[ "$USE_SYMLINKS" == "true" ]] && echo "Symlinks" || echo "Copy")"
  echo "󰆵 Buffer Size: $BUFFER_SIZE backups"
}

change_rices_directory() {
  read -p "Enter new rices directory: " new_dir
  if [[ -n "$new_dir" ]]; then
    update_setting "rices_dir" "$new_dir"
  fi
  show_settings_menu
}

change_buffer_directory() {
  read -p "Enter new buffer directory: " new_dir
  if [[ -n "$new_dir" ]]; then
    update_setting "buffer_dir" "$new_dir"
  fi
  show_settings_menu
}

toggle_symlinks_mode() {
  local new_value=$([[ "$USE_SYMLINKS" == "true" ]] && echo "false" || echo "true")
  update_setting "use_symlinks" "$new_value"
  show_settings_menu
}

change_buffer_size() {
  read -p "Enter new buffer size: " new_size
  if [[ -n "$new_size" ]]; then
    update_setting "buffer_size" "$new_size"
  fi
  show_settings_menu
}

toggle_auto_backup() {
  local new_value=$([[ "$AUTO_BACKUP" == "true" ]] && echo "false" || echo "true")
  update_setting "auto_backup" "$new_value"
  show_settings_menu
}

toggle_confirmations() {
  local new_value=$([[ "$CONFIRM_ACTIONS" == "true" ]] && echo "false" || echo "true")
  update_setting "confirm_actions" "$new_value"
  show_settings_menu
}
