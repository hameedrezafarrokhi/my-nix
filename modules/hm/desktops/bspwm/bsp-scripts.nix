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
    selected=$(echo "$formatted_keybindings" | rofi -dmenu -i -p "Keybindings" -line-padding 4 -hide-scrollbar -theme $HOME/.config/rofi/themes/keybinds.rasi)

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
      	dunstify -a "changevolume" -u low -r "9993" -h int:value:"$volume" -i "volume-$1" "Volume: ${volume}%" -t 5000
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
      		dunstify -i volume-mute -a "changevolume" -t 5000 -r 9993 -u critical "Muted"
      	else
      		send_notification up
      	fi
      	;;
      esac

  '';

  bsp-layout-manager = pkgs.writeShellScriptBin "bsp-layout-manager" ''
    current=$(bsp-layout get 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo ""
        exit 0
    fi
    case "$current" in
        tiled)                            echo ''  ;;
        monocle)                          echo '󱂬'  ;;  #󰓠
        even)                             echo ''  ;;  #
        grid)                             echo '󱗼'  ;;
        rgrid)                            echo '-󱗼' ;;
        floating)                         echo '󱗆'  ;;
        col|col2|col3|col4|col5|col6)     echo '󱪷'  ;;
        row|row2|row3|row4|row5|row6)     echo '󱪶'  ;;
        fair)                             echo ''  ;;
        rfair)                            echo '-' ;;
        deck)                             echo ''  ;;
        dwindle)                          echo ''  ;;  #󱑺
        spiral)                           echo ''  ;;  #
        tall|tall2|tall3|tall4)           echo ''  ;;
        rtall|rtall2|rtall3|rtall4)       echo '-' ;;  #󰯌
        rwide|rwide2|rwide3|rwide4)       echo ''  ;;
        wide|wide2|wide3|wide4)           echo '-' ;;
        dmaster|dmaster2|dmaster3)        echo '󰬻' ;;
        rdmaster|rdmaster2|rdmaster3)     echo '󰬻' ;;
        cmaster|cmaster2|cmaster3)        echo ''  ;;
        rcmaster|rcmaster2|rcmaster3)     echo '-' ;;
        hdmaster|hdmaster2|hdmaster3)     echo '󰬻' ;;
        rhdmaster|rhdmaster2|rhdmaster3)  echo '󰬻' ;;
        tv-ne|tv-nw|tv-sw)                echo ''  ;;
        *) echo ''
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
    ROFI_THEME="$HOME/.config/rofi/themes/power.rasi"

    chosen=$(echo -e "[Cancel]\n󰑓 Reload BSPWM \n Lock\n󰍃 Logout\n󰒲 Sleep\n󰤆 Shutdown\n󱄋 Reboot\n󰁱 Polybar\n󰆓 Save Session\n󰆔 Restore Session" | \
        rofi -dmenu -i -p "Power Menu" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

    case "$chosen" in
        " Lock") ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a -p default  ;;
        "󰑓 Reload BSPWM ") poly-reset  ;;
        "󰍃 Logout")
          bspc quit
          pkill dwm
          pkill dwm
          openbox --exit
          i3-msg exit  ;;
        "󰒲 Sleep") systemctl suspend  ;;
        "󰤆 Shutdown") systemctl poweroff ;;
        "󱄋 Reboot") systemctl reboot ;;
        "󰁱 Polybar") bsp-poly-hide ;;
        "󰆓 Save Session") yes | xsession-manager -s bspwm ;;
        "󰆔 Restore Session") yes | xsession-manager -pr bspwm ;;
        *) exit 0 ;; # Exit on cancel or invalid input
    esac
  '';

 #bsp-bar-hide = pkgs.writeShellScriptBin "bsp-bar-hide" ''
 #  TOP_HEIGHT=${config.my.poly-height}
 #  BOTTOM_HEIGHT=15
 #  BAR_NAME="${config.my.poly-name}"
 #  gaps="$(bspc config right_padding)"
 #
 #  if pgrep polybar > /dev/null; then
 #      bsp-gaps-bar-cache
 #      #bsp-gaps-bar-cache
 #      pkill polybar
 #      #pkill tint2
 #      #pkill plank
 #      pkill dockx
 #      #pkill conky
 #      "$HOME/.bsp_gaps_bar_cache"
 #      node_state=$(bspc query -T -n $(bspc query -N -n) | grep -q '"state":"fullscreen"' && echo yes)
 #
 #      if [[ $gaps -eq 0 ]]; then
 #        bspc config top_padding 0
 #        if pgrep -x .tint2-wrapped  >/dev/null; then
 #            pkill tint2
 #        fi
 #        bspc config bottom_padding 0
 #      else
 #        if [ "$node_state" != "yes" ]; then
 #          bspc config top_padding $(bspc config bottom_padding)
 #        fi
 #
 #        if pgrep -x .tint2-wrapped  >/dev/null; then
 #            pkill tint2
 #       #    bspc config bottom_padding $(( $(bspc config bottom_padding) - $BOTTOM_HEIGHT ))
 #        fi
 #      fi
 #
 #  else
 #      "$HOME/.bsp_gaps_bar_cache"
 #      #bspc config top_padding $(( $(bspc config top_padding) + $TOP_HEIGHT ))
 #
 #      if pgrep -x .tint2-wrapped  >/dev/null; then
 #          echo ""
 #      else
 #          #bspc config bottom_padding $(( $(bspc config bottom_padding) + $BOTTOM_HEIGHT ))
 #          tint2 &
 #      fi
 #
 #      polybar-start &
 #      #$HOME/.polybar_modules
 #      #conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
 #      #plank &
 #      #dockx &
 #  fi
 #'';
  bsp-bar-hide = pkgs.writeShellScriptBin "bsp-bar-hide" ''

    if systemctl --user is-active --quiet bsppoly.service; then
      if [ -f "$HOME/.config/bspwm/poly-state" ]; then
        $HOME/.bsp_gaps_bar_cache
        polybar-msg cmd show
        rm -f "$HOME/.config/bspwm/poly-state"
        if [ -f "$HOME/.config/bspwm/tint-state" ]; then
          systemctl --user restart bsptint.service
          rm -f "$HOME/.config/bspwm/tint-state"
        fi
      else
        bsp-gaps-bar-cache
        bsp-poly-cache
        bspc config top_padding $(bspc config right_padding)
        polybar-msg cmd hide
        touch "$HOME/.config/bspwm/poly-state"
        if systemctl --user is-active --quiet bsptint.service; then
            bsp-tint-cache
            systemctl --user stop bsptint.service
            bspc config bottom_padding $(bspc config right_padding)
            touch "$HOME/.config/bspwm/tint-state"
        fi
      fi
    fi

  '';

 #bsp-tint2-hide = pkgs.writeShellScriptBin "bsp-tint2-hide" ''
 #  BOTTOM_HEIGHT=15
 #  TOP_HEIGHT=$(( ${config.my.poly-height} * 2 ))
 #  bsp-gaps-bar-cache
 #  gaps="$(bspc config right_padding)"
 #  if pgrep -x .tint2-wrapped  >/dev/null; then
 #   #echo $gaps
 #    if [[ $gaps -eq 0 ]]; then
 #      if pgrep polybar > /dev/null; then
 #        pkill .tint2-wrapped
 #        "$HOME/.bsp_gaps_bar_cache"
 #        bspc config bottom_padding $(( $(bspc config bottom_padding) - $BOTTOM_HEIGHT ))
 #        bspc config top_padding $TOP_HEIGHT
 #      else
 #        pkill .tint2-wrapped
 #       #"$HOME/.bsp_gaps_bar_cache"
 #        bspc config bottom_padding $(( $(bspc config bottom_padding) - $BOTTOM_HEIGHT ))
 #        bspc config top_padding 0
 #      fi
 #    else
 #      if pgrep polybar > /dev/null; then
 #        pkill .tint2-wrapped
 #        "$HOME/.bsp_gaps_bar_cache"
 #       #bspc config bottom_padding $(( $(bspc config bottom_padding) - $BOTTOM_HEIGHT ))
 #      else
 #        pkill .tint2-wrapped
 #       #"$HOME/.bsp_gaps_bar_cache"
 #       #bspc config bottom_padding $(( $(bspc config bottom_padding) - $BOTTOM_HEIGHT ))
 #      fi
 #    fi
 #  else
 #    tint2 &
 #    if [[ $gaps -eq 0 ]]; then
 #      POLY_TOP=$(bspc config top_padding)
 #      if pgrep polybar > /dev/null; then
 #        bspc config top_padding $TOP_HEIGHT
 #       #"$HOME/.bsp_gaps_bar_cache"
 #        echo "waaaaat"
 #      else
 #        bspc confid top_padding 0
 #      fi
 #    else
 #      if pgrep polybar > /dev/null; then
 #        echo $gaps
 #        "$HOME/.bsp_gaps_bar_cache"
 #      else
 #        bspc confid top_padding $(bspc confid bottom_padding)
 #      fi
 #    fi
 #  fi
 #'';
  bsp-tint2-hide = pkgs.writeShellScriptBin "bsp-tint2-hide" ''

    BOTOM_PADING=$(bspc config bottom_padding)
    GAPS=$(bspc config window_gap)
    TINT_HEIGHT=18
    if systemctl --user is-active --quiet bsptint.service; then
      bsp-tint-cache
      #bsp-gaps-bar-cache
      systemctl --user stop bsptint.service
      bspc config bottom_padding $(bspc config right_padding)
      touch "$HOME/.config/bspwm/tint-state"
    else
      systemctl --user restart bsptint.service
      if (( BOTOM_PADING < TINT_HEIGHT )); then
        bspc config bottom_padding $(( $(bspc config bottom_padding) + $TINT_HEIGHT ))
        systemctl --user restart bsptint.service
      else
        #$HOME/.bsp_gaps_bar_cache
        $HOME/.bsp_tint_cache
        systemctl --user restart bsptint.service
        rm -f $HOME/.bsp_tint_cache
      fi
    fi

  '';

 #bsp-poly-hide = pkgs.writeShellScriptBin "bsp-poly-hide" ''
 #  gaps="$(bspc config right_padding)"
 #  #bsp-gaps-bar-cache
 #  if [[ $gaps -eq 0 ]]; then
 #    bsp-gaps-bar-cache
 #    if pgrep polybar > /dev/null; then
 #      if pgrep -x .tint2-wrapped  >/dev/null; then
 #        pkill polybar
 #        "$HOME/.bsp_gaps_bar_cache"
 #        bspc config top_padding 0
 #      else
 #        pkill polybar
 #        "$HOME/.bsp_gaps_bar_cache"
 #        bspc config top_padding 0
 #        bspc config bottom_padding 0
 #      fi
 #    else
 #      if pgrep -x .tint2-wrapped  >/dev/null; then
 #        "$HOME/.bsp_gaps_bar_cache"
 #        polybar-start &
 #        #$HOME/.polybar_modules
 #      else
 #        polybar-start &
 #        #$HOME/.polybar_modules
 #        bspc config bottom_padding 0
 #      fi
 #    fi
 #  else
 #    if pgrep polybar > /dev/null; then
 #      bsp-gaps-bar-cache
 #      if pgrep -x .tint2-wrapped  >/dev/null; then
 #        pkill polybar
 #        "$HOME/.bsp_gaps_bar_cache"
 #        bspc config top_padding $(bspc config bottom_padding)
 #      else
 #        pkill polybar
 #        "$HOME/.bsp_gaps_bar_cache"
 #        bspc config top_padding $(bspc config bottom_padding)
 #      fi
 #    else
 #      "$HOME/.bsp_gaps_bar_cache"
 #      polybar-start &
 #      #$HOME/.polybar_modules
 #    fi
 #  fi
 #'';
  bsp-poly-hide = pkgs.writeShellScriptBin "bsp-poly-hide" ''

    TOP_PADING=$(bspc config top_padding)
    GAPS=$(bspc config window_gap)
    POLY_HEIGHT=30
    if systemctl --user is-active --quiet bsppoly.service; then
      if [ -f "$HOME/.config/bspwm/poly-state" ]; then
        if (( TOP_PADING < POLY_HEIGHT )); then
          bspc config top_padding $(( $(bspc config top_padding) + $POLY_HEIGHT ))
          systemctl --user restart bsptint.service
        else
          #$HOME/.bsp_gaps_bar_cache
          $HOME/.bsp_tint_cache
          systemctl --user restart bsptint.service
          rm -f $HOME/.bsp_tint_cache
        fi
        $HOME/.bsp_poly_cache
        polybar-msg cmd show
        rm -f "$HOME/.config/bspwm/poly-state"
      else
        bsp-poly-cache
        bspc config top_padding $(bspc config right_padding)
        polybar-msg cmd hide
        touch "$HOME/.config/bspwm/poly-state"
      fi
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

  bsp-manual-gaps = pkgs.writeShellScriptBin "bsp-manual-gaps" ''
    [ $# -ne 2 ] && {
        echo "Usage: $0 {left_padding|right_padding|top_padding|bottom_padding|gap} {+|-}"
        exit 1
    }
    param="$1"
    op="$2"
    case "$op" in
        +|-) ;;
        *) echo "Second argument must be + or -"; exit 1 ;;
    esac
    case "$param" in
        left_padding|right_padding|top_padding|bottom_padding)
            key="$param"
            ;;
        gap)
            key="window_gap"
            ;;
        *)
            echo "Unknown parameter: $param"
            exit 1
            ;;
    esac
    cur=$(bspc config "$key")
    adj() {
        [ "$op" = "+" ] && echo $(( cur + 1 )) || echo $(( cur - 1 ))
    }
    bspc config "$key" "$(adj)"
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
        for wid in $(bspc query -N -d ^"$desk"); do
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
        bspc node "$wid" --to-desktop ^"$desk"
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


  bsp-sticky-window = pkgs.writeShellScriptBin "bsp-sticky-window" ''
    ${builtins.readFile ./sticky}
  '';

  bsp-sticky-window-revert = pkgs.writeShellScriptBin "bsp-sticky-window-revert" ''
    CACHE_FILE="$HOME/.cache/bsp-sticky-window-cache"

    if [ -f "$CACHE_FILE" ]; then
        cached_data=$(cat "$CACHE_FILE")
        cached_window=$(echo "$cached_data" | cut -d':' -f1)
        cached_desktop=$(echo "$cached_data" | cut -d':' -f2)

        if bspc query -N -n "$cached_window" >/dev/null 2>&1; then
            bspc node "$cached_window" --flag sticky
            bspc node "$cached_window" -d "$cached_desktop"
        fi

        rm -f "$CACHE_FILE"
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
    TOP_HEIGHT=35
    BOTTOM_HEIGHT=14
    # Get current window gap
    gap=$(bspc config window_gap)

    if [ "$gap" -eq 0 ]; then
      if systemctl --user is-active --quiet bsppoly.service; then
        if [ -f "$HOME/.config/bspwm/poly-state" ]; then
          #bspc config top_padding $(bspc config right_padding)
           "$HOME/.bsp_gaps_cache"
           #bspc config top_padding $(bspc config right_padding)
        else
          "$HOME/.bsp_gaps_cache"
          #bspc config top_padding $(bspc config right_padding)
        fi
      else
        "$HOME/.bsp_gaps_cache"
        bspc config top_padding $(bspc config right_padding)
      fi
    else
      bsp-gaps-cache
      if systemctl --user is-active --quiet bsptint.service; then
          bspc config bottom_padding $BOTTOM_HEIGHT
      else
          bspc config bottom_padding 0
      fi
      # Turn off gaps
      bspc config left_padding 0
      bspc config right_padding 0
      bspc config window_gap 0
      if systemctl --user is-active --quiet bsppoly.service; then
        if [ -f "$HOME/.config/bspwm/poly-state" ]; then
          bspc config top_padding 0
        else
            bspc config top_padding $TOP_HEIGHT
        fi
      fi
    fi
  '';

  bsp-gaps-default = pkgs.writeShellScriptBin "bsp-gaps-default" ''
    TOP_HEIGHT=${config.my.poly-height}
    BOTTOM_HEIGHT=15

    bsp-gaps-cache
    bspc config left_padding ${toString config.xsession.windowManager.bspwm.settings.left_padding}
    bspc config right_padding ${toString config.xsession.windowManager.bspwm.settings.right_padding}
    bspc config window_gap ${toString config.xsession.windowManager.bspwm.settings.window_gap}
    if pgrep polybar > /dev/null; then
        bspc config top_padding $TOP_HEIGHT
        pkill polybar
        polybar-start &
        #$HOME/.polybar_modules
    else
        bspc config top_padding ${toString config.xsession.windowManager.bspwm.settings.top_padding}
    fi
    if pgrep -x .tint2-wrapped  >/dev/null; then
        bspc config bottom_padding $BOTTOM_HEIGHT
    else
        bspc config bottom_padding ${toString config.xsession.windowManager.bspwm.settings.bottom_padding}
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

  bsp-border-default = pkgs.writeShellScriptBin "bsp-border-default" ''
    bspc config border_width ${toString config.xsession.windowManager.bspwm.settings.border_width}
    bspc config focused_border_color ${config.xsession.windowManager.bspwm.settings.focused_border_color}
    bspc config normal_border_color ${config.xsession.windowManager.bspwm.settings.normal_border_color}
    bspc config active_border_color ${config.xsession.windowManager.bspwm.settings.active_border_color}
    bspc config presel_feedback_color ${config.xsession.windowManager.bspwm.settings.presel_feedback_color}
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

 #bsp-border-color = pkgs.writeShellScriptBin "bsp-border-color" ''
 #  ${builtins.readFile ./themes/${config.my.theme}-borders}
 #'';

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

  bsp-hide = pkgs.writeShellScriptBin "bsp-hide" ''
    ${builtins.readFile ./bsp-hide}
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
    current=$(bsp-layout get)

    case "$current" in
        tall)
            bsp-layout set tall2 ;;
        tall2)
            bsp-layout set tall3 ;;
        tall3)
            bsp-layout set tall4 ;;
        rtall)
            bsp-layout set rtall2 ;;
        rtall2)
            bsp-layout set rtall3 ;;
        rtall3)
            bsp-layout set rtall4 ;;
        wide)
            bsp-layout set wide2 ;;
        wide2)
            bsp-layout set wide3 ;;
        wide3)
            bsp-layout set wide4 ;;
        rwide)
            bsp-layout set rwide2 ;;
        rwide2)
            bsp-layout set rwide3 ;;
        rwide3)
            bsp-layout set rwide4 ;;
        cmaster)
            bsp-layout set cmaster2 ;;
        cmaster2)
            bsp-layout set cmaster3 ;;
        rcmaster)
            bsp-layout set rcmaster2 ;;
        rcmaster2)
            bsp-layout set rcmaster3 ;;
        dmaster)
            bsp-layout set dmaster2 ;;
        dmaster2)
            bsp-layout set dmaster3 ;;
        rdmaster)
            bsp-layout set rdmaster2 ;;
        rdmaster2)
            bsp-layout set rdmaster3 ;;
        hdmaster)
            bsp-layout set hdmaster2 ;;
        hdmaster2)
            bsp-layout set hdmaster3 ;;
        rhdmaster)
            bsp-layout set rhdmaster2 ;;
        rhdmaster2)
            bsp-layout set rhdmaster3 ;;
        row)
            bsp-layout set row2 ;;
        row2)
            bsp-layout set row3 ;;
        row3)
            bsp-layout set row4 ;;
        row4)
            bsp-layout set row5 ;;
        row5)
            bsp-layout set row6 ;;
        col)
            bsp-layout set col2 ;;
        col2)
            bsp-layout set col3 ;;
        col3)
            bsp-layout set col4 ;;
        col4)
            bsp-layout set col5 ;;
        col5)
            bsp-layout set col6 ;;
        *)
            echo "Unknown layout: $current" ;;
    esac
  '';

  bsp-master-node-decrease = pkgs.writeShellScriptBin "bsp-master-node-decrease" ''
    # Get current layout
    current=$(bsp-layout get)

    case "$current" in
        tall4)
            bsp-layout set tall3 ;;
        tall3)
            bsp-layout set tall2 ;;
        tall2)
            bsp-layout set tall ;;
        rtall4)
            bsp-layout set rtall3 ;;
        rtall3)
            bsp-layout set rtall2 ;;
        rtall2)
            bsp-layout set rtall ;;
        wide4)
            bsp-layout set wide3 ;;
        wide3)
            bsp-layout set wide2 ;;
        wide2)
            bsp-layout set wide ;;
        rwide4)
            bsp-layout set rwide3 ;;
        rwide3)
            bsp-layout set rwide2 ;;
        rwide2)
            bsp-layout set rwide ;;
         cmaster3)
            bsp-layout set cmaster2 ;;
         cmaster2)
            bsp-layout set cmaster ;;
         rcmaster3)
            bsp-layout set rcmaster2 ;;
         rcmaster2)
            bsp-layout set rcmaster ;;
         dmaster3)
            bsp-layout set dmaster2 ;;
         dmaster2)
            bsp-layout set dmaster ;;
         rdmaster3)
            bsp-layout set rdmaster2 ;;
         rdmaster2)
            bsp-layout set rdmaster ;;
         hdmaster3)
            bsp-layout set hdmaster2 ;;
         hdmaster2)
            bsp-layout set hdmaster ;;
         rhdmaster3)
            bsp-layout set rhdmaster2 ;;
         rhdmaster2)
            bsp-layout set rhdmaster ;;
         row6)
             bsp-layout set row5 ;;
         row5)
             bsp-layout set row4 ;;
         row4)
             bsp-layout set row3 ;;
         row3)
             bsp-layout set row2 ;;
         row2)
             bsp-layout set row ;;
         col6)
             bsp-layout set col5 ;;
         col5)
             bsp-layout set col4 ;;
         col4)
             bsp-layout set col3 ;;
         col3)
             bsp-layout set col2 ;;
         col2)
             bsp-layout set col ;;
         *)
             echo "Unknown layout: $current" ;;
    esac
  '';

  bsp-move-master = pkgs.writeShellScriptBin "bsp-move-master" ''
    # Get current layout
    current=$(bsp-layout get)

    case "$current" in
        dmaster)
            bsp-layout set cmaster ;;
        cmaster)
            bsp-layout set rdmaster ;;
        rdmaster)
            bsp-layout set dmaster ;;
        hdmaster)
            bsp-layout set rcmaster ;;
        rcmaster)
            bsp-layout set rhdmaster ;;
        rhdmaster)
            bsp-layout set hdmaster ;;
        tv-nw)
            bsp-layout set tv-sw ;;
        tv-sw)
            bsp-layout set tv-ne ;;
        tv-ne)
            bsp-layout set tv-nw ;;
        *)
            echo "Unknown layout: $current" ;;
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

 #bsp-full-screen = pkgs.writeShellScriptBin "bsp-full-screen" ''
 #
 #  if [ -n "$(bspc query -N -n focused.fullscreen)" ]; then
 #     if [[ -f "$HOME/.polybar-status" ]]; then
 #       if pgrep polybar > /dev/null; then
 #          bspc node -t tiled
 #        else
 #         #polybar & disown & tint2 & disown & bspc node -t tiled
 #          bsp-bar-hide & bspc node -t tiled
 #          $HOME/.polybar_modules
 #          rm -f $HOME/.polybar-status
 #        fi
 #      else
 #        bspc node -t tiled
 #      fi
 #  else
 #    if pgrep polybar > /dev/null; then
 #     #pkill polybar & sleep 3 & pkill tint2 & bspc node -t fullscreen
 #      touch $HOME/.polybar-status
 #      bsp-bar-hide & bspc node -t fullscreen
 #      exit
 #    else
 #      bspc node -t fullscreen
 #      exit
 #    fi
 #  fi
 #'';
  bsp-full-screen = pkgs.writeShellScriptBin "bsp-full-screen" ''
    if [ -n "$(bspc query -N -n focused.fullscreen)" ]; then
      bspc node -t tiled
    else
      bspc node -t fullscreen
    fi
  '';

  bsp-skippy = pkgs.writeShellScriptBin "bsp-skippy" ''
    if pgrep skippy-xd >/dev/null 2>&1; then
          pkill skippy-xd
       else
          skippy-xd --start-daemon
    fi

    #skippy-xd --start-daemon

  '';

  bsp-conf = pkgs.writeShellScriptBin "bsp-conf" ''
    ${builtins.readFile ./bspconf}
  '';

  bsp-conf-color = pkgs.writeShellScriptBin "bsp-conf-color" ''
    ${builtins.readFile ./bspconfcolor}
  '';

  bsp-gaps-cache = pkgs.writeShellScriptBin "bsp-gaps-cache" ''
    ${builtins.readFile ./bsp-gaps-cache}
  '';

  bsp-gaps-bar-cache = pkgs.writeShellScriptBin "bsp-gaps-bar-cache" ''
    ${builtins.readFile ./bsp-gaps-bar-cache}
  '';

  bsp-tint-cache = pkgs.writeShellScriptBin "bsp-tint-cache" ''
    ${builtins.readFile ./bsp-tint-cache}
  '';

  bsp-poly-cache = pkgs.writeShellScriptBin "bsp-poly-cache" ''
    ${builtins.readFile ./bsp-poly-cache}
  '';

  bsp-hidden-menu = pkgs.writeShellScriptBin "bsp-hidden-menu" ''
    FILTER_PATTERNS="WM_NAME"

    # Get hidden window IDs and names
    windows=""
    while read id; do
        name=$(xprop -id "$id" WM_NAME 2>/dev/null | cut -d'"' -f2)
        # Skip filtered names
        echo "$name" | grep -qiE "$FILTER_PATTERNS" && continue

        class=$(xprop -id "$id" WM_CLASS 2>/dev/null | grep -o '"[^"]*"' | tail -1 | tr -d '"')
        windows+="$name\0icon\x1f$class\n"
    done < <(bspc query -N -d focused -n .hidden)

    # Show in rofi and get selection
    selected=$(echo -e "$windows" | rofi -dmenu -i -p "Hidden windows:" -show-icons -theme $HOME/.config/rofi/themes/power.rasi)

    # Unhide selected window
    if [ -n "$selected" ]; then
        id=$(bspc query -N -d focused -n .hidden | while read wid; do
            wname=$(xprop -id "$wid" WM_NAME 2>/dev/null | cut -d'"' -f2)
            [ "$wname" = "$selected" ] && echo "$wid" && break
        done)
        [ -n "$id" ] && bspc node "$id" --flag hidden=off --focus
    fi
  '';

  bsp-icon-bar = pkgs.writeShellScriptBin "bsp-icon-bar" ''
    bspc subscribe node_add node_remove node_transfer desktop_layout | while read -r line; do
        case $line in
          node_add*|node_remove*|node_transfer*|desktop_layout*)
                bspi --config ${nix-path}/modules/hm/desktops/bspwm/bspi.ini
                ;;
            *)
            ;;
        esac
    done
  '';

  bspi = pkgs.writeScriptBin "bspi" ''
    ${builtins.readFile ./bspi.py}
  '';

  bsp-window-rules-add = pkgs.writeScriptBin "bsp-window-rules-add" ''
    bspc rule -a kate desktop='^2' follow=on
    bspc rule -a dolphin desktop='^2' follow=on
    bspc rule -a brave-browser desktop='^3' follow=on
  '';

  bsp-window-rules-remove = pkgs.writeScriptBin "bsp-window-rules-remove" ''
    bspc rule -a kate desktop="" follow=off
    bspc rule -a dolphin desktop="" follow=off
    bspc rule -a brave-browser desktop="" follow=off
  '';

  bsp-group-delete = pkgs.writeScriptBin "bsp-group-delete" ''
    file="$HOME/.cache/bsp-delete"
    [ -f "$file" ] && while read line; do bspc node "$line" -c; done < "$file"
    rm -f "$file"
  '';

  bsp-rofi-group-delete-cache = pkgs.writeScriptBin "bsp-rofi-group-delete-cache" ''
    ${builtins.readFile ./bsp-rofi-group-delete-cache}
  '';

  bsp-layout-rofi = pkgs.writeScriptBin "bsp-layout-rofi" ''
    ROFI_THEME="$HOME/.config/rofi/themes/main.rasi"

    chosen=$(echo -e "[Cancel]\n Remove\n Master\n rMaster\n wMaster\n rwMaster\n cMaster\n rcMaster\n dMaster\n Grid\n rGrid\n Even\n Floating\n Columns\n Rows\n TV\n rTV\n Monocle\n Tiled" | \
        rofi -dmenu -i -p "Dynamic Layouts" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

    case "$chosen" in
        " Remove") bsp-cmaster-remove; bsp-layout remove; bsp-layout-ext remove; bsp-culomns-rows-layout-remove ;;
        " Master") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set tall  ;;
        " rMaster") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set rtall  ;;
        " wMaster") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set wide  ;;
        " rwMaster") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set rwide  ;;
        " cMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-cmaster-layout ;;
        " rcMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-rcmaster-layout ;;
        " dMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-double-stack-layout ;;
        " Grid") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set grid ;;
        " rGrid") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set rgrid ;;
        " Even") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set even ;;
        " Floating") bsp-cmaster-remove & bsp-layout remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-float ;;
        " Columns") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns ;;
        " Rows") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-layout remove & bsp-layout-ext remove & bsp-rows ;;
        " TV") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-tv-layout ;;
        " rTV") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-rtv-layout ;;
        " Monocle") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set monocle ;;
        " Tiled") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout set tiled ;;


        *) exit 0 ;; # Exit on cancel or invalid input
    esac
  '';

  bsp-layout-oneshot-rofi = pkgs.writeScriptBin "bsp-layout-oneshot-rofi" ''
    ROFI_THEME="$HOME/.config/rofi/themes/main.rasi"

    chosen=$(echo -e "[Cancel]\n Master\n rMaster\n wMaster\n rwMaster\n cMaster\n rcMaster\n dMaster\n rdMaster\n Grid\n rGrid\n Even\n Floating\n Columns\n Rows\n TV\n rTV" | \
        rofi -dmenu -i -p "OneShot Layouts" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

    case "$chosen" in
        " Master") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once tall  ;;
        " rMaster") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once rtall  ;;
        " wMaster") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once wide  ;;
        " rwMaster") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once rwide  ;;
        " cMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-cmaster-oneshot ;;
        " rcMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-rcmaster-oneshot ;;
        " dMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-cmaster-oneshot & bspc node @parent -R 180 ;;
        " rdMaster") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-rcmaster-oneshot & bspc node @parent -R 180 ;;
        " Grid") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once grid ;;
        " rGrid") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once rgrid ;;
        " Even") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-layout once even ;;
        " Floating") bsp-cmaster-remove & bsp-layout remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-float ;;
        " Columns") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-layout remove & bsp-layout-ext remove & bsp-vertical-layout-oneshot ;;
        " Rows") bsp-cmaster-remove & bsp-culomns-rows-layout-remove & bsp-layout remove & bsp-layout-ext remove & bsp-horizontal-layout-oneshot ;;
        " TV") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-cmaster-oneshot & bspc node @parent -R -90 ;;
        " rTV") bsp-cmaster-remove & bsp-layout remove & bsp-layout-ext remove & bsp-culomns-rows-layout-remove & bsp-cache-layout & bsp-cmaster-oneshot & bspc node @parent -R 90 ;;


        *) exit 0 ;; # Exit on cancel or invalid input
    esac
  '';

 #bsp-auto-color = pkgs.writeShellScriptBin "bsp-auto-color" ''
 #  ${builtins.readFile ./bsp-auto-color}
 #'';
  bsp-auto-color = pkgs.writeShellScriptBin "bsp-auto-color" ''
    if [ -f "$HOME/.config/bspwm/bsp-auto-color" ]; then
        rm -f "$HOME/.config/bspwm/bsp-auto-color"
        systemctl --user stop bspborder.service
        notify-send -e -u low -t 2000 "Per App Border Color" "Off"
    else
        touch "$HOME/.config/bspwm/bsp-auto-color"
        systemctl --user start bspborder.service
        notify-send -e -u low -t 2000 "Per App Border Color" "On"
    fi
  '';

  bsp-de-sounds = pkgs.writeShellScriptBin "bsp-de-sounds" ''
    ${builtins.readFile ./sounds}
  '';

 #bsp-sounds-toggle = pkgs.writeShellScriptBin "bsp-sounds-toggle" ''
 #  ${builtins.readFile ./bsp-sounds}
 #'';
  bsp-sounds-toggle = pkgs.writeShellScriptBin "bsp-sounds-toggle" ''
    if [ -f "$HOME/.config/bspwm/bsp-sounds-toggle" ]; then
        rm -f "$HOME/.config/bspwm/bsp-sounds-toggle"
        systemctl --user stop bspsounds.service
        notify-send -e -u low -t 2000 "Desktop Sounds" "Off"
    else
        touch "$HOME/.config/bspwm/bsp-sounds-toggle"
        systemctl --user start bspsounds.service
        notify-send -e -u low -t 2000 "Desktop Sounds" "On"
    fi
  '';

  bsp-remove-layout = pkgs.writeShellScriptBin "bsp-remove-layout" ''
    bsp-layout remove
    bsp-stack-zoom-remove
  '';

  bsp-remove-layout-me = pkgs.writeShellScriptBin "bsp-remove-layout-me" ''
    echo "no self-made layouts for now"
    bsp-stack-zoom-remove
  '';

  bsp-recalculate-layout = pkgs.writeShellScriptBin "bsp-recalculate-layout" ''
    current_layout=$(bsp-layout get)
    bsp-layout set $current_layout
  '';

  bsp-stack-zoom-oneshot = pkgs.writeShellScriptBin "bsp-stack-zoom-oneshot" ''
    ${builtins.readFile ./bsp-stack-zoom}
  '';

  bsp-stack-zoom = pkgs.writeShellScriptBin "bsp-stack-zoom" ''
    DESKTOP=$(bspc query -D -d focused)
    LOCKFILE="$HOME/.cache/bsp-stack-zoom-$DESKTOP.lock"

    # Prevent multiple instances
    if [[ -f "$LOCKFILE" ]] && kill -0 "$(cat "$LOCKFILE")" 2>/dev/null; then
        exit 0
    fi

    # Record current PID in lock file
    echo $$ > "$LOCKFILE"

    # Ensure lock file is removed when script exits
    trap 'rm -f "$LOCKFILE"' EXIT
    PID_FILE_LISTEN="$HOME/.cache/bsp-stack-zoom-$DESKTOP.pid"
    kill $(cat "$PID_FILE_LISTEN") 2>/dev/null
    rm -f "$PID_FILE_LISTEN"

    bsp-stack-zoom-oneshot
    {
        while read -r line; do
            # Split the line into fields
            read -r event monitor desktop node action <<< "$line"

            # Only act if the desktop matches
            if [[ "$desktop" == "$DESKTOP" ]]; then
              bsp-stack-zoom-oneshot
            fi
        done < <(bspc subscribe node_focus node_swap)
    } &

    # Save the PID of the background listener
    echo $! > "$PID_FILE_LISTEN"
  '';

  bsp-stack-zoom-remove = pkgs.writeShellScriptBin "bsp-stack-zoom-remove" ''
    DESKTOP=$(bspc query -D -d focused)
    PID_FILE_LISTEN="$HOME/.cache/bsp-stack-zoom-$DESKTOP.pid"
    kill $(cat "$PID_FILE_LISTEN")
    rm -f "$PID_FILE_LISTEN"
    bsp-layout reload
  '';

 #bsp-abhide = pkgs.writeScriptBin "bsp-abhide" ''
 #  bspc subscribe node_state desktop_focus node_add node_remove | \
 #  while read -r event monitor desktop node_id; do
 #
 #    wid=$(bspc query -T -n)
 #    state=$(printf '%s\n' "$wid" | jq -r '.client.state')
 #
 #    sleep 0.5
 #    if [[ $state = "fullscreen" ]]; then
 #      if pgrep polybar > /dev/null; then
 #        bsp-bar-hide
 #        touch $HOME/.polybar-status
 #      else
 #        continue
 #      fi
 #    else
 #      if pgrep polybar > /dev/null; then
 #        echo ""
 #      else
 #        if [[ -f "$HOME/.polybar-status"  ]]; then
 #          bsp-bar-hide
 #        fi
 #      fi
 #
 #    fi
 #  done
 #'';

  bsp-abhide = pkgs.writeScriptBin "bsp-abhide" ''
      {
          while read -r line; do
              read -r event monitor desktop node action <<< "$line"
              wid=$(bspc query -T -n)
              state=$(printf '%s\n' "$wid" | jq -r '.client.state')

              sleep 0.5
              if [[ $state = "fullscreen" ]]; then
                if pgrep polybar > /dev/null; then
                  bsp-bar-hide
                  touch $HOME/.polybar-status
                else
                  continue
                fi
              else
                if pgrep polybar > /dev/null; then
                  echo ""
                else
                  if [[ -f "$HOME/.polybar-status"  ]]; then
                    bsp-bar-hide
                  fi
                fi

              fi
          done < <(bspc subscribe node_state node_add node_remove desktop_focus)
      }
  '';

  bsp-s-autohide = pkgs.writeShellScriptBin "bsp-s-autohide" ''
    ${builtins.readFile ./bsp-s-autohide}
  '';

  poly-bsp-lay = pkgs.writeShellScriptBin "poly-bsp-lay" ''
    bspc subscribe desktop_focus | while read -r event; do
      polybar-msg action "#bspwm.hook.1"
    done
  '';

  live-bg-auto = pkgs.writeShellScriptBin "live-bg-auto" ''
      {
          while read -r line; do
              # Split the line into fields
              read -r event monitor desktop node action <<< "$line"

                  pp() {
                      PROC="paperview-rs"
                      PID=$(pgrep -n "$PROC")
                      pgrep -n "$PROC" &&
                      WINCOUNT=$(bspc query -N '@/' -n .descendant_of.window.!hidden.!floating | wc -l)
                      if [[ $WINCOUNT -eq 0 ]]; then
                        kill -CONT "$PID"
                      fi
                      if [[ $WINCOUNT -gt 0 ]]; then
                        kill -STOP "$PID"
                      fi
                  }

                  case "$event" in
      		    node_focus) pp;;
      		    node_remove) pp;;
      		    node_state) pp;;
      		    node_transfer) pp;;
      		    desktop_focus) pp;;
                  esac

          done < <(bspc subscribe node_focus desktop_focus)
      }
  '';

 #live-bg-pause-script = pkgs.writeShellScriptBin "live-bg-pause-script" ''
 #  ${builtins.readFile ./live-bg-pause-script}
 #'';
  live-bg-pause-script = pkgs.writeShellScriptBin "live-bg-pause-script" ''
    if [ -f "$HOME/.config/bspwm/bsp-live-auto-pause" ]; then
        rm -f "$HOME/.config/bspwm/bsp-live-auto-pause"
        systemctl --user stop bsplive.service
        notify-send -e -u low -t 2000 "Auto Live Wallpaper Pause" "Off"
    else
        touch "$HOME/.config/bspwm/bsp-live-auto-pause"
        systemctl --user start bsplive.service
        notify-send -e -u low -t 2000 "Auto Live Wallpaper Pause" "On"
    fi
  '';

  bsp-bspi-toggle = pkgs.writeShellScriptBin "bsp-bspi-toggle" ''
    if [ -f "$HOME/.config/bspwm/bsp-bspi-icons" ]; then
        rm -f "$HOME/.config/bspwm/bsp-bspi-icons"
        systemctl --user stop bspicon.service
        notify-send -e -u low -t 2000 "bspi Icons" "Off"
        bsp-default-icon
    else
        touch "$HOME/.config/bspwm/bsp-bspi-icons"
        systemctl --user start bspicon.service
        notify-send -e -u low -t 2000 "bspi Icons" "On"
    fi
  '';

  bsp-layout-status = pkgs.writeShellScriptBin "bsp-layout-status" ''
    if [ -f "$HOME/.config/bspwm/bsp-layout-status" ]; then
        rm -f "$HOME/.config/bspwm/bsp-layout-status"
        systemctl --user stop bsplayout.service
        notify-send -e -u low -t 2000 "bsp-layout Status" "Off"
    else
        touch "$HOME/.config/bspwm/bsp-layout-status"
        systemctl --user start bsplayout.service
        notify-send -e -u low -t 2000 "bsp-layout Status" "On"
    fi
  '';


  bsp-subscribtions = pkgs.writeShellScriptBin "bsp-subscribtions" ''

    if [ -f "$HOME/.config/bspwm/bsp-live-auto-pause" ]; then
        systemctl --user start bsplive.service
    else
        systemctl --user stop bsplive.service
    fi

    if [ -f "$HOME/.config/bspwm/bsp-bspi-icons" ]; then
        systemctl --user start bspicon.service
    else
        systemctl --user stop bspicon.service
        bsp-default-icon
    fi

    if [ -f "$HOME/.config/bspwm/bsp-sounds-toggle" ]; then
        systemctl --user start bspsounds.service
    else
        systemctl --user stop bspsounds.service
    fi

    if [ -f "$HOME/.config/bspwm/bsp-auto-color" ]; then
        systemctl --user start bspborder.service
    else
        systemctl --user stop bspborder.service
    fi

    if [ -f "$HOME/.config/bspwm/bsp-layout-status" ]; then
        systemctl --user start bsplayout.service
    else
        systemctl --user stop bsplayout.service
    fi

    #if [ -f "$HOME/.config/bspwm/bsp-auto-bar-hide" ]; then
    #    systemctl --user start bspautohide.service
    #else
    #   systemctl --user stop bspautohide.service
    #fi

  '';

  bsp-power-man = pkgs.writeShellScriptBin "bsp-power-man" ''

    case "$1" in

      battery-save)
        systemctl --user stop bsplive.service
        systemctl --user stop bspicon.service
        bsp-default-icon
        systemctl --user stop bspsounds.service
        systemctl --user stop bspborder.service
        systemctl --user stop bsplayout.service
        #systemctl --user stop bspautohide.service

        powerprofilesctl set power-saver
        polybar-msg action "#pp.hook.1"

        pkill paperview-rs
        $HOME/.fehbg

        xset s blank
        xset s on
        xset s $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) ${toString config.services.screen-locker.xss-lock.screensaverCycle}
        xset +dpms
        xset dpms $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) $(( ${toString config.services.screen-locker.inactiveInterval} * 60 ))
        systemctl --user restart xautolock-session.service
        systemctl --user restart xss-lock.service
        polybar-msg action "#idle.hook.1"

        systemctl --user stop picom.service
        polybar-msg action "#picom.hook.1"

        xbacklight -20

        echo "battery-save" > "$HOME/.config/bspwm/bsp-power-state"
      ;;


      performance)
        systemctl --user stop bsplive.service
        systemctl --user stop bspicon.service
        bsp-default-icon
        systemctl --user stop bspsounds.service
        systemctl --user stop bspborder.service
        systemctl --user stop bsplayout.service
        #systemctl --user stop bspautohide.service

        powerprofilesctl set performance
        polybar-msg action "#pp.hook.1"

        pkill paperview-rs
        $HOME/.fehbg

        pkill .xscreensaver-w
        pkill xscreensaver-sy
        pkill .xscreensaver-s
        systemctl --user stop xautolock-session.service
        systemctl --user stop xss-lock.service
        xset s noblank
        xset s off
        xset s 0 0
        xset -dpms
        xset dpms 0 0 0
        polybar-msg action "#idle.hook.1"

        systemctl --user start picom.service
        polybar-msg action "#picom.hook.1"

        xbacklight +20

        echo "performance" > "$HOME/.config/bspwm/bsp-power-state"
      ;;


      fancy)
        systemctl --user start bsplive.service
        systemctl --user start bspicon.service
        systemctl --user start bspsounds.service
        systemctl --user start bspborder.service
        systemctl --user start bsplayout.service
        #systemctl --user start bspautohide.service

        systemctl --user start picom.service
        polybar-msg action "#picom.hook.1"

        echo "fancy" > "$HOME/.config/bspwm/bsp-power-state"
      ;;


      manual)
        bsp-subscribtions
        echo "manual" > "$HOME/.config/bspwm/bsp-power-state"
      ;;

    esac

  '';

  tint-go-below = pkgs.writeShellScriptBin "tint-go-below" ''
    sleep 0.5
    xdo above -t "$(xdo id -N Bspwm -n root | sort | head -n 1)" $(xdo id -n tint2)
  '';

  bsp-set-layout = pkgs.writeShellScriptBin "bsp-set-layout" ''
    bsp-remove-layout; bsp-cache-layout; bsp-layout set $1; polybar-msg action "#bspwm.hook.1"
  '';

  bsp-once-layout = pkgs.writeShellScriptBin "bsp-once-layout" ''
    bsp-remove-layout; bsp-cache-layout; bsp-layout once $1; polybar-msg action "#bspwm.hook.1"
  '';

in

{

  config = lib.mkIf cfg.enable {

    home.packages = [

      bsp-plank-reset
      bsp-help
      bsp-conf
      bsp-conf-color
      bsp-volume
      bsp-once-layout
      bsp-set-layout
      bsp-layout-manager
      bsp-remove-layout
      bsp-remove-layout-me
      bsp-xkb-layout
      bsp-float
      bsp-power
      bsp-bar-hide
      bsp-tint2-hide
      bsp-poly-hide
      bsp-dock-hide
      bsp-gaps
      bsp-gaps-cache
      bsp-gaps-bar-cache
      bsp-gaps-default
      bsp-manual-gaps
      bsp-border-default
      bsp-tag-view
      bsp-tag-view-revert
      bsp-tag-view-rofi
      bsp-restore-cached-layout
      bsp-cache-layout
      bsp-zoom
      bsp-zoom-second_biggest
      bsp-send-follow
     #bsp-border-color
      bsp-border-size
      bsp-border-toggle
      bsp-gaps-toggle
      bsp-empty-remove
      bsp-touchegg
      bsp-hide
      bsp-conky
      bsp-desktop-switch
      bsp-desktop-switch-follow
      bsp-manual-window-swap
      bsp-manual-window-send
      bsp-master-node-increase
      bsp-master-node-decrease
      bsp-manual-order-load
      bsp-manual-order-save
      bsp-manual-order-remove
      bsp-full-screen
      bsp-skippy
      bsp-sticky-window
      bsp-sticky-window-revert
      bsp-hidden-menu
      bsp-icon-bar
      bsp-window-rules-add
      bsp-window-rules-remove
      bsp-group-delete
      bsp-rofi-group-delete-cache
      bsp-layout-rofi
      bsp-layout-oneshot-rofi
      bsp-auto-color
      bsp-de-sounds
      bsp-sounds-toggle
      bsp-recalculate-layout
      bsp-move-master
      bsp-stack-zoom-oneshot
      bsp-stack-zoom
      bsp-stack-zoom-remove
      bsp-abhide
      bsp-s-autohide
      bsp-tint-cache
      bsp-poly-cache
      bsp-subscribtions
      bsp-bspi-toggle
      bsp-layout-status
      bsp-power-man
      poly-bsp-lay
      live-bg-auto
      live-bg-pause-script
      bspswallow
      bspwmswallow
      pidswallow
      bspad
      scratchpad
      bspi
      tint-go-below

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

    systemd.user.services.bsptint = {
      Unit = {
       Description = "Tint2 for bspwm";
       ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
      #X-Restart-Triggers = [ "${nix-path}/.config/polybar/config.ini" ];
      };
      Service = {
        Type = "simple";
        ExecStart = "${config.programs.tint2.package}/bin/tint2";
        ExecStartPost = "${tint-go-below}/bin/tint-go-below";
        Restart = "on-failure";
      };
     #Install = {
     #  WantedBy = [ "graphical-session.target" ];
     #};
    };

    systemd.user.services.bspicon = {
      Unit = {
       Description = "bspwm bspi, icons for bar";
       ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
      #After = "graphical-session.target";
      #Wants = "graphical-session.target";
      };
      Service = {
        Type = "simple";
        ExecStart = "${bsp-icon-bar}/bin/bsp-icon-bar";
        Restart = "on-failure";
      };
     #Install = {
     #  WantedBy = [ "graphical-session.target" ];
     #};
    };

    systemd.user.services.bsplayout = {
      Unit = {
       Description = "bspwm layout detection";
       ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
      };
      Service = {
        Type = "simple";
        ExecStart = "${poly-bsp-lay}/bin/poly-bsp-lay";
        Restart = "on-failure";
      };
     #Install = {
     #  WantedBy = [ "graphical-session.target" ];
     #};
    };

    systemd.user.services.bspsounds = {
      Unit = {
       Description = "bspwm desktop sounds";
       ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
      };
      Service = {
        Type = "simple";
        ExecStart = "${bsp-de-sounds}/bin/bsp-de-sounds";
        Restart = "on-failure";
      };
     #Install = {
     #  WantedBy = [ "graphical-session.target" ];
     #};
    };

    systemd.user.services.bsplive = {
      Unit = {
       Description = "bspwm auto live wallpaper pause";
       ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
      };
      Service = {
        Type = "simple";
        ExecStart = "${live-bg-auto}/bin/live-bg-auto";
        Restart = "on-failure";
      };
     #Install = {
     #  WantedBy = [ "graphical-session.target" ];
     #};
    };

    systemd.user.services.bspautohide = {
      Unit = {
       Description = "bspwm auto bar hide and show";
       ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
      };
      Service = {
        Type = "simple";
        ExecStart = "${bsp-abhide}/bin/bsp-abhide";
        Restart = "on-failure";
      };
     #Install = {
     #  WantedBy = [ "graphical-session.target" ];
     #};
    };

};}
