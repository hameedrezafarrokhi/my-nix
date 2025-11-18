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

    chosen=$(echo -e "[Cancel]\n󰑓 Reload BSPWM❤️\n Lock\n󰍃 Logout\n󰒲 Sleep\n󰤆 Shutdown\n󱄋 Reboot" | \
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
        conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
        #plank &
        dockx &
    fi
  '';

  bsp-tint2-hide = pkgs.writeShellScriptBin "bsp-tint2-hide" ''
    if hash tint2 >/dev/null 2>&1; then
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

  scratchpad = pkgs.writeShellScriptBin "scratchpad" ''
    ${builtins.readFile ./scratchpad}
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

  bsp-cmaster-layout = pkgs.writeShellScriptBin "bsp-cmaster-layout" ''
    ${builtins.readFile ./layouts/ctall.sh}
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


in

{

  options.my.bspwm.enable = lib.mkEnableOption "bspwm";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.bspwm = {

      enable = true;
      package = pkgs.bspwm;
      alwaysResetDesktops = true;

     #monitors = { };

      # bspc monitor -d 1 2 3 4 5 6 7 8 9 10
      extraConfigEarly = ''
        bspc monitor -d 1 2 3 4 5 6 7 8 9 10
        export XDG_CURRENT_DESKTOP=BSPWM &
        export desktop=BSPWM &
      '';

      # killall -q polybar
      # polybar -c ~/.config/bspwm/polybar/config.ini &
      extraConfig = ''

        #bspc rule -a '*' desktop='^10$' state=floating

        bspc subscribe node_add | while read -r event; do
            node_id=$(echo "$event" | cut -d' ' -f5)
            desktop=$(bspc query -D -d focused --names)
            if [ "$desktop" = "10" ]; then
                bspc node "$node_id" -t floating
            fi
        done &

        bspc rule -a ulauncher border=off
        bspc rule -a Ulauncher border=off
        bspc rule -a scratchpad state=floating layer=normal

        bspc rule -a plank layer=top    # manage=on border=off  # locked=on focus=off follow=off
        bspc rule -a Plank layer=top    # manage=on border=off  # locked=on focus=off follow=off
        bspc rule -a dockx layer=top    # manage=on border=off  # locked=on focus=off follow=off
        bspc rule -a Dockx layer=top    # manage=on border=off  # locked=on focus=off follow=off
        bspc rule -a dockbarx layer=top # manage=on border=off  # locked=on focus=off follow=off
        bspc rule -a Dockbarx layer=top # manage=on border=off  # locked=on focus=off follow=off

        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N dockbarx &
        #done

        if hash sxhkd >/dev/null 2>&1; then
        	  pkill sxhkd
        	  sleep 0.5
        	  sxhkd -c "${nix-path}/modules/hm/desktops/bspwm/sxhkdrc" &
        fi

        if hash polybar >/dev/null 2>&1; then
        	  pkill polybar
        	  sleep 1.5
        	  polybar ${config.my.poly-name} &
        fi

        if hash conky >/dev/null 2>&1; then
        	  pkill conky
        	  sleep 0.5
        	  conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
        fi

        #if hash plank >/dev/null 2>&1; then
        #	  pkill plank
        #	  sleep 0.5
        #	  plank &
        #fi

        if hash dockx >/dev/null 2>&1; then
        	  pkill dockx
        	  sleep 0.5
        	  dockx &
        fi

        if hash tint2 >/dev/null 2>&1; then
        	  pkill tint2
        	  sleep 0.5
        	  tint2 -c ${nix-path}/modules/hm/bar-shell/tint2/dock/liness/tint.tint2rc &
        fi

        if hash skippy-xd >/dev/null 2>&1; then
        	  skippy-xd --stop-daemon
        	  sleep 0.5
        	  skippy-xd --start-daemon &
        fi

       #bspc subscribe node_add | while read -r _; do
       #   xdo raise -N Plank &
       #done
       #bspc subscribe node_add | while read -r _; do
       #   xdo raise -N dockx &
       #done &
       #bspc subscribe node_add | while read -r _; do
       #   xdo raise -N Dockx &
       #done &

       rm -f ~/.cache/bspwm_zoom_last_1
       rm -f ~/.cache/bspwm_zoom_last_2
       rm -f ~/.cache/bspwm_zoom_last_3
       rm -f ~/.cache/bspwm_zoom_last_4
       rm -f ~/.cache/bspwm_zoom_last_5
       rm -f ~/.cache/bspwm_zoom_last_6
       rm -f ~/.cache/bspwm_zoom_last_7
       rm -f ~/.cache/bspwm_zoom_last_8
       rm -f ~/.cache/bspwm_zoom_last_9
       rm -f ~/.cache/bspwm_zoom_last_10
       rm -f ~/.cache/bspwm_zoom_last_12
       rm -f ~/.cache/bspwm_zoom_last_13
       rm -f ~/.cache/bspwm_zoom_last_14
       rm -f ~/.cache/bspwm_zoom_last_15
       rm -f ~/.cache/bspwm_zoom_last_16
       rm -f ~/.cache/bspwm_zoom_last_17
       rm -f ~/.cache/bspwm_zoom_last_18
       rm -f ~/.cache/bspwm_zoom_last_19
       rm -f ~/.cache/bspwm_zoom_last_20

       rm -f "$HOME/.cache/bsp"* 2>/dev/null

      '';

      startupPrograms = [
       #"numlockx on"
       #"tilda"
       #"feh --bg-fill /home/hrf/Pictures/Wallpapers/catppuccin-astro-macchiato/background.png"
       #"polybar example"
       #"plank"
      ];

      settings = {

        border_width = 4;
        window_gap = 8;
        left_padding = 0;
        right_padding = 0;
        top_padding = 0;
        bottom_padding = 0;

        split_ratio = 0.5;
        single_monocle = false;
        focus_follows_pointer = true;
        borderless_monocle = true;
        gapless_monocle = true;

      };

     #rules = {
     #  Plank = {
     #    layer = "above";
     #  };
     #};

     #rules = {
     #  "<name>" = {
     #    sticky = ;
     #    state = ;
     #    splitRatio = ;
     #    splitDir = ;
     #    rectangle = ;
     #    private = ;
     #    node = ;
     #    monitor = ;
     #    marked = ;
     #    manage = ;
     #    locked = ;
     #    layer = ;
     #    hidden = ;
     #    follow = ;
     #    focus = ;
     #    desktop = ;
     #    center = ;
     #    border = ;
     #  };
     #  "Gimp" = {
     #    desktop = "^8";
     #    state = "floating";
     #    follow = true;
     #  };
     #};

    };

    home.packages = [

      pkgs.sxhkd
      pkgs.plank
      pkgs.dockbarx
     #pkgs.xorg.xdpyinfo
      mypkgs.stable.tint2
      pkgs.bc
      pkgs.conky

      pkgs.xdo
      pkgs.xbacklight
      pkgs.xkblayout-state
      pkgs.skippy-xd

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
      bsp-gaps
      bsp-tag-view
      bsp-tag-view-revert
      bsp-tag-view-rofi
      bsp-restore-cached-layout
      bsp-cache-layout
      bsp-zoom
      bsp-zoom-second_biggest
      scratchpad
      bsp-cmaster-layout
      bsp-send-follow
      bsp-border-color
      bsp-border-size
      bsp-border-toggle
      bsp-gaps-toggle
      pkgs.bsp-layout

     #(pkgs.bsp-layout.overrideAttrs (old: {
     #  myLayouts = ./layouts;   # your extra *.sh files
     #  postInstall = old.postInstall or "" + ''
     #    cp -v $myLayouts/*.sh $out/lib/bsp-layout/layouts/
     #    chmod 755 $out/lib/bsp-layout/layouts/*.sh
     #    for f in $out/lib/bsp-layout/layouts/*.sh; do
     #      substituteInPlace "$f" --replace 'bc ' '${pkgs.bc}/bin/bc '
     #    done
     #  '';
     #}))
    ];

   #systemd.user.services.plank-bspwm = {
   #  Unit = {
   #    Description = "Plank for BSPWM";
   #    After = "xdg-desktop-autostart.target";
   #   #BindsTo = "xdg-desktop-autostart.target";
   #    PartOf = [ "tray.target" ];
   #  };
   #
   #  Service = {
   #    ExecStart = "${bsp-plank}/bin/bsp-plank";
   #    Restart = "on-failure";
   #   #ExecCondition = "${bsp-plank}/bin/bsp-plank";
   #  };
   #
   #  Install = {
   #    WantedBy = [ "tray.target" ];
   #  };
   #};

  };

}
