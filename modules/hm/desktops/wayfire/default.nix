{ config, pkgs, lib, ... }:

let

  cfg = config.my.labwc;

in

{

  options.my.wayfire.enable = lib.mkEnableOption "wayfire";

  config = lib.mkIf cfg.enable {

    wayland.windowManager.wayfire = {

      enable = true;
      package = pkgs.wayfire;
      xwayland.enable = true;

      plugins = with pkgs.wayfirePlugins; [
        wcm
        wf-shell
        windecor
        wwp-switcher
        focus-request
        wayfire-shadows
        wayfire-plugins-extra
      ];

      systemd = {
        enable = true;
        variables = [ "-all" ];
        extraCommands = [
          "systemctl --user stop wayfire-session.target"
          "systemctl --user start wayfire-session.target"
        ];
      };

      settings = {
       #core.plugins = '' '';
      };

      wf-shell = {
        enable = true;
        package = pkgs.wayfirePlugins.wf-shell;
       #settings = { };
      };

    };

    home.packages = [ pkgs.wf-config pkgs.wayland-logout ];

  };

}
