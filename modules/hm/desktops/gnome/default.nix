{ config, pkgs, lib, ... }:

let

  cfg = config.my.gnome;

in

{

  options.my.gnome.enable = lib.mkEnableOption "gnome";

  config = lib.mkIf cfg.enable {

    programs.gnome-shell = {

      enable = true;

      extensions = [
       #{ package = pkgs.gnomeExtensions.dash-to-panel; }
       #{
       #  id = "user-theme@gnome-shell-extensions.gcampax.github.com";
       #  package = pkgs.gnome-shell-extensions;
       #}
      ];

    };

    dconf.settings = {

    };

  };

}
