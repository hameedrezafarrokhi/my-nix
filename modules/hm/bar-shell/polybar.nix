{ config, pkgs, lib, inputs, nix-path, ... }:

let

  poly-idle-inhibit = pkgs.writeShellScriptBin "poly-idle-inhibit" ''
    CURRENT_TIMEOUT=$(xset q | awk '/timeout:/ {print $2}')

    if [ "$1" = "--status" ]; then
        if [ "$CURRENT_TIMEOUT" -eq 0 ]; then
            echo ""
        else
            echo ""
        fi
        exit 0
    fi

    # Toggle based on state
    if [ "$CURRENT_TIMEOUT" -eq 0 ]; then
        # Re-enable idle (default X timeout)
        xset s on
        xset s blank
        xset s 600 600
        xset +dpms
        systemctl --user restart xautolock-session.service
        systemctl --user restart xss-lock.service
    else
        # Disable idle
        xset s off
        xset s noblank
        xset s 0 0
        xset -dpms
        pkill .xscreensaver-w
        pkill xscreensaver-sy
        pkill .xscreensaver-s
        systemctl --user stop xautolock-session.service
        systemctl --user stop xss-lock.service
    fi
  '';

  poly-notif = pkgs.writeShellScriptBin "poly-notif" ''
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
    dunstctl history-pop
  '';

  poly-power = pkgs.writeShellScriptBin "poly-power" ''
    ROFI_THEME="${nix-path}/modules/hm/desktops/awesome/awesome/rofi/power.rasi"

    chosen=$(echo -e "[Cancel]\nLock\nLogout\nShutdown\nReboot" | \
        rofi -dmenu -i -p "Power Menu" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

    case "$chosen" in
        "Lock") ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a -p default  ;;
        "Logout")
          bspc quit
          pkill dwm
          pkill dwm
          openbox --exit
          i3-msg exit  ;;
        "Shutdown") systemctl poweroff ;;
        "Reboot") systemctl reboot ;;
        *) exit 0 ;; # Exit on cancel or invalid input
    esac
  '';

  poly-reset = pkgs.writeShellScriptBin "poly-reset" ''
    bspc wm -r
    openbox --restart
    i3-msg restart
  '';

in

{ config = lib.mkIf (builtins.elem "polybar" config.my.bar-shell.shells) {

  home.packages = [ poly-idle-inhibit poly-notif poly-power poly-reset ];

  services.polybar = {

    enable = true;
    package = pkgs.polybarFull;

   #config = {};  # For path usage, otherwise use "settings"
   #extraConfig = '' '';

    script = "polybar example &";  # Script to run polybar like "polybar bar &"

    settings = {

      "bar/example" = {
        width = "100%";
        height = "18pt";
        radius = 6;
       #dpi = 96;
        modules = {
          left = "apps memory cpu filesystem networkspeeddown networkspeedup xwindow";
          center = "xworkspaces";
          right = "lock tray bspwm notif idle keyboard-layout pulseaudio date hour power";
        };
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
        enable-ipc = true;
       #tray-position = "right";
       #wm-restack = "generic";
       #wm-restack = "bspwm";
       #wm-restack = :i3";
       #override-redirect = true;
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        label-active = "%name%";
        label-active-padding = 1;
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-urgent = "%name%";
        label-urgent-padding = 1;
        label-empty = "";
        label-empty-padding = 0;
        label-font = 3;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:75:...%";
        format-prefix = ''"󰖯 "'';
        label-maxlen = 30;
      };

      "module/filesystem" = {
        format-mounted = "<label-mounted>%{O-8pt}";
        type = "internal/fs";
        interval = 120;
        mount-0 = "/";
        format-mounted-prefix = '' %{O-4pt}'';
        label-mounted = "%percentage_free%%";
        label-unmounted = "%mountpoint% not mounted";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume-prefix = ''"󰜟 "'';
        format-volume = "<label-volume>%{O-5pt}";
        label-volume = "%percentage%%";
        label-muted = "muted";
        click-right = "pavucontrol";
       #double-click-left = "resources";
       #double-click-middle = ;
        double-click-right = "baobab";
      };

      "module/lock" = {
        type = "internal/xkeyboard";
       #ignore = ;
        format-margin = 1;
        blacklist-1 = "num lock";
        blacklist-0 = "scroll lock";
        format = "<label-indicator>";
        label-indicator-padding = 1;
        indicator-icon-0 = "caps lock;-CL;+CL";
        label-indicator-off = "";
        label-indicator-on = ''" Caps "'';
      };

      "module/xkb" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";
        blacklist-1 = "scroll lock";
        blacklist-2 = "caps lock";
        format = "<label-layout>";
        format-spacing = 0;
        label-layout = "%name%";
       #label-layout-padding = 0;
       #label-layout-background = ;
       #label-layout-foreground = ;
       #label-indicator = "%name%";
        layout-icon-0 = "us";
        layout-icon-1 = "ir";
      };

      "module/keyboard-layout" = {
        type = "custom/script";
        exec = "xkb-switch -p";
       #interval = 2;
        click-left = "xkb-switch -n";
        double-click-left = "iotas";
        click-right = "onboard";
        double-click-right = "pkill onboard";
        format = "<label>%{O-8pt}";
      };

      "module/memory" = {
        format = "<label>%{O-8pt}";
        type = "internal/memory";
        interval = 2;
        format-prefix = '' %{O-5pt}'';
        label = "%percentage_used:2%%";
      };

      "module/cpu" = {
        format = "<label>%{O-7pt}";
        type = "internal/cpu";
        interval = 02;
        format-prefix = '' %{O-6pt}'';
        label = "%percentage:2%%";
      };

     #"network-base" = {
     #  type = "internal/network";
     #  interval = 5;
     #  format-connected = "<label-connected>";
     #  format-disconnected = "<label-disconnected>";
     #};

     #"module/wlan" = {
     #  "inherit" = "network-base";
     #  interface-type = "wireless";
     #};

     #"module/eth" = {
     #  "inherit" = "network-base";
     #  interface-type = "wired";
     #};

      "module/hour" = {
       #format = "<lable>%{O-4pt}";
        type = "internal/date";
        interval = 5;
        date = "%l:%M %p";
        label = "%date%";
        label-padding = 1;
        label-font = 1;
        format-prefix = ''"󰥔"'';
      };

      "module/date" = {
        type = "custom/script";
        interval = 60;
        format = "<label>%{O-8pt}";
        exec = ''"LC_TIME="en_us_utf8" date +"%a-%-d""'';
        label-padding = 0;
        label-font = 1;
        format-prefix = ''" "'';
        click-left = "gnome-calendar";
        click-right = "gnome-clocks";
        double-click-left = "timeswitch";
       #double-click-middle = ;
        double-click-right = "kalarm";
      };

      "module/tray" = {
        type = "internal/tray";
        tray-spacing = "4px";
      };

      "module/apps" = {
        type = "custom/script";
        format = "<label>%{O-8pt}";
        exec = ''"echo '' $(uname -n) | sed 's/^\(..\)\(.\)/\1\u\2/'"'';
       #interval = 60;
        click-left = "rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme ${nix-path}/modules/hm/desktops/awesome/awesome/rofi/config.rasi -location 1 -yoffset 42 -xoffset 8";
        click-right = "dolphin";
        double-click-left = "kate";
       #double-click-middle = ;
        double-click-right = "kitty";
      };

      "module/idle" = {
        type = "custom/script";
        exec = "poly-idle-inhibit --status";
        interval = 2;
        click-left = "poly-idle-inhibit";
        format = "<label>%{O-8pt}";
       #lable = "%output%";
       #label-on = "";
       #label-off = "";
      };

      "module/notif" = {
        type = "custom/script";
        exec = "echo ''";
        format = "<label>%{O-5pt}";
        click-left = "dunstctl history-pop";
        click-right = "poly-notif";
        double-click-left = "dunstctl close-all";
        double-click-right = "dunstctl history-clear";
      };

      "module/power" = {
        type = "custom/script";
        exec = "echo '⏻'";
        format = "%{O-11pt}<label>%{O-2pt}";
        click-left = "poly-power";
        click-right = "poly-reset";
        double-click-left = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10  -n -c 24273a -p default";
        double-click-right = "resources";
      };

      "module/bspwm" = {
        type = "custom/script";
        exec = "bsp-layout-manager";
        format = "<label>%{O-5pt}";
        click-left = "bsp-layout next";
        click-right = "bsp-layout previous";
        double-click-left = "bsp-layout reload";
        double-click-right = "bsp-layout remove";
      };

      "module/networkspeedup" = {
        type = "internal/network";
        interface = "wlp3s0";
        unknown-as-up = true;
        interval = 2.0;
        label-connected = ''"%upspeed:4%%{O-5pt}"'';
        format-connected = "<label-connected>%{O-5pt}";
        format-connected-prefix = ''""'';
        speed-unit = '''';
      };

      "module/networkspeeddown" = {
        type = "internal/network";
        interface = "wlp3s0";
        unknown-as-up = true;
        interval = 2.0;
        label-connected = ''"%downspeed:4%%{O-8pt}"'';
        format-connected = "<label-connected>%{O-2pt}";
        format-connected-prefix = ''""'';
        speed-unit = '''';
      };

      "settings" = {
       #screenchange-reload = true;
       #pseudo-transparency = true ;
      };

    };

  };

  systemd.user.services.polybar = {
   #enable = {
   # enable = false;
   #};
    Unit = {
     #Description = "Polybar status bar";
     #PartOf = [ "tray.target" ];
     #X-Restart-Triggers = mkIf (configFile != null) "${configFile}";
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=none";
    };
   #Service = {
   #  Type = "forking";
   #  Environment = [ "PATH=${cfg.package}/bin:/run/wrappers/bin" ];
   #  ExecStart =
   #    let
   #      scriptPkg = pkgs.writeShellScriptBin "polybar-start" cfg.script;
   #    in
   #    "${scriptPkg}/bin/polybar-start";
   #  Restart = "on-failure";
   #};
   #
   #Install = {
   #  WantedBy = [ "tray.target" ];
   #};
  };

  xdg.configFile = {

    polybar-themes-blocks = {
      source = "${inputs.polybar-themes}/bitmap/blocks";
      target = "polybar/blocks";
    };
    polybar-themes-colorblocks = {
      source = "${inputs.polybar-themes}/bitmap/colorblocks";
      target = "polybar/colorblocks";
    };
    polybar-themes-cuts = {
      source = "${inputs.polybar-themes}/bitmap/cuts";
      target = "polybar/cuts";
    };
    polybar-themes-docky = {
      source = "${inputs.polybar-themes}/bitmap/docky";
      target = "polybar/docky";
    };
    polybar-themes-forest = {
      source = "${inputs.polybar-themes}/bitmap/forest";
      target = "polybar/forest";
    };
    polybar-themes-grayblocks = {
      source = "${inputs.polybar-themes}/bitmap/grayblocks";
      target = "polybar/grayblocks";
    };
    polybar-themes-hack = {
      source = "${inputs.polybar-themes}/bitmap/hack";
      target = "polybar/hack";
    };
    polybar-themes-material = {
      source = "${inputs.polybar-themes}/bitmap/material";
      target = "polybar/material";
    };
    polybar-themes-shades = {
      source = "${inputs.polybar-themes}/bitmap/shades";
      target = "polybar/shades";
    };
    polybar-themes-shapes = {
      source = "${inputs.polybar-themes}/bitmap/shapes";
      target = "polybar/shapes";
    };
    polybar-themes-launch = {
      source = "${inputs.polybar-themes}/bitmap/launch.sh";
      target = "polybar/launch.sh";
    };

  };

  home.file = {

   #polybar-collection = {
   #
   #  source = "${inputs.polybar-collection}/";
   #  target = "polybar-collection/";
   #  recursive = true;
   #
   #};

  };

};}
