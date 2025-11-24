#!/bin/bash

expand_path() {
    local path="$1"
    echo "${path//\~/$HOME}"
}

check_dependencies() {
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required but not installed. Install with: sudo pacman -S jq"
        exit 1
    fi
}

fatal() {
    echo "Error: $1"
    exit 1
}

confirm() {
    local message="$1"
    read -p "$message (y/N): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}