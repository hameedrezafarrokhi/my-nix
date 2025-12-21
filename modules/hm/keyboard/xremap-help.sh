#!/usr/bin/env bash

XREMAP_FILE="$HOME/.config/xremap/xremap.yaml"

declare -a stack
declare -a indent_stack
group=""
output=()

while IFS= read -r rawline; do
    # Skip empty lines
    [[ -z "$rawline" ]] && continue

    # Count leading spaces
    line="${rawline#"${rawline%%[![:space:]]*}"}"
    indent=$(( ${#rawline} - ${#line} ))

    # Group name
    if [[ "$line" =~ ^-?[[:space:]]*name:[[:space:]]*(.*) ]]; then
        group="${BASH_REMATCH[1]}"
        stack=()
        indent_stack=()
        continue
    fi

    # Skip literal remap lines
    if [[ "$line" =~ ^remap: ]]; then
        continue
    fi

    # Key line (ends with colon)
    if [[ "$line" =~ ^([A-Za-z0-9_\-]+):$ ]]; then
        key="${BASH_REMATCH[1]}"
        # Remove stack entries with indent >= current
        while [[ ${#indent_stack[@]} -gt 0 && ${indent_stack[-1]} -ge $indent ]]; do
            unset 'stack[-1]'
            unset 'indent_stack[-1]'
        done
        stack+=("$key")
        indent_stack+=("$indent")
        continue
    fi

    # Launch line
    if [[ "$line" =~ launch:[[:space:]]*\[(.*)\] ]]; then
        cmds="${BASH_REMATCH[1]}"
        # Remove quotes and commas
        cmds="${cmds//\"/}"
        cmds="${cmds//,/ }"
        # Flatten keychain
        keychain="[$group] ${stack[*]// /-}"
        output+=("$keychain | $cmds")
        continue
    fi
done < "$XREMAP_FILE"

# Check output
if [[ ${#output[@]} -eq 0 ]]; then
    echo "No keybindings found in $XREMAP_FILE"
    exit 1
fi

# Show Rofi menu
selected=$(printf "%s\n" "${output[@]}" | column -t -s '|' \
            | rofi -dmenu -i -p "XRemap Keybindings" -line-padding 4 -hide-scrollbar -theme $HOME/.config/rofi/themes/keybinds.rasi)

# Execute selected command
if [[ -n "$selected" ]]; then
    cmd=$(echo "$selected" | awk -F'|' '{print $2}' | xargs)
    nohup $cmd &>/dev/null &
fi
