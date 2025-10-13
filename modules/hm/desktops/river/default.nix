{ config, pkgs, lib, ... }:

let

  cfg = config.my.labwc;

in

{

  options.my.river.enable = lib.mkEnableOption "river";

  config = lib.mkIf cfg.enable {

    wayland.windowManager.river = {

      enable = true;
      package = pkgs.river-classic;
      xwayland.enable = true;

      systemd = {
        enable = true;
        variables = [ "-all" ];
        extraCommands = [
          "systemctl --user stop river-session.target"
          "systemctl --user start river-session.target"
        ];
      };

      extraSessionVariables = {
       #XDG_CURRENT_DESKTOP= "labwc:wlroots";
       #MOZ_ENABLE_WAYLAND = "1";
      };

     #settings = { };
     #extraConfig = '' '';

    };

  };

}
