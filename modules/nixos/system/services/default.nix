{ config, lib, pkgs, admin, ... }:

{

  options.my.services.enable = lib.mkEnableOption "random services";

  config = lib.mkIf (config.my.services.enable) {

    services = {

      orca = {
        enable = false;
        package = pkgs.orca;
      };

      # GNOME STUFF
      gnome.localsearch.enable = false;
      gnome.tinysparql.enable = false;
      gnome.glib-networking.enable = true;
      gnome.sushi.enable = false;
      sysprof.enable = false;

      gvfs = {
        enable = true;
        package = pkgs.gnome.gvfs;
      };

    };

  };

}
