{ config, pkgs, lib, nix-path, nix-path-alt, mypkgs, ... }:

let

  cfg = config.my.bspwm;

  bsp-plank-reset = pkgs.writeShellScriptBin "bsp-plank-reset" ''
    pkill plank
    plank &
  '';

  bsp-help = pkgs.writeShellScriptBin "bsp-help" ''
    # Extract keybindings and descriptions and format into fixed-width columns
    keybindings=$(awk '
        /^[a-z]/ && last {
            # Use printf for consistent column widths and padding
            printf "%-30s | %-40s\n", $0, last
        }
        { last="" }
        /^#/ { last=substr($0, 3) }' ${nix-path-alt}/modules/hm/desktops/bspwm/sxhkdrc)

    # Pad the content with a fixed-width column approach
    formatted_keybindings=$(echo "$keybindings" | column -t -s '|')

    # Show in rofi and capture the selected line
    selected=$(echo "$formatted_keybindings" | rofi -dmenu -i -p "Keybindings" -line-padding 4 -hide-scrollbar -theme ${nix-path}/modules/hm/desktops/bspwm/keybinds.rasi)

    # Execute the selected keybinding's command (if needed)
    if [ -n "$selected" ]; then
        command=$(echo "$selected" | awk -F'|' '{print $1}' | xargs)
        nohup $command &>/dev/null &
    fi
  '';

  volume= "$(pamixer --get-volume)";
  bsp-volume = pkgs.writeShellScriptBin "bsp-volume" ''
      #!/bin/bash

      function send_notification() {
      	volume=$(pamixer --get-volume)
      	dunstify -a "changevolume" -u low -r "9993" -h int:value:"$volume" -i "volume-$1" "Volume: ${volume}%" -t 2000
      }

      case $1 in
      up)
      	# Set the volume on (if it was muted)
      	pamixer -u
      	pamixer -i 2 --allow-boost
      	send_notification $1
      	;;
      down)
      	pamixer -u
      	pamixer -d 2 --allow-boost
      	send_notification $1
      	;;
      mute)
      	pamixer -t
      	if $(pamixer --get-mute); then
      		dunstify -i volume-mute -a "changevolume" -t 2000 -r 9993 -u low "Muted"
      	else
      		send_notification up
      	fi
      	;;
      esac

  '';

  bsp-layout-manager = pkgs.writeShellScriptBin "bsp-layout-manager" ''
    # Check if there is a floating window on the current focused desktop
    if bspc query -N -n .floating.local > /dev/null; then
        echo '󱗆'
        exit 0
    fi

    current=$(bsp-layout get 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo ""
        exit 0
    fi

    case "$current" in
        tiled)   echo '' ;;
        monocle) echo '󱂬' ;;
        even)    echo '' ;;
        grid)    echo '󱗼' ;;
        rgrid)   echo '󰋁' ;;
        rtall)   echo '󱇜' ;;
        rwide)   echo '' ;;
        tall)    echo '' ;;
        wide)    echo '' ;;
        *)       echo ''
             exit 1 ;;
    esac
  '';

  bsp-xkb-layout = pkgs.writeShellScriptBin "bsp-xkb-layout" ''
    xkblayout-state print "%s"
  '';

  # bspc query -N -n .window | xargs -I {} bspc node {} -t floating
  # bspc query -N -n .window | xargs -I {} bspc node {} -t tiled
  bsp-float = pkgs.writeShellScriptBin "bsp-float" ''
    bspc query -N -d focused | while read -r n; do s=$(bspc query -T -n "$n" | grep -q '"state":"floating"' && echo tiled || echo floating); bspc node "$n" -t "$s"; done
  '';

  bsp-power = pkgs.writeShellScriptBin "bsp-power" ''
    ROFI_THEME="${nix-path}/modules/hm/desktops/awesome/awesome/rofi/power.rasi"

    chosen=$(echo -e "[Cancel]\n󰑓 Reload BSPWM❤️\n Lock\n󰍃 Logout\n󰒲 Sleep\n󰤆 Shutdown\n󱄋 Reboot\n󰆓 Save Session\n󰆔 Restore Session" | \
        rofi -dmenu -i -p "Power Menu" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

    case "$chosen" in
        " Lock") ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a -p default  ;;
        "󰑓 Reload BSPWM❤️") poly-reset  ;;
        "󰍃 Logout")
          bspc quit
          pkill dwm
          pkill dwm
          openbox --exit
          i3-msg exit  ;;
        "󰒲 Sleep") systemctl suspend  ;;
        "󰤆 Shutdown") systemctl poweroff ;;
        "󱄋 Reboot") systemctl reboot ;;
        "󰆓 Save Session") yes | xsession-manager -s bspwm ;;
        "󰆔 Restore Session") yes | xsession-manager -pr bspwm ;;
        *) exit 0 ;; # Exit on cancel or invalid input
    esac
  '';

  bsp-bar-hide = pkgs.writeShellScriptBin "bsp-bar-hide" ''
    TOP_HEIGHT=${config.my.poly-height}
    BOTTOM_HEIGHT=15
    BAR_NAME="${config.my.poly-name}"

    if pgrep polybar > /dev/null; then
        pkill polybar
        pkill tint2
        #pkill plank
        pkill dockx
        #pkill conky
        bspc config top_padding 0
        bspc config bottom_padding 0
    else
        bspc config top_padding $TOP_HEIGHT
        bspc config top_padding $BOTTOM_HEIGHT
        polybar $BAR_NAME &
        tint2 -c ${nix-path}/modules/hm/bar-shell/tint2/dock/liness/tint.tint2rc &
        #conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
        #plank &
        #dockx &
    fi
  '';

  bsp-tint2-hide = pkgs.writeShellScriptBin "bsp-tint2-hide" ''
    if pgrep -x .tint2-wrapped  >/dev/null; then
        pkill .tint2-wrapped
        bspc config bottom_padding 0
    else
        bspc config bottom_padding 15
        tint2 -c ${nix-path}/modules/hm/bar-shell/tint2/dock/liness/tint.tint2rc &
    fi
  '';

  bsp-poly-hide = pkgs.writeShellScriptBin "bsp-poly-hide" ''
    TOP_HEIGHT=${config.my.poly-height}
    BAR_NAME="${config.my.poly-name}"

    if pgrep polybar > /dev/null; then
        pkill polybar
        bspc config top_padding 0
    else
        bspc config top_padding $TOP_HEIGHT
        polybar $BAR_NAME &
    fi
  '';

  bsp-dock-hide = pkgs.writeShellScriptBin "bsp-dock-hide" ''
    if pgrep dockx > /dev/null; then
        pkill dockx
    else
        dockx &
    fi
  '';

  scratchpad = pkgs.writeShellScriptBin "scratchpad" ''
    ${builtins.readFile ./scratchpad}
  '';

  bspad = pkgs.writeShellScriptBin "bspad" ''
    ${builtins.readFile ./bspad}
  '';

  bsp-gaps = pkgs.writeShellScriptBin "bsp-gaps" ''
    case "$1" in
        +|-) op="$1";;
        *) echo "Usage: $0 [+|-]"; exit 1;;
    esac

    # Read current values
    lp=$(bspc config left_padding)
    rp=$(bspc config right_padding)
    wg=$(bspc config window_gap)

    # Increment/decrement helper
    adj() { [ "$op" = "+" ] && echo $(( $1 + 1 )) || echo $(( $1 - 1 )); }

    # Apply new values
    bspc config left_padding  $(adj $lp)
    bspc config right_padding $(adj $rp)
    bspc config window_gap   $(adj $wg)
  '';

  bsp-tag-view = pkgs.writeShellScriptBin "bsp-tag-view" ''
    # Accepts any number of desktops: ./toggle-multiple-desktops.sh 1 2 3 ...
    CACHE="$HOME/.bspwm_desktops_cache"

    if [ -f "$CACHE" ]; then
        echo "Already toggled. Use restore script."
        exit 0
    fi

    if [ $# -lt 1 ]; then
        echo "Usage: $0 <desktop1> [desktop2 ...]"
        exit 1
    fi

    > "$CACHE"

    for desk in "$@"; do
        for wid in $(bspc query -N -d "$desk"); do
            echo "$wid $desk" >> "$CACHE"
            bspc node "$wid" --flag sticky 1
        done
    done
  '';

  bsp-tag-view-revert = pkgs.writeShellScriptBin "bsp-tag-view-revert" ''
    CACHE="$HOME/.bspwm_desktops_cache"

    if [ ! -f "$CACHE" ]; then
        echo "No cached toggle found."
        exit 0
    fi

    while read wid desk; do
        bspc node "$wid" --flag sticky 0
        bspc node "$wid" --to-desktop "$desk"
    done < "$CACHE"

    rm "$CACHE"
  '';

  bsp-tag-view-rofi = pkgs.writeShellScriptBin "bsp-tag-view-rofi" ''
    # Get list of current desktops
    DESKTOPS=$(bspc query -D --names)

    # Prompt with Rofi, no window below, single line input
    CHOICE=$(echo "$DESKTOPS" | rofi -dmenu -p "Desktops to toggle (space-separated):" -lines 0 -no-custom)

    # If user entered something, call the toggle script
    if [ -n "$CHOICE" ]; then
        bsp-tag-view $CHOICE
    fi
  '';

  bsp-cache-layout = pkgs.writeShellScriptBin "bsp-cache-layout" ''
    DESKTOP=$(bspc query -D -d focused)
    CACHE_FILE="$HOME/.cache/bsp-layout-$DESKTOP.json"

    # Only cache if not exists
    [ -f "$CACHE_FILE" ] && exit

    # Save full desktop tree (including split ratios and window order)
    bspc query -T -d "$DESKTOP" > "$CACHE_FILE"
  '';

  bsp-restore-cached-layout = pkgs.writeShellScriptBin "bsp-restore-cached-layout" ''
    # Restore a cached desktop tree exactly, while keeping new windows intact

    DESKTOP=$(bspc query -D -d focused)
    CACHE_FILE="$HOME/.cache/bsp-layout-$DESKTOP.json"

    [ ! -f "$CACHE_FILE" ] && exit

    # Read cached JSON
    TREE_JSON=$(cat "$CACHE_FILE")

    # Get IDs of windows in cache
    CACHED_WINDOWS=$(jq -r '.. | .id? // empty' <<< "$TREE_JSON")

    # Get current windows
    CURRENT_WINDOWS=$(bspc query -N -d "$DESKTOP")

    # Identify new windows spawned after cache
    NEW_WINDOWS=$(comm -23 <(echo "$CURRENT_WINDOWS" | sort) <(echo "$CACHED_WINDOWS" | sort))

    # Remove new windows temporarily to restore layout
    for win in $NEW_WINDOWS; do
        bspc node "$win" -d hidden
    done

    # Restore layout
    # Using bspc node to rebuild the tree recursively
    restore_node() {
        local node_json=$1
        local parent=$2

        local id=$(jq -r '.id' <<< "$node_json")
        local split=$(jq -r '.split // empty' <<< "$node_json")
        local ratio=$(jq -r '.splitRatio // empty' <<< "$node_json")
        local state=$(jq -r '.state // empty' <<< "$node_json")

        # Skip if it's a desktop node
        [ "$split" == "null" ] && return

        # Set split ratio
        [ -n "$ratio" ] && bspc node "$id" -s "$ratio" 2>/dev/null

        # Set state (tiled/floating)
        if [ "$state" == "floating" ]; then
            bspc node "$id" -t floating 2>/dev/null
        else
            bspc node "$id" -t tiled 2>/dev/null
        fi

        # Recurse into children
        local children=$(jq -c '.nodes[]' <<< "$node_json")
        for child in $children; do
            restore_node "$child" "$id"
        done
    }

    # Start restoring from root
    ROOT=$(jq '.root' <<< "$TREE_JSON")
    restore_node "$ROOT" "$DESKTOP"

    # Unhide new windows so they appear, without affecting restored layout
    for win in $NEW_WINDOWS; do
        bspc node "$win" -d "$DESKTOP"
    done

    # Remove cache after restoration
    rm "$CACHE_FILE"
  '';

  bsp-cmaster-oneshot = pkgs.writeShellScriptBin "bsp-cmaster-oneshot" ''
    ${builtins.readFile ./layouts/cmaster-oneshot}
  '';

  #${builtins.readFile ./layouts/cmaster}
  bsp-cmaster-layout = pkgs.writeShellScriptBin "bsp-cmaster-layout" ''
    DESKTOP=$(bspc query -D -d focused)
    LOCKFILE="$HOME/.cache/bspwm-cmaster-$DESKTOP.lock"

    # Prevent multiple instances
    if [[ -f "$LOCKFILE" ]] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
        exit 0
    fi

    # Record current PID in lock file
    echo $$ > "$LOCKFILE"

    # Ensure lock file is removed when script exits
    trap 'rm -f "$LOCKFILE"' EXIT


    PID_FILE_LISTEN="$HOME/.cache/bspwm-cmaster-$DESKTOP.pid"

    kill $(cat "$PID_FILE_LISTEN") 2>/dev/null
    rm -f "$PID_FILE_LISTEN"

    bsp-cmaster-oneshot

    {
      while read -r line; do
          read -r event monitor desktop node action <<< "$line"
          if [[ "$desktop" == "$DESKTOP" ]]; then
              bsp-cmaster-layout
          fi
      done
    } < <(bspc subscribe node_add node_remove) &
    echo $! > "$PID_FILE_LISTEN"
  '';

  bsp-cmaster = pkgs.writeShellScriptBin "bsp-cmaster" ''
    DESKTOP=$(bspc query -D -d focused)
    PID_FILE_LISTEN="$HOME/.cache/bspwm-cmaster-$DESKTOP.pid"
    kill $(cat "$PID_FILE_LISTEN")
    rm -f "$PID_FILE_LISTEN"

    bsp-cmaster-layout

    {
        while read -r line; do
            read -r event monitor desktop node action <<< "$line"
            if [[ "$desktop" == "$DESKTOP" ]]; then
                bsp-cmaster-layout
            fi
        done
    } < <(bspc subscribe node_add node_remove) &
    echo $! > "$PID_FILE_LISTEN"
  '';

  bsp-cmaster-remove = pkgs.writeShellScriptBin "bsp-cmaster-remove" ''
    DESKTOP=$(bspc query -D -d focused)
    PID_FILE_LISTEN="$HOME/.cache/bspwm-cmaster-$DESKTOP.pid"
    kill $(cat "$PID_FILE_LISTEN")
    rm -f "$PID_FILE_LISTEN"
  '';

  bsp-ctall-layout = pkgs.writeShellScriptBin "bsp-ctall-layout" ''
    ${builtins.readFile ./layouts/ctall.sh}
  '';

  bsp-tv-layout = pkgs.writeShellScriptBin "bsp-tv-layout" ''
    DESKTOP=$(bspc query -D -d focused)

    LOCKFILE="$HOME/.cache/bspwm-cmaster-$DESKTOP.lock"

    # Prevent multiple instances
    if [[ -f "$LOCKFILE" ]] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
        exit 0
    fi

    # Record current PID in lock file
    echo $$ > "$LOCKFILE"

    # Ensure lock file is removed when script exits
    trap 'rm -f "$LOCKFILE"' EXIT



    PID_FILE_LISTEN="$HOME/.cache/bspwm-cmaster-$DESKTOP.pid"

    kill $(cat "$PID_FILE_LISTEN") 2>/dev/null
    rm -f "$PID_FILE_LISTEN"

    bsp-cmaster-oneshot &&
    bspc node "$(bspc query -N -n focused)" -s "$(bspc query -N -n biggest.local)"
    #sleep 0.5
    bspc node @parent -R -90

    {
      while read -r line; do
          read -r event monitor desktop node action <<< "$line"
          if [[ "$desktop" == "$DESKTOP" ]]; then
              bsp-tv-layout
          fi
      done
    } < <(bspc subscribe node_add node_remove) &
    echo $! > "$PID_FILE_LISTEN"
  '';

  bsp-rtv-layout = pkgs.writeShellScriptBin "bsp-rtv-layout" ''
    DESKTOP=$(bspc query -D -d focused)

    LOCKFILE="$HOME/.cache/bspwm-cmaster-$DESKTOP.lock"

    # Prevent multiple instances
    if [[ -f "$LOCKFILE" ]] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
        exit 0
    fi

    # Record current PID in lock file
    echo $$ > "$LOCKFILE"

    # Ensure lock file is removed when script exits
    trap 'rm -f "$LOCKFILE"' EXIT



    PID_FILE_LISTEN="$HOME/.cache/bspwm-cmaster-$DESKTOP.pid"

    kill $(cat "$PID_FILE_LISTEN") 2>/dev/null
    rm -f "$PID_FILE_LISTEN"

    bsp-cmaster-oneshot &&
    bspc node "$(bspc query -N -n focused)" -s "$(bspc query -N -n biggest.local)"
    #sleep 0.5
    bspc node @parent -R 90

    {
      while read -r line; do
          read -r event monitor desktop node action <<< "$line"
          if [[ "$desktop" == "$DESKTOP" ]]; then
              bsp-rtv-layout
          fi
      done
    } < <(bspc subscribe node_add node_remove) &
    echo $! > "$PID_FILE_LISTEN"
  '';

  bsp-vertical-layout-oneshot = pkgs.writeShellScriptBin "bsp-vertical-layout-oneshot" ''
    ${builtins.readFile ./layouts/vetrical-columns-oneshot}
  '';

  bsp-horizontal-layout-oneshot = pkgs.writeShellScriptBin "bsp-horizontal-layout-oneshot" ''
    ${builtins.readFile ./layouts/horizontal-columns-oneshot}
  '';

  bsp-culomns-rows-layout-oneshot = pkgs.writeShellScriptBin "bsp-culomns-rows-layout-oneshot" ''
    CACHE_FILE="$HOME/.cache/bsp-columns-rows-oneshot"
    if [[ -f "$CACHE_FILE" ]]; then
        bsp-horizontal-layout-oneshot
        rm "$CACHE_FILE"
        notify-send "Horizontal Rows Layout (OneShot)"
    else
        bsp-vertical-layout-oneshot
        touch "$CACHE_FILE"
        notify-send "Vertical Columns Layout (OneShot)"
    fi
  '';

  bsp-vertical-layout = pkgs.writeShellScriptBin "bsp-vertical-layout" ''
    ${builtins.readFile ./layouts/vetrical-columns}
  '';

  bsp-horizontal-layout = pkgs.writeShellScriptBin "bsp-horizontal-layout" ''
    ${builtins.readFile ./layouts/horizontal-columns}
  '';

  bsp-culomns = pkgs.writeShellScriptBin "bsp-culomns" ''
    DESKTOP=$(bspc query -D -d focused)
    PID_FILE="$HOME/.cache/bspwm-row-column-layout-$DESKTOP.pid"

    # Kill existing monitor for THIS desktop
    if [[ -f "$PID_FILE" ]]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi

    # Apply horizontal layout
    bsp-vertical-layout

    # Start monitoring and save PID
    {
        while read -r line; do
            read -r event monitor desktop node action <<< "$line"
            if [[ "$desktop" == "$DESKTOP" ]]; then
                bsp-vertical-layout
            fi
        done
    } < <(bspc subscribe node_add node_remove) &
    echo $! > "$PID_FILE"
  '';

  bsp-rows = pkgs.writeShellScriptBin "bsp-rows" ''
    DESKTOP=$(bspc query -D -d focused)
    PID_FILE="$HOME/.cache/bspwm-row-column-layout-$DESKTOP.pid"

    # Kill existing monitor for THIS desktop
    if [[ -f "$PID_FILE" ]]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi

    # Apply horizontal layout
    bsp-horizontal-layout

    # Start monitoring and save PID
    {
        while read -r line; do
            read -r event monitor desktop node action <<< "$line"
            if [[ "$desktop" == "$DESKTOP" ]]; then
                bsp-horizontal-layout
            fi
        done
    } < <(bspc subscribe node_add node_remove) &
    echo $! > "$PID_FILE"
  '';

  bsp-culomns-rows-layout-remove = pkgs.writeShellScriptBin "bsp-culomns-rows-layout-remove" ''
    DESKTOP=$(bspc query -D -d focused)
    PID_FILE="$HOME/.cache/bspwm-row-column-layout-$DESKTOP.pid"

    # Kill existing monitor for THIS desktop
    if [[ -f "$PID_FILE" ]]; then
        kill $(cat "$PID_FILE") 2>/dev/null
        rm -f "$PID_FILE"
    fi
  '';

  bsp-zoom = pkgs.writeShellScriptBin "bsp-zoom" ''
    DESKTOP=$(bspc query -D -d focused --names)
    CACHE_FILE="$HOME/.cache/bspwm_zoom_last_$DESKTOP"

    focused=$(bspc query -N -n focused)
    biggest=$(bspc query -N -n biggest.local)

    # If focused is NOT biggest → swap & remember previous master
    if [ "$focused" != "$biggest" ]; then
        # Save current biggest (master) to cache
        echo "$biggest" > "$CACHE_FILE"
        bspc node "$focused" -s "$biggest"
        exit 0
    fi

    # Focused IS biggest:
    # If no cache, nothing to do
    [ ! -f "$CACHE_FILE" ] && exit 0

    # Otherwise swap back with cached node
    original=$(cat "$CACHE_FILE")

    # Only swap if the node still exists
    if bspc query -N -n "$original" >/dev/null 2>&1; then
        bspc node "$focused" -s "$original"
    fi

    # Remove cache
    rm -f "$CACHE_FILE"
  '';

  bsp-zoom-second_biggest = pkgs.writeShellScriptBin "bsp-zoom-second_biggest" ''
    DESKTOP=$(bspc query -D -d focused --names)
    CACHE_FILE="$HOME/.cache/bspwm_zoom_second_$DESKTOP"

    focused=$(bspc query -N -n focused)

    # Get ONLY tiled windows on this desktop
    nodes=$(bspc query -N -n .local.tiled)

    # If fewer than 2 tiled windows → nothing to do
    [ "$(printf "%s\n" $nodes | wc -l)" -lt 2 ] && exit 0

    # Build list: area node_id
    areas=$(for n in $nodes; do
        rect=$(bspc query -T -n "$n" | jq '.rectangle')
        width=$(echo "$rect" | jq '.width')
        height=$(echo "$rect" | jq '.height')
        area=$((width * height))
        echo "$area $n"
    done)

    # Sort largest → smallest
    sorted=$(echo "$areas" | sort -nr -k1,1)

    # Biggest and 2nd biggest
    biggest=$(echo "$sorted" | sed -n '1p' | awk '{print $2}')
    second_biggest=$(echo "$sorted" | sed -n '2p' | awk '{print $2}')

    # SWAP LOGIC
    # If focused is NOT 2nd biggest → swap to 2nd-biggest
    if [ "$focused" != "$second_biggest" ]; then
        echo "$second_biggest" > "$CACHE_FILE"
        bspc node "$focused" -s "$second_biggest"
        exit 0
    fi

    # Focused IS 2nd-biggest → restore
    [ ! -f "$CACHE_FILE" ] && exit 0
    original=$(cat "$CACHE_FILE")

    # Restore only if still valid
    if bspc query -N -n "$original" >/dev/null 2>&1; then
        bspc node "$focused" -s "$original"
    fi

    rm -f "$CACHE_FILE"
  '';

  bsp-send-follow = pkgs.writeShellScriptBin "bsp-send-follow" ''
    DEST=^$1  # e.g., 1-10

    # move the focused node
    NODE=$(bspc query -N -n focused)
    bspc node "$NODE" --to-desktop "$DEST"

    # get the monitor of that desktop
    MONITOR=$(bspc query -M -d "$DEST")

    # focus the monitor and desktop
    bspc monitor "$MONITOR" --focus
    bspc desktop "$DEST" --focus

    # focus the node itself
    bspc node "$NODE" --focus
  '';

  bsp-gaps-toggle = pkgs.writeShellScriptBin "bsp-gaps-toggle" ''
    # Get current window gap
    gap=$(bspc config window_gap)

    if [ "$gap" -eq 0 ]; then
        # Restore default gap (adjust to your preference)
        bspc config window_gap 10
    else
        # Turn off gaps
        bspc config left_padding 0
        bspc config right_padding 0
        bspc config window_gap 0
    fi
  '';

  bsp-border-toggle = pkgs.writeShellScriptBin "bsp-border-toggle" ''
    # Temp file to store previous border width
    TMPFILE="/tmp/.bspwm_border_width"

    # Get current border width
    current=$(bspc config border_width)

    if [ "$current" -eq 0 ]; then
        # If border is off, restore previous width
        if [ -f "$TMPFILE" ]; then
            prev=$(cat "$TMPFILE")
            bspc config border_width "$prev"
        else
            # fallback default if no previous value
            bspc config border_width 2
        fi
    else
        # Save current border width and turn borders off
        echo "$current" > "$TMPFILE"
        bspc config border_width 0
    fi
  '';

  bsp-border-size = pkgs.writeShellScriptBin "bsp-border-size" ''
    # Argument: "inc" or "dec"
    action=$1

    # Default border width if currently zero
    DEFAULT_BORDER=2
    STEP=1  # change per press

    # Get current border width
    current=$(bspc config border_width)

    # If empty or 0, start from default
    if ! [[ "$current" =~ ^[0-9]+$ ]] || [ "$current" -eq 0 ]; then
        current=$DEFAULT_BORDER
    fi

    # Increment or decrement
    if [ "$action" == "inc" ]; then
        new=$((current + STEP))
    elif [ "$action" == "dec" ]; then
        new=$((current - STEP))
        if [ "$new" -lt 0 ]; then new=0; fi
    else
        echo "Usage: $0 inc|dec"
        exit 1
    fi

    # Apply new border width
    bspc config border_width "$new"
  '';

  bsp-border-color = pkgs.writeShellScriptBin "bsp-border-color" ''
    ${builtins.readFile ./themes/${config.my.theme}-borders}
  '';

  bsp-empty-remove = pkgs.writeShellScriptBin "bsp-empty-remove" ''
    for win in $(bspc query -N -n .leaf.\!window); do bspc node $win -k; done
  '';

  bspswallow = pkgs.writeShellScriptBin "bspswallow" ''
    ${builtins.readFile ./bspswallow}
  '';

  bspwmswallow = pkgs.writeShellScriptBin "bspwmswallow" ''
    ${builtins.readFile ./bspwmswallow}
  '';

  pidswallow = pkgs.writeShellScriptBin "pidswallow" ''
    ${builtins.readFile ./pidswallow}
  '';

  bsp-touchegg = pkgs.writeShellScriptBin "bsp-touchegg" ''
    rm -f $HOME/.config/touchegg/touchegg.conf
    cp ${nix-path}/modules/hm/desktops/bspwm/touchegg.conf $HOME/.config/touchegg/touchegg.conf
    #systemctl --user stop touchegg-bsp.service
    #systemctl --user start touchegg-bsp.service
  '';

  bsp-unhide-last-hidden = pkgs.writeShellScriptBin "bsp-unhide-last-hidden" ''
    n=$(bspc query -N -n .hidden.local | head -n 1); [ -n "$n" ] && bspc node "$n" -g hidden=off
  '';

  bsp-conky = pkgs.writeShellScriptBin "bsp-conky" ''
    if pgrep -x conky >/dev/null; then
        pkill conky &
    else
        conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
    fi
  '';

  bsp-desktop-switch = pkgs.writeShellScriptBin "bsp-desktop-switch" ''
    target="$1"
    current="$(bspc query -D -d focused --names)"

    # Create a temporary desktop on the current monitor
    temp="swap_buffer"
    bspc monitor -a "$temp"

    # Capture nodes before moving anything
    current_nodes=$(bspc query -N -d "$current")
    target_nodes=$(bspc query -N -d "$target")

    # Move current → temp
    for n in $current_nodes; do
        bspc node "$n" --to-desktop "$temp"
    done

    # Move target → current
    for n in $target_nodes; do
        bspc node "$n" --to-desktop "$current"
    done

    # Move temp → target
    temp_nodes=$(bspc query -N -d "$temp")
    for n in $temp_nodes; do
        bspc node "$n" --to-desktop "$target"
    done

    # Remove temporary desktop
    bspc desktop "$temp" --remove
  '';

  bsp-desktop-switch-follow = pkgs.writeShellScriptBin "bsp-desktop-switch-follow" ''
    target="$1"
    current="$(bspc query -D -d focused --names)"

    # Create a temporary desktop on the current monitor
    temp="swap_buffer"
    bspc monitor -a "$temp"

    # Capture nodes before moving anything
    current_nodes=$(bspc query -N -d "$current")
    target_nodes=$(bspc query -N -d "$target")

    # Move current → temp
    for n in $current_nodes; do
        bspc node "$n" --to-desktop "$temp"
    done

    # Move target → current
    for n in $target_nodes; do
        bspc node "$n" --to-desktop "$current"
    done

    # Move temp → target
    temp_nodes=$(bspc query -N -d "$temp")
    for n in $temp_nodes; do
        bspc node "$n" --to-desktop "$target"
    done

    # Remove temporary desktop
    bspc desktop "$temp" --remove

    # Follow: switch focus to the target desktop
    bspc desktop -f "$target"
  '';

  bsp-manual-window-swap = pkgs.writeShellScriptBin "bsp-manual-window-swap" ''
    CACHE="$HOME/.cache/bspwm_manual_window_swap"
    TIMEOUT=60  # seconds

    # If cache exists, check age
    if [ -f "$CACHE" ]; then
        NOW=$(date +%s)
        MOD=$(stat -c %Y "$CACHE")
        # If cache is older than timeout delete it
        if [ $((NOW - MOD)) -ge $TIMEOUT ]; then
            rm -f "$CACHE"
        fi
    fi

    # If no cache file now: store focused window ID
    if [ ! -f "$CACHE" ]; then
        bspc query -N -n focused > "$CACHE"
        exit 0
    fi

    # Cache exists and is fresh perform swap
    CACHED_WIN=$(cat "$CACHE")
    CURRENT_WIN=$(bspc query -N -n focused)

    if [ -n "$CACHED_WIN" ] && [ -n "$CURRENT_WIN" ]; then
        bspc node "$CACHED_WIN" -s "$CURRENT_WIN"
    fi

    rm -f "$CACHE"
  '';

  bsp-manual-window-send = pkgs.writeShellScriptBin "bsp-manual-window-send" ''
    CACHE="$HOME/.cache/bspwm_swap"
    TIMEOUT=60  # seconds

    # If cache exists, check age
    if [ -f "$CACHE" ]; then
        NOW=$(date +%s)
        MOD=$(stat -c %Y "$CACHE")

        # If cache is older than timeout delete it
        if [ $((NOW - MOD)) -ge $TIMEOUT ]; then
            rm -f "$CACHE"
        fi
    fi

    # If no cache file now: store focused window ID
    if [ ! -f "$CACHE" ]; then
        bspc query -N -n focused > "$CACHE"
        exit 0
    fi

    # Cache exists and is fresh send cached window to current desktop
    CACHED_WIN=$(cat "$CACHE")
    CURRENT_DESKTOP=$(bspc query -D -d focused)

    if [ -n "$CACHED_WIN" ] && [ -n "$CURRENT_DESKTOP" ]; then
        bspc node "$CACHED_WIN" -d "$CURRENT_DESKTOP"
    fi

    rm -f "$CACHE"
  '';

  bsp-master-node-increase = pkgs.writeShellScriptBin "bsp-master-node-increase" ''
    # Get current layout
    current=$(bsp-layout-ext get)

    case "$current" in
        tall)
            bsp-layout-ext set tall2
            ;;
        tall2)
            bsp-layout-ext set tall3
            ;;
        tall3)
            bsp-layout-ext set tall4
            ;;
        rtall)
            bsp-layout-ext set rtall2
            ;;
        rtall2)
            bsp-layout-ext set rtall3
            ;;
        rtall3)
            bsp-layout-ext set rtall4
            ;;
        wide)
            bsp-layout-ext set wide2
            ;;
        wide2)
            bsp-layout-ext set wide3
            ;;
        wide3)
            bsp-layout-ext set wide4
            ;;
        rwide)
            bsp-layout-ext set rwide2
            ;;
        rwide2)
            bsp-layout-ext set rwide3
            ;;
        rwide3)
            bsp-layout-ext set rwide4
            ;;
        *)
            echo "Unknown layout: $current"
            ;;
    esac
  '';

  bsp-master-node-decrease = pkgs.writeShellScriptBin "bsp-master-node-decrease" ''
    # Get current layout
    current=$(bsp-layout-ext get)

    case "$current" in
        tall4)
            bsp-layout-ext set tall3
            ;;
        tall3)
            bsp-layout-ext set tall2
            ;;
        tall2)
            bsp-layout set tall
            ;;
        rtall4)
            bsp-layout-ext set rtall3
            ;;
        rtall3)
            bsp-layout-ext set rtall2
            ;;
        rtall2)
            bsp-layout set rtall
            ;;
        wide4)
            bsp-layout-ext set wide3
            ;;
        wide3)
            bsp-layout-ext set wide2
            ;;
        wide2)
            bsp-layout set wide
            ;;
        rwide4)
            bsp-layout-ext set rwide3
            ;;
        rwide3)
            bsp-layout-ext set rwide2
            ;;
        rwide2)
            bsp-layout set rwide
            ;;
        *)
            echo "Unknown layout: $current"
            ;;
    esac
  '';

  bsp-manual-order-save = pkgs.writeShellScriptBin "bsp-manual-order-save" ''

    DESKTOP=$(bspc query -D -d focused)
    rm -f "$HOME/.cache/bspwm-order-$DESKTOP"
    bspc query -N -n ".leaf.!hidden.!floating" -d > "$HOME/.cache/bspwm-order-$DESKTOP"

  '';

  bsp-manual-order-load = pkgs.writeShellScriptBin "bsp-manual-order-load" ''
    ${builtins.readFile ./bsp-manual-order-load}
  '';

  bsp-manual-order-remove = pkgs.writeShellScriptBin "bsp-manual-order-remove" ''

    DESKTOP=$(bspc query -D -d focused)
    rm -f "$HOME/.cache/bspwm-order-$DESKTOP"

  '';

in

{

  config = lib.mkIf cfg.enable {

    home.packages = [

      bsp-plank-reset
      bsp-help
      bsp-volume
      bsp-layout-manager
      bsp-xkb-layout
      bsp-float
      bsp-power
      bsp-bar-hide
      bsp-tint2-hide
      bsp-poly-hide
      bsp-dock-hide
      bsp-gaps
      bsp-tag-view
      bsp-tag-view-revert
      bsp-tag-view-rofi
      bsp-restore-cached-layout
      bsp-cache-layout
      bsp-zoom
      bsp-zoom-second_biggest
      bsp-cmaster-layout
      bsp-cmaster
      bsp-cmaster-oneshot
      bsp-cmaster-remove
      bsp-ctall-layout
      bsp-rtv-layout
      bsp-tv-layout
      bsp-send-follow
      bsp-border-color
      bsp-border-size
      bsp-border-toggle
      bsp-gaps-toggle
      bsp-empty-remove
      bsp-touchegg
      bsp-unhide-last-hidden
      bsp-conky
      bsp-desktop-switch
      bsp-desktop-switch-follow
      bsp-vertical-layout-oneshot
      bsp-horizontal-layout-oneshot
      bsp-culomns-rows-layout-oneshot
      bsp-vertical-layout
      bsp-horizontal-layout
      bsp-culomns
      bsp-rows
      bsp-culomns-rows-layout-remove
      bsp-manual-window-swap
      bsp-manual-window-send
      bsp-master-node-increase
      bsp-master-node-decrease
      bsp-manual-order-load
      bsp-manual-order-save
      bsp-manual-order-remove
      bspswallow
      bspwmswallow
      pidswallow
      bspad
      scratchpad

    ];

    xdg.configFile = {

      noswallow = {
        target = "bspwm/noswallow";
        text = ''
          kitty
          Alacritty
        '';
      };

      terminals = {
        target = "bspwm/terminals";
        #${config.my.default.terminal}
        text = ''
          Kitty
          Alacritty
        '';
      };

    };


};}
