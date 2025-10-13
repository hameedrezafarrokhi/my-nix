{ config, pkgs, lib, admin, ... }:

let

  cfg = config.my.containers.flatpak;

in

{

  options.my.containers.flatpak.enable = lib.mkEnableOption "enable flatpak";

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [

      warehouse                     ##Flatpak manager

    ];

    services.flatpak = {

      enable = true;
      package = pkgs.flatpak;

      remotes = [
        {name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo";}
        {name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";}
      ];

      uninstallUnmanaged = false;
      uninstallUnused = false;

      update = {
        onActivation = false;
       #auto = {
       #  enable = true;
       #  onCalendar = "weekly"; # Default value
       #};
      };

      restartOnFailure = {
        enable = true;
        restartDelay = "60s";
      };

      packages = [
        # Examples
       #{ appId = "com.brave.Browser"; origin = "flathub";  }
       #{ flatpakref = "<uri>"; sha256="<hash>"; }
       #"com.obsproject.Studio"

       #"com.protonvpn.www"

       #"io.github.giantpinkrobots.flatsweep"
       #"com.github.tchx84.Flatseal"

       #"io.github.jeffshee.Hidamari"
       #"io.github.nokse22.trivia-quiz"

       #"io.github.fsobolev.TimeSwitch"
       #"com.github.taiko2k.avvie"

       #"org.kde.kate"
       #"io.github.najepaliya.kleaner"
       #"com.expidusos.file_manager"

       #"io.github.flattool.Warehouse"
       #"com.heroicgameslauncher.hgl"

       #"org.gtk.Gtk3theme.Adwaita-dark"
       #"org.gtk.Gtk3theme.adw-gtk3"
       #"org.gtk.Gtk3theme.adw-gtk3-dark"
       #"org.kde.KStyle.Adwaita/x86_64/6.8"
       #"org.gtk.Gtk3theme.Materia-nord"
       #"org.gtk.Gtk3theme.Materia"
       #"org.gtk.Gtk3theme.Materia-nord-compact"

       #"org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/24.08"
       #"org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/23.08"
       #"org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/22.08"
       #"org.freedesktop.Platform.VulkanLayer.MangoHud/x86_64/21.08"

       #"com.vixalien.sticky"
       #"io.github.tntwise.REAL-Video-Enhancer"

      ];

      overrides = {
        global = {
          Context = { #example: ["wayland" "!x11" "!fallback-x11"];                  # Force Wayland by default
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
		  "xdg-config/fontconfig:ro"
		  "xdg-data/themes:ro"
		  "xdg-data/icons:ro"
		  "xdg-data/fonts:ro"
		  "$HOME/.themes:ro"
		  "$HOME/.icons:ro"
	        #"xdg-config:ro"
	        #"xdg-data:ro"
	        #"xdg-state:ro"
            ];
          };
          Environment = {
            XCURSOR_PATH = "/run/current-system/sw/share/icons";
            NIX_XDG_DESKTOP_PORTAL_DIR = "/etc/profiles/per-user/${admin}/share/xdg-desktop-portal/portals";
            XDG_CACHE_HOME = "$HOME/.cache";
            XDG_CONFIG_HOME = "$HOME/.config";
            XDG_DATA_HOME = "$HOME/.local/share";
            XDG_STATE_HOME = "$HOME/.local/state";
	      QML2_IMPORT_PATH = "/etc/profiles/per-user/${admin}/lib/qt-5.15.17/qml:/etc/profiles/per-user/${admin}/lib/qt-6/qml";
	      QT_PLUGIN_PATH = "/etc/profiles/per-user/${admin}/lib/qt-5.15.17/plugins:/etc/profiles/per-user/${admin}/lib/qt-6/plugins";
          };
        };
       #"com.protonvpn.www".Context.sockets = ["x11"]; # No Wayland support
       #"io.github.jeffshee.Hidamari".Context.sockets = ["wayland"]; # No X support
      };

    };


  };

}
