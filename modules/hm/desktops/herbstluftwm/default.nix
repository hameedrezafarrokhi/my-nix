{ config, pkgs, lib, ... }:

let

  cfg = config.my.herbstluftwm;

in

{

  options.my.herbstluftwm.enable = lib.mkEnableOption "herbstluftwm";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.herbstluftwm = {

      enable = true;
      package = pkgs.herbstluftwm;

      tags = [ "file" "browser" "terminal" "editor" "other" ];

     #rules = [
     #  "windowtype~'_NET_WM_WINDOW_TYPE_(DIALOG|UTILITY|SPLASH)' focus=on pseudotile=on"
     #  "windowtype~'_NET_WM_WINDOW_TYPE_(NOTIFICATION|DOCK|DESKTOP)' manage=off"
     #];

      mousebinds = {
        Mod4-B1 = "move";
        Mod4-B3 = "resize";
      };

     #keybinds = {
     #  Mod4-o = "split right";
     #  Mod4-u = "split bottom";
     #};

      settings = {
        gapless_grid = false;
        window_border_width = 3;
        window_border_active_color = "#FF0000";
      };

      extraConfig = ''
        herbstclient set_layout max
        herbstclient detect_monitors
      '';

    };

  };

}
