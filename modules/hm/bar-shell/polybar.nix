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
        xset s blank
        xset s on
        xset s $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) ${toString config.services.screen-locker.xss-lock.screensaverCycle}
        xset +dpms
        #xset dpms 1800 3600 6000      # Standby: 30    Suspend: 40    Off: 90
        #xset dpms 2100 2400 2700
        #xset dpms 6000 6000 6000
        xset dpms $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) $(( ${toString config.services.screen-locker.inactiveInterval} * 60 )) $(( ${toString config.services.screen-locker.inactiveInterval} * 60 ))
        systemctl --user restart xautolock-session.service
        systemctl --user restart xss-lock.service
    else
        # Disable idle
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
    ROFI_THEME="$HOME/.config/rofi/themes/power.rasi"

    chosen=$(echo -e "[Cancel]\n󰑓 Reload\n Lock\n󰍃 Logout\n󰒲 Sleep\n󰤆 Shutdown\n󱄋 Reboot" | \
        rofi -dmenu -i -p "Power Menu" -line-padding 4 -hide-scrollbar -theme "$ROFI_THEME")

    case "$chosen" in
        " Lock") ${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10 -n -c 24273a -p default  ;;
        "󰑓 Reload") poly-reset  ;;
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

  poly-reset = pkgs.writeShellScriptBin "poly-reset" ''
    bspc wm -r
    openbox --restart
    i3-msg restart
  '';

  bsp-next = pkgs.writeShellScriptBin "bsp-next" ''
    bsp-layout next
    notify-send -e -u low -t 2000 "$(bsp-layout get)"
  '';
  bsp-prev = pkgs.writeShellScriptBin "bsp-prev" ''
    bsp-layout previous
    notify-send -e -u low -t 2000 "$(bsp-layout get)"
  '';
  bsp-reload = pkgs.writeShellScriptBin "bsp-reload" ''
    bsp-layout reload
    notify-send -e -u low -t 2000 "$(bsp-layout get)"
  '';
  bsp-og = pkgs.writeShellScriptBin "bsp-og" ''
    bsp-layout remove
    notify-send -e -u low -t 2000 "BSPWM Layout"
  '';

  poly-xkb-layout = pkgs.writeShellScriptBin "poly-xkb-layout" ''
    xkblayout-state print "%s"
  '';
  poly-xkb-change = pkgs.writeShellScriptBin "poly-xkb-change" ''
    xkb-switch -n
    notify-send -e -u low -t 2000 "$(poly-xkb-layout)"
  '';

  poly-picom-status = pkgs.writeShellScriptBin "poly-picom-status" ''
    if systemctl --user is-active --quiet picom.service; then
        echo "󰏣"
    else
        echo ""
    fi
  '';
  poly-picom-toggle = pkgs.writeShellScriptBin "poly-picom-toggle" ''
    if systemctl --user is-active --quiet picom.service; then
        systemctl --user stop picom.service
    else
        systemctl --user restart picom.service
    fi
  '';

  poly-bsp-float = pkgs.writeShellScriptBin "poly-bsp-float" ''
    bspc query -N -d focused | while read -r n; do s=$(bspc query -T -n "$n" | grep -q '"state":"floating"' && echo tiled || echo floating); bspc node "$n" -t "$s"; done
    notify-send -e -u low -t 2000 "Floating Toggle"
  '';

  poly-player = pkgs.writeShellScriptBin "poly-player" ''
    echo ""
    playerctl metadata -f '{{status}} {{title}}' -F 2>/dev/null | while read event; do
    out=$(playerctl metadata -f '{{status}} {{title}}' 2>/dev/null)
      if [[ -z $out ]]; then
        echo ""
      else
        echo $out | sed 's/Paused//; s/Playing//; s/Stopped//;'
      fi
    done
  '';

  poly-pp = pkgs.writeShellScriptBin "poly-pp" ''
    CURRENT_PROFILE=$(powerprofilesctl get)

    if [ "$1" = "--status" ]; then
        if [ "$CURRENT_PROFILE" = "performance" ]; then
            echo "󰑣"  # Performance icon
        elif [ "$CURRENT_PROFILE" = "power-saver" ]; then
            echo ""  # Power Saver icon
        else
            echo ""  # Balanced icon
        fi
        exit 0
    fi

    # Toggle between the profiles on click
    if [ "$CURRENT_PROFILE" = "performance" ]; then
        # Switch to Power Saver mode
        powerprofilesctl set power-saver
        echo "Switched to Power Saver mode."
        notify-send -e -u critical -t 3000 "Power-Saver Mode"
    elif [ "$CURRENT_PROFILE" = "power-saver" ]; then
        # Switch to Balanced mode
        powerprofilesctl set balanced
        echo "Switched to Balanced mode."
        notify-send -e -u critical -t 3000 "Balanced Mode"
    else
        # Switch to Performance mode
        powerprofilesctl set performance
        echo "Switched to Performance mode."
        notify-send -e -u critical -t 3000 "Performance Mode"
    fi
  '';

  poly-color-picker = pkgs.writeShellScriptBin "poly-color-picker" ''
    sh -c 'color=$(xcolor); printf "%s" "$color" | xclip -selection clipboard; notify-send -t 0 "Color" "$color" -h string:bgcolor:"$color" -h string:fgcolor:"#fff"'
  '';

  poly-magnifier = pkgs.writeShellScriptBin "poly-magnifier" ''
    magnify -wexpr 1920 / 4 -hexpr 1080 / 4 -m4 -r30
  '';

  poly-dnd = pkgs.writeShellScriptBin "poly-dnd" ''
    ICON_DND=""    # DND icon (font-awesome)
    ICON_BELL=""   # Bell icon
    WAITING=$(dunstctl count waiting)

    if [ "$WAITING" -ne 0 ]; then
        echo "$ICON_DND $WAITING"
        exit 0
    fi

    if dunstctl is-paused | grep -q true; then
        echo "$ICON_DND"
    else
        echo "$ICON_BELL"
    fi
  '';

  poly-modules = pkgs.writeShellScriptBin "poly-modules" ''
    ${builtins.readFile ./poly-modules}
  '';

  poly-modules-rofi = pkgs.writeShellScriptBin "poly-modules-rofi" ''
    MODULE_FILE="$HOME/.polybar_modules"

    if [ ! -f "$MODULE_FILE" ]; then
        echo "No modules configured" | rofi -dmenu -p "Polybar" -l 1 -theme $HOME/.config/rofi/themes/main.rasi
        exit 0
    fi

    MENU_ITEMS=$(grep "action" "$MODULE_FILE" | while read -r line; do
        module=$(echo "$line" | sed -E 's/.*action ([^ ]+).*/\1/')
        if echo "$line" | grep -q "hide"; then
            echo "❌0 $module"
        else
            echo "✔️ $module"
        fi
    done | sort -u)

    if [ -z "$MENU_ITEMS" ]; then
        echo "No modules found" | rofi -dmenu -p "Polybar" -l 1 -theme $HOME/.config/rofi/themes/main.rasi
        exit 0
    fi

    SELECTED=$(echo "$MENU_ITEMS" | rofi -dmenu -p "Toggle module" -i -theme $HOME/.config/rofi/themes/main.rasi)

    # Remove "(Hidden)" or "(Shown)" from the selected item
    SELECTED_CLEANED=$(echo "$SELECTED" | sed 's/❌0 //; s/✔️ //')

    [[ -n "$SELECTED_CLEANED" ]] && poly-modules "$SELECTED_CLEANED"
  '';

in

{ options.my.poly-height = lib.mkOption { type = lib.types.str; };
  options.my.poly-name   = lib.mkOption { type = lib.types.str; };

  config = lib.mkIf (builtins.elem "polybar" config.my.bar-shell.shells) {

  home.packages = [
    poly-idle-inhibit
    poly-notif
    poly-power
    poly-reset
    bsp-next
    bsp-prev
    bsp-reload
    bsp-og
    poly-bsp-float
    poly-xkb-layout
    poly-xkb-change
    poly-picom-status
    poly-picom-toggle
    poly-player
    poly-pp
    poly-color-picker
    poly-magnifier
    poly-dnd
    poly-modules
    poly-modules-rofi
  ];

  my.poly-height = "18";
  my.poly-name = "example";

  services.polybar = {

    enable = true;
    package = pkgs.polybarFull;

   #config = {};  # For path usage, otherwise use "settings"
   #extraConfig = '' '';

   #script = "polybar example &";  # Script to run polybar like "polybar bar &"

    script = ''
      polybar example &
      $HOME/.polybar_modules
    '';

    settings = {

      "bar/${config.my.poly-name}" = {
        width = "100%";
        height = "${config.my.poly-height}pt";
        radius = 6;
       #dpi = 96;
        modules = {
          left = "apps pp memory cpu filesystem networkspeeddown networkspeedup networkspeeddown-wired networkspeedup-wired player xwindow";
          center = "xworkspaces";
          right = "lock tray picom bspwm notif idle keyboard-layout pulseaudio date hour power";
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
        group-by-monitor = false;
        pin-workspaces = false;
        enable-click = true;
        enable-scroll = true;
        reverse-scroll = false;
       #icon-0 = "code;♚";
       #icon-1 = "office;♛";
       #icon-2 = "graphics;♜";
       #icon-3 = "mail;♝";
       #icon-4 = "web;♞";
       #icon-default = "♟";
        label-active = "%{O-2pt}%index%: %{O-4pt}%name%%{O-2pt}";
        label-active-padding = 1;
        label-occupied = "%{O-2pt}%index%: %{O-4pt}%name%%{O-2pt}";
        label-occupied-padding = 1;
        label-urgent = "%{O-2pt}%index%: %{O-4pt}%name%%{O-2pt}";
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
        label-mounted = "%{T3}%percentage_free%%%{T-}";
        label-unmounted = "%mountpoint% not mounted";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume-prefix = ''"󰜟 "'';
        format-volume = "<label-volume>%{O-8pt}";
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
       #label-indicator-on = ''" Caps "'';
        label-indicator-on = ''"󰘲"'';
      };

      "module/xkb" = {
        type = "internal/xkeyboard";
        blacklist-0 = "num lock";
        blacklist-1 = "scroll lock";
        blacklist-2 = "caps lock";
        format = "<label-layout>";
        format-spacing = 0;
       #tail = true;
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
        interval = 2;
        click-left = "poly-xkb-change";
        double-click-left = "iotas";
        click-right = "onboard";
        double-click-right = "sxcs --mag-filters 'circle'";
        click-middle = "poly-color-picker";
        double-click-middle = "poly-magnifier";
        format = "<label>%{O-8pt}";
      };

      "module/memory" = {
        format = "<label>%{O-8pt}";
        type = "internal/memory";
        interval = 2;
        format-prefix = '' %{O-5pt}'';
        label = "%{T3}%percentage_used:2%%%{T-}";
      };

      "module/cpu" = {
        format = "<label>%{O-7pt}";
        type = "internal/cpu";
        interval = 02;
        format-prefix = '' %{O-6pt}'';
        label = "%{T3}%percentage:2%%%{T-}";
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
       #interval = 5;
        interval = 1.0;
        date = "%l:%M:%S";
       #date = "%l:%M %p";
       #date = "%a-%d %l:%M %p";
        label = "%date%";
        label-padding = 1;
        label-font = 1;
        format-prefix = ''"󰥔%{O-5pt}"'';
      };

      "module/date" = {
        type = "custom/script";
        interval = 60;
        format = "<label>%{O-8pt}";
        exec = ''"LC_TIME="en_us_utf8" date +"%a-%d""'';
        label-padding = 0;
        label-font = 1;
        format-prefix = ''" "'';
        click-left = "gnome-calendar";
        click-right = "gnome-clocks";
       #double-click-middle = ;
       #double-click-left = "timeswitch";
        double-click-right = "kalarm";
      };

      "module/tray" = {
        type = "internal/tray";
        tray-spacing = "5px";
        format = "<tray>%{O-6pt}";
        tray-size = "66%";
      };

      # ''"echo ' ' $(uname -n) | sed 's/^\(..\)\(.\)/\1\u\2/'"''
      "module/apps" = {
        type = "custom/script";
        format = "<label>%{O-10pt}";
        exec = ''"echo ' '"'';
       #interval = 60;
        click-left = "jgmenu_run";
       #click-left = "rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons -theme $HOME/.config/rofi/themes/main.rasi -location 1 -yoffset 42 -xoffset 8";
        click-right = "bsp-hidden-menu";
        double-click-left = "skippy-xd --paging";
        click-middle = "ulauncher";
       #double-click-middle = "kate";
        double-click-middle = "skippy-xd --toggle";
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
        exec = "poly-dnd";
        interval = 2;
       #exec = "echo ''";
        format = "<label>%{O-8pt}";
        click-left = "dunstctl history-pop";
        click-right = "poly-notif";
        double-click-left = "dunstctl close-all";
        double-click-right = "dunstctl history-clear";
        click-middle = "dunstctl set-paused toggle";
      };

      "module/power" = {
        type = "custom/script";
        exec = "echo '⏻'";
        format = "%{O-11pt}<label>%{O-2pt}";
        click-left = "poly-power";
        click-right = "gnome-clocks";
        double-click-left = "timeswitch";
       #double-click-right = "resources";
        double-click-right = "poly-modules-rofi";
        double-click-middle = "kalarm";
        click-middle = "gnome-calendar";
      };

      "module/bspwm" = {
        type = "custom/script";
        exec = "bsp-layout-manager";
        format = "<label>%{O-8pt}";
       #tail = true;
        interval = 2;
        click-left = "bsp-next";
        click-right = "bsp-prev";
        click-middle = "poly-bsp-float";
        double-click-left = "bsp-reload";
        double-click-right = "bsp-og";
      };

      "module/networkspeedup" = {
        type = "internal/network";
        interface-type = "wireless";
       #interface = "wlp3s0";
        unknown-as-up = true;
        interval = 2.0;
        label-connected = ''"%upspeed:4%%{O-5pt}"'';
        format-connected = "%{T3}<label-connected>%{O-5pt}%{T-}";
        format-connected-prefix = ''""'';
        speed-unit = '''';
      };

      "module/networkspeeddown" = {
        type = "internal/network";
        interface-type = "wireless";
       #interface = "wlp3s0";
        unknown-as-up = true;
        interval = 2.0;
        label-connected = ''"%downspeed:4%%{O-8pt}"'';
        format-connected = "%{T3}<label-connected>%{O-2pt}%{T-}";
        format-connected-prefix = ''""'';
        speed-unit = '''';
      };

      "module/networkspeedup-wired" = {
        type = "internal/network";
        interface-type = "wired";
       #interface = "wlp3s0";
        unknown-as-up = true;
        interval = 2.0;
        label-connected = ''"%upspeed:4%%{O-5pt}"'';
        format-connected = "<label-connected>%{O-5pt}";
        format-connected-prefix = ''""'';
        speed-unit = '''';
      };

      "module/networkspeeddown-wired" = {
        type = "internal/network";
        interface-type = "wired";
       #interface = "wlp3s0";
        unknown-as-up = true;
        interval = 2.0;
        label-connected = ''"%downspeed:4%%{O-8pt}"'';
        format-connected = "<label-connected>%{O-2pt}";
        format-connected-prefix = ''""'';
        speed-unit = '''';
      };

      "module/picom" = {
        type = "custom/script";
        exec = "poly-picom-status";
        interval = 2;
       #tail = true;
        click-left = "poly-picom-toggle";
        format = "<label>%{O-8pt}";
        label = "%output%";
      };

      "module/player" = {
        type = "custom/script";
        tail = true;
        exec = "poly-player";
        label = "%output:0:20:...%";
       #label-padding = ${widths.large}
        format = "<label>";
       #format-font = 1;
       #format-background = ${colors.shade1}
       #format-prefix = ﱘ
       #format-prefix-font = 2
       #format-prefix-padding = ${widths.large}
        click-left = "playerctl play-pause";
        double-click-left = "playerctl next";
        click-right = "playerctl loop";
        double-click-right = "playerctl previous";
        click-middle = "playerctl stop";
       #double-click-middle = "playerctl ";
        scroll-up = "playerctl position 5+";
        scroll-down = "playerctl position 5-";
        label-maxlen = 25;
        format-prefix = ''"󰝚 "'';
      };

      "module/pp" = {
        type = "custom/script";
        exec = "poly-pp --status";
        interval = 2;
       #tail = true;
        click-left = "poly-pp";
        format = "<label>%{O-6pt}";
       #lable = "%output%";
       #label-on = "";
       #label-off = "";
      };

      "settings" = {
        screenchange-reload = true;
       #pseudo-transparency = true;
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

   #polybar-themes-blocks = {
   #  source = "${inputs.polybar-themes}/bitmap/blocks";
   #  target = "polybar/blocks";
   #};
   #polybar-themes-colorblocks = {
   #  source = "${inputs.polybar-themes}/bitmap/colorblocks";
   #  target = "polybar/colorblocks";
   #};
   #polybar-themes-cuts = {
   #  source = "${inputs.polybar-themes}/bitmap/cuts";
   #  target = "polybar/cuts";
   #};
   #polybar-themes-docky = {
   #  source = "${inputs.polybar-themes}/bitmap/docky";
   #  target = "polybar/docky";
   #};
   #polybar-themes-forest = {
   #  source = "${inputs.polybar-themes}/bitmap/forest";
   #  target = "polybar/forest";
   #};
   #polybar-themes-grayblocks = {
   #  source = "${inputs.polybar-themes}/bitmap/grayblocks";
   #  target = "polybar/grayblocks";
   #};
   #polybar-themes-hack = {
   #  source = "${inputs.polybar-themes}/bitmap/hack";
   #  target = "polybar/hack";
   #};
   #polybar-themes-material = {
   #  source = "${inputs.polybar-themes}/bitmap/material";
   #  target = "polybar/material";
   #};
   #polybar-themes-shades = {
   #  source = "${inputs.polybar-themes}/bitmap/shades";
   #  target = "polybar/shades";
   #};
   #polybar-themes-shapes = {
   #  source = "${inputs.polybar-themes}/bitmap/shapes";
   #  target = "polybar/shapes";
   #};
   #polybar-themes-launch = {
   #  source = "${inputs.polybar-themes}/bitmap/launch.sh";
   #  target = "polybar/launch.sh";
   #};

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
