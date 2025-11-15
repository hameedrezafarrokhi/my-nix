{ config, pkgs, lib, nix-path, nix-path-alt, ... }:

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

        if hash sxhkd >/dev/null 2>&1; then
        	  pkill sxhkd
        	  sleep 1.5
        	  sxhkd -c "${nix-path}/modules/hm/desktops/bspwm/sxhkdrc" &
        fi

        if hash polybar >/dev/null 2>&1; then
        	  pkill polybar
        	  sleep 1.5
        	  polybar example &
        fi

        if hash conky >/dev/null 2>&1; then
        	  pkill conky
        	  sleep 1.5
        	  conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
        fi

        if hash plank >/dev/null 2>&1; then
        	  pkill plank
        	  sleep 1.5
        	  plank &
        fi

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

        split_ratio = 0.5;
        single_monocle = false;
        focus_follows_pointer = true;
        borderless_monocle = true;
        gapless_monocle = true;

      };

      rules = {
        Plank = {
          layer = "above";
        };
      };

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
      pkgs.bc
      pkgs.bsp-layout
      pkgs.conky
      bsp-plank-reset
      bsp-help
      bsp-volume
      bsp-layout-manager
      bsp-xkb-layout
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
