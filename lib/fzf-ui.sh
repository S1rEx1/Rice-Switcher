#!/bin/bash

check_fzf_dependency() {
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is required but not installed."
    echo "Install with: sudo pacman -S fzf"
    exit 1
  fi
}

show_main_menu() {
  local choice=$(printf "Switch Config\nList Configs\nSettings\nHelp\nExit" | fzf --height=15 --header="🌙 Config Switcher")

  case "$choice" in
  "Switch Config")
    show_config_menu
    ;;
  "List Configs")
    list_available_configs
    read -p "Press enter to continue..."
    show_main_menu
    ;;
  "Settings")
    show_settings_menu
    ;;
  "Help")
    show_help
    read -p "Press enter to continue..."
    show_main_menu
    ;;
  "Exit")
    echo "Goodbye!"
    exit 0
    ;;
  *)
    show_main_menu
    ;;
  esac
}

show_config_menu() {
  if [[ ! -d "$RICES_DIR" ]]; then
    echo "Error: Rices directory not found: $RICES_DIR"
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
    echo "No configs found in $RICES_DIR"
    read -p "Press enter to continue..."
    show_main_menu
    return
  fi

  local selected_config=$(printf "%s\n" "${configs[@]}" | fzf --height=15 --header="Select Config")

  if [[ -n "$selected_config" ]]; then
    switch_to_config "$selected_config"
    read -p "Press enter to continue..."
  fi

  show_main_menu
}

show_settings_menu() {
  local choice=$(printf "View Current Settings\nChange Rices Directory\nChange Buffer Directory\nToggle Symlinks Mode\nChange Buffer Size\nToggle Auto Backup\nToggle Confirmations\nReset to Defaults\nBack to Main Menu" | fzf --height=15 --header="Settings")

  case "$choice" in
  "View Current Settings")
    clear
    show_current_settings
    read -p "Press enter to continue..."
    show_settings_menu
    ;;
  "Change Rices Directory")
    change_rices_directory
    ;;
  "Change Buffer Directory")
    change_buffer_directory
    ;;
  "Toggle Symlinks Mode")
    toggle_symlinks_mode
    ;;
  "Change Buffer Size")
    change_buffer_size
    ;;
  "Toggle Auto Backup")
    toggle_auto_backup
    ;;
  "Toggle Confirmations")
    toggle_confirmations
    ;;
  "Reset to Defaults")
    reset_settings
    read -p "Press enter to continue..."
    show_settings_menu
    ;;
  "Back to Main Menu")
    show_main_menu
    ;;
  *)
    show_settings_menu
    ;;
  esac
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
