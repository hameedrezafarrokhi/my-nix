{ config, pkgs, lib, ... }:

let

  cfg = config.my.xdg;

in

{

  imports = [ ./default-apps.nix ];

  options.my.xdg.enable =  lib.mkEnableOption "xdg";

  config = lib.mkIf cfg.enable {

    # location: /run/current-system/sw/etc/xdg/
    # location: /run/current-system/sw/share/xdg-desktop-portal/
    # location: ${config.home.homeDirectory}/.config/xdg-desktop-portal/

   #home.homeDirectory = "/home/${config.home.username}"; # SET PER USER!!!

    home.packages = [
      (pkgs.writeShellScriptBin "fehb"  ''feh --bg-fill "$1"'')
      (pkgs.writeShellScriptBin "ekc"   ''${config.my.default.gui-editor-alt-name} $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "vkc"   ''${config.my.default.video-player} $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "mkc"   ''${config.my.default.audio-player} $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "fkc"   ''${config.my.default.pdf-viewer} $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "akc"   ''${config.my.default.archive-manager} $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "pkc"   ''${config.my.default.image-viewer} $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "ekcs"  ''kitty --name kitty-picker --class kitty-picker sh -c '${config.my.default.gui-editor-alt-name} "$(kitten choose-files)"' '')
      (pkgs.writeShellScriptBin "vkcs"  ''kitty --name kitty-picker --class kitty-picker sh -c '${config.my.default.video-player} "$(kitten choose-files)"' '')
      (pkgs.writeShellScriptBin "mkcs"  ''kitty --name kitty-picker --class kitty-picker sh -c '${config.my.default.audio-player} "$(kitten choose-files)"' '')
      (pkgs.writeShellScriptBin "fkcs"  ''kitty --name kitty-picker --class kitty-picker sh -c '${config.my.default.pdf-viewer} "$(kitten choose-files)"' '')
      (pkgs.writeShellScriptBin "akcs"  ''kitty --name kitty-picker --class kitty-picker sh -c '${config.my.default.archive-manager} "$(kitten choose-files)"' '')
      (pkgs.writeShellScriptBin "pkcs"  ''kitty --name kitty-picker --class kitty-picker sh -c '${config.my.default.image-viewer-alt-name} "$(kitten choose-files)"' '')
      (pkgs.writeShellScriptBin "pkcr"  ''kitty --name kitty-picker --class kitty-picker sh -c 'kitten icat $(kitten choose-files) & sleep infinity' '')
      (pkgs.writeShellScriptBin "pkck"  ''kitten icat $(kitten choose-files)'')
      (pkgs.writeShellScriptBin "kicat" ''kitten icat $1'')
    ];

    xdg = {
      enable = true;

      autostart = {
        enable = true;
        entries = [
         #"${pkgs.evolution}/share/applications/org.gnome.Evolution.desktop"
         #"/run/cuurent-system/sw/share/application/xremap.desktop"
         #"${(pkgs.writeShellScriptBin "xremap-desktop" ''
         #  systemctl --user stop xremap.service && xremap --watch --mouse ${config.services.xremap.yamlConfig}
         #'')}/bin/xremap-desktop"
         #"${config.xdg.desktopEntries.xremap}"
         #"${config.home.homeDirectory}/.local/state/home-manager/gcroots/current-home/home-path/share/applications/xremap.desktop"

         #"${x-cursor-start}/x-cursor.desktop"

        ];
        readOnly = false;
      };

     #cacheFile =  {};
     #configFile = {};
     #dataFile = {};
     #desktopEntries = {};
     #stateFile = {};

     #cacheHome = "~/.cache";
     #configHome  = "~/.config";
     #dataHome = "~/.local/share";
     #stateHome = "~/.local/state";

      systemDirs = {
        config = [ "/etc/xdg" ];   # examples ?????
        data = [ "/usr/share" "/usr/local/share" ];
      };

      userDirs = {
        enable = true;
        createDirectories = true;
        desktop = "${config.home.homeDirectory}/Desktop";
        documents = "${config.home.homeDirectory}/Documents";
        download = "${config.home.homeDirectory}/Downloads";
        music = "${config.home.homeDirectory}/Music";
        pictures = "${config.home.homeDirectory}/Pictures";
        publicShare = "${config.home.homeDirectory}/Public";
        templates = "${config.home.homeDirectory}/Templates";
        videos = "${config.home.homeDirectory}/Videos";
        extraConfig = {  # add extra dirs here
          XDG_MISC_DIR = "${config.home.homeDirectory}/Misc";
        };
      };

      portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal                  # General
          pkgs.xdg-desktop-portal-gtk              # For WMs/Gnome
          pkgs.kdePackages.xdg-desktop-portal-kde  # For KDE Plasma
          pkgs.xdg-desktop-portal-gnome            # For Gnome
          pkgs.xdg-desktop-portal-hyprland         # For Hyprland
          pkgs.xdg-desktop-portal-wlr              # For Wayland WMs like Sway
          pkgs.xdg-desktop-portal-xapp             # For Cinnamon Mate XFCE
          pkgs.lxqt.xdg-desktop-portal-lxqt        # For LXQT
          pkgs.xdg-desktop-portal-cosmic           # For Cosmic
          pkgs.xdg-desktop-portal-shana            # For General Purpose (Portal of Portals / needs config)
          pkgs.xdg-desktop-portal-termfilechooser  # For Terminal Filepicker
          pkgs.xdg-desktop-portal-luminous
         #pantheon.xdg-desktop-portal-pantheon     # For Pantheon
          pkgs.gnome-keyring
        ];
       #configPackages = [ pkgs.gnome-session ];
        config = { # same as nixos options
          common = {
           #default = ["gtk" "kde" "gnome" "gnome-keyring" "hyprland" "cosmic" "wlr" "xapp" "lxqt" "luminous" "shana" "termfilechooser" "kwallet"];
           #default = [ "*" ];
            "org.freedesktop.impl.portal.FileChooser" = ["shana"];
          };
          hyprland = {
            default = ["hyprland" "kde" "gtk" "gnome" "gnome-keyring" "shana"];
           #"org.freedesktop.impl.portal.Secret" = ["kwallet"];
            "org.freedesktop.impl.portal.Settings" = ["hyprland" "kde" "gtk" "gnome"];
            "org.freedesktop.impl.portal.FileChooser" = ["shana" "kde" "gtk" "gnome"];
            "org.freedesktop.impl.portal.AppChooser" = ["kde" "gtk" "gnome"];
          };
          niri = {
            default = ["gnome" "gtk" "gnome-keyring" "kde" "shana" "wlr"];
            "org.freedesktop.impl.portal.Access" = ["gtk" "gnome"];
            "org.freedesktop.impl.portal.Notification" = ["gtk"];
            "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
          };
          kde = {
            default = ["kde"];
            "org.freedesktop.impl.portal.Secret" = ["kwallet"];
            "org.freedesktop.impl.portal.Settings" = ["kde" "gtk"];
          };
        };
      };

      configFile."./xdg-desktop-portal-shana/config.toml".text = ''
          open_file = "Kde"
          save_file = "Kde"

          [tips]
          open_file_when_folder = "Kde"
        '';  # Gnome Kde Gtk Lxqt  "org.freedesktop.desktop.impl.lxqt"
    };

    # GTK SPECS:
    # $ grep Interfaces /usr/share/xdg-desktop-portal/portals/gtk.portal  | cut -d= -f2  | tr ';' '\n'
    # org.freedesktop.impl.portal.FileChooser
    # org.freedesktop.impl.portal.AppChooser
    # org.freedesktop.impl.portal.Print
    # org.freedesktop.impl.portal.Notification
    # org.freedesktop.impl.portal.Inhibit
    # org.freedesktop.impl.portal.Access
    # org.freedesktop.impl.portal.Account
    # org.freedesktop.impl.portal.Email
    # org.freedesktop.impl.portal.DynamicLauncher
    # org.freedesktop.impl.portal.Lockdown
    # org.freedesktop.impl.portal.Settings

    home.sessionVariables = {

       XDG_MENU_PREFIX = "plasma-";

    };

   #home.file."/.config/xdg-desktop-portal-shana/config.toml" = {
   #  target = ;
   #  text = ''
   #    open_file = "Kde"
   #    save_file = "Gtk"
   #
   #    [tips]
   #    open_file_when_folder = "Kde"
   #  '';  # Gnome Kde Gtk Lxqt  "org.freedesktop.desktop.impl.lxqt"
   #};

  };

}
