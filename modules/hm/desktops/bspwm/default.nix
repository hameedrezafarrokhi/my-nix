{ config, pkgs, lib, nix-path, nix-path-alt, mypkgs, ... }:

let

  cfg = config.my.bspwm;

 #bsp-tabbed = pkgs.callPackage ./tabbed/bsp-tabbed.nix { };
 #bsptab = pkgs.callPackage ./tabbed/bsptab.nix { tabbed = bsp-tabbed; };
 #
  bsp-layout-ext = pkgs.callPackage ./bsp-layout-ext/bsp-layout-ext.nix { };
  bsp-layout = pkgs.callPackage ./bsp-layout/bsp-layout.nix { };

in

{

  options.my.bspwm.enable = lib.mkEnableOption "bspwm";

  imports = [

    ./bsp-scripts.nix

  ];

  config = lib.mkIf cfg.enable {

    xsession.windowManager.bspwm = {

      enable = true;
      package = pkgs.bspwm;
      alwaysResetDesktops = true;

     #monitors = { };

      # bspc monitor -d 1 2 3 4 5 6 7 8 9 10
      extraConfigEarly = ''

        #export XDG_CURRENT_DESKTOP=BSPWM &
        #export desktop=BSPWM &
        #dbus-update-activation-environment --systemd --all
        #dbus-update-activation-environment --systemd XDG_CURRENT_DESKTOP=bspwm
        #systemctl --user import-environment

        #bspc monitor -d 1 2 3 4 5 6 7 8 9 10

        INTERNAL_MONITOR="${config.my.display.primary.name}"
        EXTERNAL_MONITOR="${config.my.display.external.name}"

        # on first load setup default workspaces
        if [[ "$1" = 0 ]]; then
          if [[ $(xrandr -q | grep "${config.my.display.external.name} connected") ]]; then
            bspc monitor "$INTERNAL_MONITOR" -d 1 2 3 4 5
            bspc monitor "$EXTERNAL_MONITOR" -d 6 7 8 9 10
            bspc wm -O "$INTERNAL_MONITOR" "$EXTERNAL_MONITOR"
            systemctl --user start bsppoly-2.service &
          else
            bspc monitor -d 1 2 3 4 5 6 7 8 9 10
            systemctl --user stop bsppoly-2.service &
          fi
        fi

        monitor_add() {
          # Move first 5 desktops to external monitor
          for desktop in $(bspc query -D --names -m "$INTERNAL_MONITOR" | sed 5q); do
            bspc desktop "$desktop" --to-monitor "$EXTERNAL_MONITOR"
          done

          # Remove default desktop created by bspwm
          bspc desktop Desktop --remove

          # reorder monitors
          bspc wm -O "$INTERNAL_MONITOR" "$EXTERNAL_MONITOR"

          systemctl --user restart bsppoly-2.service &
        }

        monitor_remove() {
          # Add default temp desktop because a minimum of one desktop is required per monitor
          bspc monitor "$EXTERNAL_MONITOR" -a Desktop

          # Move all desktops except the last default desktop to internal monitor
          for desktop in $(bspc query -D -m "$EXTERNAL_MONITOR");	do
            bspc desktop "$desktop" --to-monitor "$INTERNAL_MONITOR"
          done

          # delete default desktops
          bspc desktop Desktop --remove

          # reorder desktops
          bspc monitor "$INTERNAL_MONITOR" -o 1 2 3 4 5 6 7 8 9 10

          systemctl --user stop bsppoly-2.service &
        }

        if [[ $(xrandr -q | grep "${config.my.display.external.name} connected") ]]; then
          # set xrandr rules for docked setup
          xrandr --output "$INTERNAL_MONITOR" --mode ${config.my.display.primary.x}x${config.my.display.primary.y} --pos 0x0 --rotate normal --output "$EXTERNAL_MONITOR" --primary --mode ${config.my.display.external.x}x${config.my.display.external.y} --pos ${config.my.display.primary.x}x0 --rotate normal
          if [[ $(bspc query -D -m "${config.my.display.external.name}" | wc -l) -ne 5 ]]; then
            monitor_add
          fi
          bspc wm -O "$EXTERNAL_MONITOR" "$INTERNAL_MONITOR"
        else
          # set xrandr rules for mobile setup
          xrandr --output "$INTERNAL_MONITOR" --primary --mode ${config.my.display.primary.x}x${config.my.display.primary.y} --pos 0x0 --rotate normal --output "$EXTERNAL_MONITOR" --off
          if [[ $(bspc query -D -m "${config.my.display.primary.name}" | wc -l) -ne 10 ]]; then
            monitor_remove
          fi
        fi

      '';

      # killall -q polybar
      # polybar -c ~/.config/bspwm/polybar/config.ini &
      extraConfig = ''

        rm -f "$HOME/.cache/bsp"* 2>/dev/null

        if hash sxhkd >/dev/null 2>&1; then
        	  pkill sxhkd
        	  sleep 0.5
        	  sxhkd -c "${nix-path}/modules/hm/desktops/bspwm/sxhkdrc" &
        fi

        systemctl --user restart bsppoly.service &
        systemctl --user restart bsptint.service &
        bsp-touchegg &

        pw-play "$HOME/.local/share/desktop-sounds/startup"

        if [ -f "$HOME/.bsp_conf" ]; then
            "$HOME/.bsp_conf"
        fi
        if [ -f "$HOME/.bsp_conf_color" ]; then
            "$HOME/.bsp_conf_color"
        fi
        if [ -f "$HOME/.config/bspwm/bsp-power-state" ]; then
            bsp-power-man $(cat $HOME/.config/bspwm/bsp-power-state)
        else
            bsp-power-man manual
        fi

        bspc rule -a Tilda state=floating # rectangle=0x0+0+0
        bspc rule -a ulauncher border=off
        bspc rule -a Ulauncher border=off
        bspc rule -a scratchpad state=floating layer=normal
        bspc rule -a ".blueman-manager-wrapped" state=floating
        bspc rule -a pavucontrol state=floating
        bspc rule -a copyq state=floating
        bspc rule -a ".protonvpn-app-wrapped" state=floating
        bspc rule -a protonvpn-app state=floating
        bspc rule -a Protonvpn-app state=floating
        bspc rule -a kruler state=floating
        bspc rule -a kruler border=off
        bspc rule -a kitty-picker state=floating
        bspc rule -a tetris state=floating rectangle=370x450+500+150
        bspc rule -a "" id=0x4e00001 state=floating rectangle=750x400+560+300   # zoom apps float and size (xzoom and magnify)

      '';

      startupPrograms = [
       #"numlockx on"
       #"tilda"
       #"feh --bg-fill /home/hrf/Pictures/Wallpapers/catppuccin-astro-macchiato/background.png"
       #"polybar example"
       #"plank"
      ];

      settings = {

        #border_width = 8;
        #window_gap = 8;
        #left_padding = 0;
        #right_padding = 0;
        #top_padding = 0;
        #bottom_padding = 0;

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
      pkgs.tilda
     #pkgs.plank
      pkgs.dockbarx
     #pkgs.xorg.xdpyinfo
      pkgs.xorg.xwininfo
      pkgs.xorg.xprop
      pkgs.xdotool
      mypkgs.stable.tint2
      pkgs.bc
      pkgs.conky
      pkgs.xdo
      pkgs.xbacklight
      pkgs.xkblayout-state
      pkgs.skippy-xd
      pkgs.xorg.xprop

     #pkgs.bsp-layout
      bsp-layout
     #pkgs.touchegg
     #pkgs.tabbed
     #bsp-tabbed
     #bsptab
     #bsp-layout-ext
     #pkgs.tabbed

    ];

    xdg.configFile."bsp-layout/layoutrc".text = ''
      # Layout Ratios
      TALL_RATIO=0.6;
      WIDE_RATIO=0.6;
      CENTER_RATIO=0.6;
      RCENTER_RATIO=0.6;
      DCENTER_RATIO=0.5;
      HDCENTER_RATIO=0.5;
      DECK_RATIO=0.5;

      # Windows To Ignore
      FLAGS="!hidden.!floating";

      # Use desktop names(1) or ids(0)
      USE_NAMES=0;
    '';

    home.sessionVariables = {

      SWALLOW_APPLICATIONS = "sxiv|zathura|mpv|feh|vlc|gwenview|showtime|resources";
     #SWALLOW_TERMINALS = "xterm|gnome-terminal";
      SWALLOW_TERMINALS = "wezterm|ghostty";

    };

    systemd.user.services.bspwm-reload = {
      Unit = {
        Description = "Reload BSPWM";
      };
      Service = {
        Type = "oneshot";
        ExecStart = ''/bin/bash -c "bspc wm -r"'';
        StandardOutput = "journal";
       #ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER bspwm'";
      };
    };

   #systemd.user.services.bsp-conf = {
   #  Unit = {
   #    Description = "Save Bspwm Config";
   #    ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
   #  };
   #  Service = {
   #    Type = "oneshot";
   #    ExecStart = ''/bin/bash -c "bsp-conf && bsp-conf-color"'';
   #  };
   #};
   #systemd.user.timers.bsp-conf = {
   #  Unit = {
   #    Description = "Bspwm Config Save Every 20min";
   #    ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
   #  };
   #  Install = {
   #    WantedBy = [ "timers.target" ];
   #  };
   #  Timer = {
   #    OnBootSec = "20min";
   #    OnUnitActiveSec = "20min";
   #    AccuracySec = "1min";
   #    Persistent = true;
   #  };
   #};

  };

}



# junk config


        #bspc subscribe node_add | while read -r event; do
        #    node_id=$(echo "$event" | cut -d' ' -f5)
        #    desktop=$(bspc query -D -d focused --names)
        #    if [ "$desktop" = "10" ]; then
        #        bspc node "$node_id" -t floating
        #    fi
        #done &


        #bspc rule -a plank layer=top    # manage=on border=off  # locked=on focus=off follow=off
        #bspc rule -a Plank layer=top    # manage=on border=off  # locked=on focus=off follow=off
        #bspc rule -a dockx layer=top    # manage=on border=off  # locked=on focus=off follow=off
        #bspc rule -a Dockx layer=top    # manage=on border=off  # locked=on focus=off follow=off
        #bspc rule -a dockbarx layer=top # manage=on border=off  # locked=on focus=off follow=off
        #bspc rule -a Dockbarx layer=top # manage=on border=off  # locked=on focus=off follow=off

        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N dockbarx &
        #done

        #rm -f ~/.cache/bspwm_zoom_last_1
        #rm -f ~/.cache/bspwm_zoom_last_2
        #rm -f ~/.cache/bspwm_zoom_last_3


        #if hash polybar >/dev/null 2>&1; then
        #	  pkill polybar
        #	  sleep 1.5
        #	  #polybar ${config.my.poly-name} &
        #     polybar-start
        #fi

        #$HOME/.polybar_modules

        #if hash conky >/dev/null 2>&1; then
        #	  pkill conky
        #	  sleep 0.5
        #	  conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
        #fi

        #if hash plank >/dev/null 2>&1; then
        #	  pkill plank
        #	  sleep 0.5
        #	  plank &
        #fi

        #if hash dockx >/dev/null 2>&1; then
        #	  pkill dockx
        #	  sleep 0.5
        #	  dockx &
        #fi

        #if hash tint2 >/dev/null 2>&1; then
        #	  pkill tint2
        #	  sleep 0.5
        #	  #tint2 -c ${nix-path}/modules/hm/bar-shell/tint2/dock/liness/tint.tint2rc &
        #     tint2 &
        #fi

        #if hash skippy-xd >/dev/null 2>&1; then
        #	  skippy-xd --stop-daemon
        #	  sleep 0.5
        #	  skippy-xd --start-daemon &
        #fi


         # Auto Swallower With Exclude List (Set With XDG ConfigFile in bsp-scripts.nix)
        #pgrep bspswallow || bspswallow &

         # Generic Swallower (Doesnt Work)
        #export PIDSWALLOW_SWALLOW_COMMAND='bspc node $pwid --flag hidden=on'
        #export PIDSWALLOW_VOMIT_COMMAND='bspc node $pwid --flag hidden=off'
        ##export PIDSWALLOW_PREGLUE_HOOK='bspc query -N -n $pwid.floating >/dev/null && bspc node $cwid --state floating'
        #pgrep -fl 'pidswallow -gl' || pidswallow -gl &

         # Manual Swallowe With Include List (Set Env Vars Below)
        #export SWALLOW_APPLICATIONS="sxiv|zathura|mpv"
        #export SWALLOW_TERMINALS="xterm|gnome-terminal"
        #bspwmswallow &

        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N Plank &
        #done
        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N dockx &
        #done &
        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N Dockx &
        #done &


        #rm -f $HOME/.config/touchegg/touchegg.conf
        #cp ${nix-path}/modules/hm/desktops/bspwm/touchegg.conf $HOME/.config/touchegg/touchegg.conf
        #if hash touchegg >/dev/null 2>&1; then
        #	  pkill touchegg
        #	  sleep 0.5
        #	  touchegg --daemon &
        #fi

        #bsp-subscribtions

        #pkill bsp-icon-bar
        #bsp-icon-bar &

        #pkill poly-bsp-lay
        #poly-bsp-lay &

        #pkill -f "live-bg-auto"
        #sleep 0.5
        #if [ -f "$HOME/.config/bspwm/bsp-live-auto-pause" ]; then
        #    $HOME/.config/bspwm/bsp-live-auto-pause
        #fi

        #pkill -f "bsp-app-border"
        #sleep 0.5
        #if [ -f "$HOME/.config/bspwm/bsp-auto-color" ]; then
        #    $HOME/.config/bspwm/bsp-auto-color
        #fi

        #pkill -f "bsp-de-sounds"
        #sleep 0.5
        #if [ -f "$HOME/.config/bspwm/bsp-sounds-toggle" ]; then
        #    $HOME/.config/bspwm/bsp-sounds-toggle
        #fi

        #pkill -f "bsp-abhide"
        #pkill -f "bsp-s-autohide"
        #sleep 0.5
        #if [ -f "$HOME/.config/bspwm/bsp-autohide" ]; then
        #  bsp-s-autohide
        #  sleep 0.5
        #  bsp-s-autohide
        #fi

