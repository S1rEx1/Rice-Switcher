#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/switch.sh"
source "$SCRIPT_DIR/lib/buffer.sh"
source "$SCRIPT_DIR/lib/settings.sh"
source "$SCRIPT_DIR/lib/fzf-ui.sh"

main() {
  load_config
  check_fzf_dependency

  if [[ $# -eq 0 ]]; then
    show_main_menu
    return
  fi

  case "${1:-}" in
  "switch")
    if [[ -z "${2:-}" ]]; then
      show_config_menu
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
    show_settings_menu
    ;;
  "help" | "-h" | "--help")
    show_help
    ;;
  *)
    echo "Unknown command: $1"
    show_help
    exit 1
    ;;
  esac
}

main "$@"

