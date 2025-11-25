#!/bin/bash

RICE_SWITCHER_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RICE_CATALOG_FILE="$RICE_SWITCHER_ROOT/rices.json"
export RICE_CATALOG_FILE

ensure_rice_catalog() {
  if [[ -f "$RICE_CATALOG_FILE" ]]; then
    return
  fi

  cat >"$RICE_CATALOG_FILE" <<'JSON'
[
  {
    "name": "Sample Rice",
    "description": "Template entry: replace fields with your own rice information.",
    "preview_url": "https://example.com/path/to/rice-preview.png",
    "github_url": "https://github.com/your-handle/sample-rice",
    "install_cmd": "echo 'Replace install_cmd with your own command'"
  }
]
JSON
}

load_rice_entries() {
  ensure_rice_catalog
  jq -c '.[]' "$RICE_CATALOG_FILE" 2>/dev/null || return 1
}

get_rice_entry_by_index() {
  local index="$1"
  jq -c ".[$index]" "$RICE_CATALOG_FILE"
}

format_rice_entries_for_fzf() {
  ensure_rice_catalog
  local entries
  mapfile -t entries < <(jq -c '.[]' "$RICE_CATALOG_FILE") || return 1

  local i entry
  for i in "${!entries[@]}"; do
    entry=${entries[$i]}
    local name description
    name=$(jq -r '.name // "Unnamed Rice"' <<<"$entry")
    description=$(jq -r '.description // ""' <<<"$entry")
    printf '%s\t%s\t%s\n' "$i" "$name" "$description"
  done
}

render_rice_preview() {
  local preview_url="$1"

  if [[ -z "$preview_url" ]]; then
    echo "Preview: not provided"
  else
    echo "Preview URL: $preview_url"
    echo "(Open in browser to view the screenshot)"
  fi
}

show_rice_detail_menu() {
  local entry_json="$1"
  local name description preview_url github_url install_cmd

  name=$(jq -r '.name // "Unnamed Rice"' <<<"$entry_json")
  description=$(jq -r '.description // ""' <<<"$entry_json")
  preview_url=$(jq -r '.preview_url // ""' <<<"$entry_json")
  github_url=$(jq -r '.github_url // ""' <<<"$entry_json")
  install_cmd=$(jq -r '.install_cmd // ""' <<<"$entry_json")

  while true; do
    clear
    echo "󰏘  $name"
    echo "────────────────────────────"
    echo "$description"
    echo
    render_rice_preview "$preview_url"
    echo
    echo "󰠁 GitHub: ${github_url:-not set}"
    echo "󰇅 Command: ${install_cmd:-not set}"
    echo
    echo "[1] Install"
    echo "[2] Open link"
    echo "[3] Back"
    read -p "Choose an option: " choice

    case "$choice" in
    1)
      return 0
      ;;
    2)
      if [[ -n "$github_url" ]]; then
        if command -v xdg-open >/dev/null 2>&1; then
          xdg-open "$github_url" >/dev/null 2>&1 &
        elif command -v open >/dev/null 2>&1; then
          open "$github_url" >/dev/null 2>&1 &
        else
          echo "Open this link manually: $github_url"
        fi
      else
        echo "This rice has no GitHub link configured."
      fi
      read -p "Press Enter to continue..."
      ;;
    3)
      return 1
      ;;
    *)
      echo "Invalid option"
      sleep 0.7
      ;;
    esac
  done
}

run_rice_install_command() {
  local command_to_run="$1"
  if [[ -z "$command_to_run" ]]; then
    echo "󰅖 Install command is empty. Update rices.json."
    return 1
  fi

  bash -lc "$command_to_run"
}

show_install_rice_catalog() {
  local catalog_lines
  if ! catalog_lines=$(format_rice_entries_for_fzf); then
    echo "󰅖 Failed to load rice catalog. Ensure $RICE_CATALOG_FILE is valid JSON."
    read -p "Press Enter to return..."
    return 1
  fi

  if [[ -z "$catalog_lines" ]]; then
    echo "󰅖 No rices defined. Edit $RICE_CATALOG_FILE."
    read -p "Press Enter to return..."
    return 1
  fi

  local preview_cmd=$(cat <<'PREVIEW'
line="{}"
index=$(printf '%s' "$line" | cut -f1)
index_clean=$(printf '%s' "$index" | tr -cd '0-9')
if [ -z "$index_clean" ]; then
  echo "Invalid entry"
  exit 0
fi
entry_json=$(jq -c --arg idx "$index_clean" '.[($idx|tonumber)]' "$RICE_CATALOG_FILE")
if [ -z "$entry_json" ] || [ "$entry_json" = "null" ]; then
  echo "Entry not found"
  exit 0
fi
name=$(printf '%s' "$entry_json" | jq -r '.name // "Unnamed Rice"')
description=$(printf '%s' "$entry_json" | jq -r '.description // ""')
preview_url=$(printf '%s' "$entry_json" | jq -r '.preview_url // ""')
github_url=$(printf '%s' "$entry_json" | jq -r '.github_url // "not set"')
install_cmd=$(printf '%s' "$entry_json" | jq -r '.install_cmd // "not set"')

echo "󰏘  $name"
echo ""
echo "$description"
echo ""

if [ -n "$preview_url" ]; then
  echo "Preview URL: $preview_url"
  echo "(Open in browser to view screenshot)"
else
  echo "Preview: not provided"
fi

echo ""
echo "GitHub: $github_url"
echo ""
echo "Install command:"
echo "$install_cmd"
PREVIEW
)

  local selection
  selection=$(printf '%s\n' "$catalog_lines" | fzf \
    --height=17 \
    --header="Select a rice to install (Enter=confirm, ESC=back)" \
    --prompt="Install ❯ " \
    --with-nth=2,3 \
    --delimiter=$'\t' \
    --preview="$preview_cmd" \
    --preview-window=right:60%:wrap \
    --ansi)

  local fzf_status=$?
  if [[ $fzf_status -ne 0 || -z "$selection" ]]; then
    return 0
  fi

  IFS=$'\t' read -r selected_index _name _desc <<<"$selection"
  local entry_json
  entry_json=$(get_rice_entry_by_index "$selected_index")

  if [[ -z "$entry_json" || "$entry_json" == "null" ]]; then
    echo "󰅖 Selected rice entry not found in $RICE_CATALOG_FILE."
    read -p "Press Enter to continue..."
    return 1
  fi

  if ! show_rice_detail_menu "$entry_json"; then
    return 0
  fi

  local rice_name rice_cmd
  rice_name=$(jq -r '.name // "Unnamed Rice"' <<<"$entry_json")
  rice_cmd=$(jq -r '.install_cmd // ""' <<<"$entry_json")

  if ! confirm "Install rice '$rice_name'?(no backup in this app, but 90% later in script)"; then
    echo "󰜺 Installation cancelled"
    read -p "Press Enter to continue..."
    return 0
  fi

  echo "󰏘 Running install command"
  if run_rice_install_command "$rice_cmd"; then
    echo "✅ Rice '$rice_name' installed"
  else
    echo "❌ Install command failed ($?)"
  fi

  read -p "Press Enter to return to menu..."
}
