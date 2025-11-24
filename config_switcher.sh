#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/switch.sh"
source "$SCRIPT_DIR/lib/buffer.sh"

main() {
    load_config
    
    case "${1:-}" in
        "switch")
            if [[ -z "${2:-}" ]]; then
                echo "Usage: $0 switch <config_name>"
                list_available_configs
                exit 1
            fi
            switch_to_config "$2"
            ;;
        "list")
            list_available_configs
            ;;
        "buffer")
            show_buffer_contents
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

main "$@"