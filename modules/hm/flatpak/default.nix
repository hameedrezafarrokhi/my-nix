{ config, pkgs, lib, ... }:

let

  cfg = config.my.flatpak;

in

{

  options.my.flatpak.enable =  lib.mkEnableOption "flatpak";

  config = lib.mkIf cfg.enable {

    services.flatpak = {

      overrides = {
        global = {
          Context = {
            devices = [ "all" "dri" ];
            allow = [ "bluetooth" ];
            sockets = ["wayland" "x11" "fallback-x11" "gpg-agent" "pulseaudio" "session-bus" "system-bus" "ssh-auth" "inherit-wayland-socket"];
            filesystems = [
              "home"
              "host"
              "host-etc"
              "host-os"
              "/nix/store:ro"
             #"/etc/xdg:ro"
              "/run/current-system/sw/bin:ro"
              "/run/current-system/sw/sbin:ro"
              "/run/current-system/sw/share:ro"
              "/run/current-system/sw/share/icons:ro"
              "/run/current-system/sw/share/themes:ro"
              "/run/current-system/sw/etc/xdg:ro"
              "/run/current-system/sw/lib:ro"
              "/run/current-system/sw/libexec:ro"
		  "xdg-config/gtk-3.0:ro"
		  "xdg-config/gtk-4.0:ro"
		  "xdg-config/Kvantum:ro"
		  "xdg-config/fontconfig"
		  "xdg-data/themes:ro"
		  "xdg-data/icons:ro"
		  "xdg-data/fonts:ro"
		  ".themes:ro"
		  ".icons:ro"
	        #"xdg-config:ro"
	        #"xdg-data:ro"
	        #"xdg-state:ro"
		  "${config.home.homeDirectory}:ro"
              "${config.xdg.configHome}/gtk-3.0:ro"
              "${config.xdg.configHome}/gtk-4.0:ro"
              "${config.xdg.configHome}/Kvantum:ro"
              "${config.xdg.configHome}/dconf:ro"
              "${config.xdg.dataHome}:ro"
              "${config.xdg.stateHome}:ro"
              "${config.xdg.cacheHome}:ro"
              "${config.xdg.configHome}:ro"
              "${config.xdg.dataHome}/icons:ro"
            ];
          };
          Environment = {

            XCURSOR_PATH = "/run/current-system/sw/share/icons";

            NIX_XDG_DESKTOP_PORTAL_DIR = "/etc/profiles/per-user/${config.home.username}/share/xdg-desktop-portal/portals";
	      QML2_IMPORT_PATH = "/etc/profiles/per-user/${config.home.username}/lib/qt-5.15.17/qml:/etc/profiles/per-user/${config.home.username}/lib/qt-6/qml";
	      QT_PLUGIN_PATH = "/etc/profiles/per-user/${config.home.username}/lib/qt-5.15.17/plugins:/etc/profiles/per-user/${config.home.username}/lib/qt-6/plugins";

            XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
            XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
            XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
            XDG_STATE_HOME = "${config.home.homeDirectory}/.local/state";
          };
        };
       #"com.protonvpn.www".Context.sockets = ["x11"]; # No Wayland support
       #"io.github.jeffshee.Hidamari".Context.sockets = ["wayland"]; # No X support
      };

    };

  };

}
