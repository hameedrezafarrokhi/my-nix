{ config, lib, pkgs, admin, ... }:

{

  options.my.services.enable = lib.mkEnableOption "random services";

  config = lib.mkIf (config.my.services.enable) {

    services = {

      # GNOME STUFF
      gnome.localsearch.enable = true;
      gnome.tinysparql.enable = true;
      gnome.glib-networking.enable = true;
      gnome.sushi.enable = true;
      sysprof.enable = true;
      gvfs = {
        enable = true;
        package = pkgs.gnome.gvfs;
      };

    };

  };

}
