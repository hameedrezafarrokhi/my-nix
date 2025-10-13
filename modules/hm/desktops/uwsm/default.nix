{ config, pkgs, lib, ... }:

let

  cfg = config.my.uwsm;

in

{

  options.my.uwsm.enable =  lib.mkEnableOption "uwsm configs";

  config = lib.mkIf cfg.enable {

    xdg = {

      configFile."./uwsm/env".text = ''

        export XCURSOR_SIZE=24
        export HYPRCURSOR_SIZE=24
        export XDG_MENU_PREFIX=plasma-
        export NIXOS_OZON_WL=1
        export ELECTRON_OZONE_PLATFORM_HINT=auto

        '';
     #        export MOZ_ENABLE_WAYLAND=1

    };

  };

}
