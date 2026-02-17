{ config, pkgs, lib, nix-path, ... }:

let

  cfg = config.my.openbox;

in

{

  options.my.openbox.enable = lib.mkEnableOption "openbox";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.obconf
     #pkgs.jgmenu
    ];

    xdg.configFile = {

      openbox-autostart = {
        target = "openbox/autostart";
        text = ''
          #fehw &

          if hash polybar >/dev/null 2>&1; then
          	  pkill polybar
          	  sleep 1
          	  ${config.services.polybar.package}/bin/polybar &
          	  polybar-msg action bspwm module_hide
          fi &

          polybar-msg action bspwm module_hide

          if hash conky >/dev/null 2>&1; then
          	  pkill conky
          	  sleep 0.5
          	  conky -c "${nix-path}/modules/hm/bar-shell/conky/Deneb/Deneb.conf" &
          fi &

          if hash tint2 >/dev/null 2>&1; then
          	  pkill tint2
          	  sleep 0.5
          	  tint2
          fi &

          if hash dockx >/dev/null 2>&1; then
          	  pkill dockx
          	  sleep 0.5
          	  dockx &
          fi

          if hash skippy-xd >/dev/null 2>&1; then
          	  pkill skippy-xd
          	  sleep 0.5
          	  skippy-xd --start-daemon &
          fi

          #if hash plank >/dev/null 2>&1; then
          #	  pkill plank
          #	  sleep 0.5
          #	  plank
          #fi &

          polybar-msg action bspwm module_hide
        '';
      };

    };


  };

}
