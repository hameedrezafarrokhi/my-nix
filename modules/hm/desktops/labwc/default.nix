{ config, pkgs, lib, ... }:

let

  cfg = config.my.labwc;

in

{

  options.my.labwc.enable = lib.mkEnableOption "labwc";

  config = lib.mkIf cfg.enable {

    wayland.windowManager.labwc = {

      enable = true;
      package = pkgs.labwc;
      xwayland.enable = true;

      autostart = [
        "waybar &"
      ];

      systemd = {
        enable = true;
        variables = [ "--all" ];
       #extraCommands = [
       #  "systemctl --user stop labwc-session.target"
       #  "systemctl --user start labwc-session.target"
       #];
      };

     #environment = [
     #  "XDG_CURRENT_DESKTOP=labwc:wlroots"
     #];


     #menu = [ ];
     #rc = { };
     #extraConfig = '' '';

    };

  };

}
