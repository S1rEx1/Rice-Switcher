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
