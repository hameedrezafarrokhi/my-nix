{ config, pkgs, lib, ... }:

let

  flame-env =  pkgs.writeShellScriptBin "flame-env" ''
    case "$XDG_CURRENT_DESKTOP" in
      KDE|GNOME|Hyprland|niri)
        echo "Skipping for $XDG_CURRENT_DESKTOP"
        exit 1
        ;;
    esac
  '';

in

{ config = lib.mkIf (config.my.apps.flameshot.enable) {

  services.flameshot = {
    enable = true;
    package = pkgs.flameshot;
   #package = pkgs.flameshot.override { enableWlrSupport = true; enableMonochromeIcon = true; };
   #settings = { # example: INI format
   #  General = {
   #    disabledTrayIcon = true;
   #    showStartupLaunchMessage = false;
   #  };
   #};
  };

  systemd.user.services.flameshot.Service.ExecStartPre = "${flame-env}/bin/flame-env";

  home.packages = [ flame-env ];

};}
