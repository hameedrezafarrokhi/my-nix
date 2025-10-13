{ config, pkgs, lib, nix-path, ... }:

let

  cfg = config.my.bspwm;

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
        export XDG_CURRENT_DESKTOP=BSPWM
      '';

      # killall -q polybar
      # polybar -c ~/.config/bspwm/polybar/config.ini &
      extraConfig = ''

        if hash sxhkd >/dev/null 2>&1; then
        	  pkill sxhkd
        	  sleep 1.5
        	  sxhkd -c "${nix-path}/modules/hm/desktops/bspwm/sxhkdrc" &
        fi

      '';

      startupPrograms = [
       #"numlockx on"
       #"tilda"
       #"feh --bg-fill /home/hrf/Pictures/Wallpapers/catppuccin-astro-macchiato/macchiato-hald8-background.png2.png"
        "polybar example"
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

    home.packages = [ pkgs.sxhkd pkgs.bc pkgs.bsp-layout ];

  };

}
