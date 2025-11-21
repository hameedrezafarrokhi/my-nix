{ config, pkgs, lib, nix-path, nix-path-alt, mypkgs, ... }:

let

  cfg = config.my.bspwm;

in

{

  options.my.bspwm.enable = lib.mkEnableOption "bspwm";

  imports = [

    ./bsp-scripts.nix
    ./bsp-touchegg.nix

  ];

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
      pkgs.xorg.xprop
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
