{ config, pkgs, lib, nix-path, nix-path-alt, mypkgs, ... }:

let

  cfg = config.my.bspwm;

  bsp-tabbed = pkgs.callPackage ./tabbed/bsp-tabbed.nix { };
  bsptab = pkgs.callPackage ./tabbed/bsptab.nix { tabbed = bsp-tabbed; };

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
          else
            bspc monitor -d 1 2 3 4 5 6 7 8 9 10
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
        bspc rule -a ".blueman-manager-wrapped" state=floating
        bspc rule -a pavucontrol state=floating
        bspc rule -a "copyq" state=floatin
        bspc rule -a ".protonvpn-app-wrapped" state=floating

        # zoom apps float and size (xzoom and magnify)
        bspc rule -a "" id=0x4e00001 state=floating rectangle=750x400+560+300

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

        pgrep bspswallow || bspswallow &

        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N Plank &
        #done
        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N dockx &
        #done &
        #bspc subscribe node_add | while read -r _; do
        #   xdo raise -N Dockx &
        #done &

        bsp-touchegg &

        #rm -f $HOME/.config/touchegg/touchegg.conf
        #cp ${nix-path}/modules/hm/desktops/bspwm/touchegg.conf $HOME/.config/touchegg/touchegg.conf
        #if hash touchegg >/dev/null 2>&1; then
        #	  pkill touchegg
        #	  sleep 0.5
        #	  touchegg --daemon &
        #fi

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

        border_width = 8;
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
      pkgs.bsp-layout
     #pkgs.touchegg
     #pkgs.tabbed

      bsp-tabbed
      bsptab

     #pkgs.tabbed

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

   #systemd.user.services.touchegg-bsp = {
   #  Unit = {
   #   Description = "Touchegg BSPWM Daemon";
   #   ConditionEnvironment = "!XDG_SESSION_TYPE=wayland";
   #  };
   #  Service = {
   #    Type = "simple";
   #    ExecStart = "${pkgs.touchegg}/bin/touchegg --daemon";
   #    Restart = "on-failure";
	 ##xecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER bspwm'";
   #  };
   #  Install = {
   #    WantedBy = [ "graphical-session.target" ];
   #  };
   #};

  };

}
