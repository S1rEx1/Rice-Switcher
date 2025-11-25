#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/switch.sh"
source "$SCRIPT_DIR/lib/buffer.sh"
source "$SCRIPT_DIR/lib/settings.sh"
source "$SCRIPT_DIR/lib/rices.sh"
source "$SCRIPT_DIR/lib/fzf-ui.sh"

print_usage() {
  cat <<'USAGE'
Config Switcher

Usage:
  ./config-switcher.sh                 # Launch interactive menu
  ./config-switcher.sh switch [name]   # Switch to specific config
  ./config-switcher.sh list            # List configs
  ./config-switcher.sh buffer          # Show buffer contents
  ./config-switcher.sh settings        # Open settings UI
  ./config-switcher.sh install         # Open rice installation catalog
  ./config-switcher.sh help            # Show this message
USAGE
}

ensure_fzf_ready() {
  check_fzf_dependency
}

launch_interactive_menu() {
  ensure_fzf_ready
  clear
  show_main_menu
}

handle_switch_command() {
  if [[ -n "${1:-}" ]]; then
    switch_to_config "$1"
  else
    ensure_fzf_ready
    show_config_menu
  fi
}

handle_settings_menu() {
  ensure_fzf_ready
  show_settings_menu
}

handle_install_catalog() {
  ensure_fzf_ready
  show_install_rice_catalog
}

main() {
  load_config

  if [[ $# -eq 0 ]]; then
    launch_interactive_menu
    return
  fi

  case "${1:-}" in
  switch)
    handle_switch_command "${2:-}"
    ;;
  list)
    list_available_configs
    ;;
  buffer)
    show_buffer_contents
    ;;
  settings)
    handle_settings_menu
    ;;
  install)
    handle_install_catalog
    ;;
  menu | interactive)
    launch_interactive_menu
    ;;
  help | -h | --help)
    print_usage
    ;;
  *)
    echo "Unknown command: $1" >&2
    print_usage
    exit 1
    ;;
  esac
}

main "$@"

