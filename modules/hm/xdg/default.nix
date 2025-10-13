{ config, pkgs, lib, ... }:

let

  cfg = config.my.xdg;
  x-cursor = pkgs.writeShellScriptBin "x-cursor" ''sleep 3 && xsetroot -cursor_name left_ptr'';
  x-cursor-start = pkgs.writeTextFile {
    name = "x-cursor.desktop";
    text = ''
      [Desktop Entry]
      Name=X-Cursor
      Comment=X-Cursor
      Exec=${x-cursor}/bin/x-cursor
    '';
  };

in

{

  imports = [ ./default-apps.nix ];

  options.my.xdg.enable =  lib.mkEnableOption "xdg";

  config = lib.mkIf cfg.enable {

    # location: /run/current-system/sw/etc/xdg/
    # location: /run/current-system/sw/share/xdg-desktop-portal/
    # location: ${config.home.homeDirectory}/.config/xdg-desktop-portal/

   #home.homeDirectory = "/home/${config.home.username}"; # SET PER USER!!!

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

      mime = {
        enable = true;
        desktopFileUtilsPackage = pkgs.desktop-file-utils;
        sharedMimeInfoPackage = pkgs.shared-mime-info;
      };

      terminal-exec = {
        enable = true;
        package = pkgs.xdg-terminal-exec; # pkgs.xdg-terminal-exec-mkhl (Rust Based)
        settings = {
         default = [ "${config.my.default.tui-editor}.desktop" ];
        #KDE = [  ];
        #GNOME = [ "com.raggesilver.BlackBox.desktop" "org.gnome.Terminal.desktop" ];
        };
      };

      mimeApps = {
        enable = true;
        associations = {
          added = { "application/vnd.microsoft.portable-executable" = "wine.desktop"; };
          removed = {
            "text/*" = [ "peazip-add-to-archive.desktop" "peazip.desktop" "peazip-extract.desktop" ];
            "application/*" = [ "peazip-add-to-archive.desktop" "peazip.desktop" "peazip-extract.desktop" ];
          };
        };
        defaultApplications = {

          ################################################################   TEXT

                               "text/*" = "${config.my.default.gui-editor}.desktop";
                           "text/plain" = "${config.my.default.gui-editor}.desktop";
                        "text/markdown" = "${config.my.default.gui-editor}.desktop";
                   "text/x-shellscript" = "${config.my.default.gui-editor}.desktop";

                     "application/json" = "${config.my.default.gui-editor}.desktop";
                      "application/xml" = "${config.my.default.gui-editor}.desktop";

                      "application/pdf" = "${config.my.default.gui-editor}.desktop";

          ###############################################################   IMAGE

                              "image/*" = "${config.my.default.image-viewer}.desktop";
                            "image/png" = "${config.my.default.image-viewer}.desktop";
                           "image/jpeg" = "${config.my.default.image-viewer}.desktop";
                            "image/gif" = "${config.my.default.image-viewer}.desktop";
                           "image/webp" = "${config.my.default.image-viewer}.desktop";
                            "image/bmp" = "${config.my.default.image-viewer}.desktop";
                           "image/tiff" = "${config.my.default.image-viewer}.desktop";

          ###############################################################   AUDIO

                              "audio/*" = "${config.my.default.audio-player}.desktop";
                           "audio/mpeg" = "${config.my.default.audio-player}.desktop";
                            "audio/mp3" = "${config.my.default.audio-player}.desktop";
                            "audio/aac" = "${config.my.default.audio-player}.desktop";
                            "audio/ogg" = "${config.my.default.audio-player}.desktop";
                           "audio/flac" = "${config.my.default.audio-player}.desktop";
                          "audio/x-m4a" = "${config.my.default.audio-player}.desktop";
                            "audio/wav" = "${config.my.default.audio-player}.desktop";

          ###############################################################   VIDEO

                              "video/*" = "${config.my.default.video-player}.desktop";
                            "video/mp4" = "${config.my.default.video-player}.desktop";
                     "video/x-matroska" = "${config.my.default.video-player}.desktop";
                          "video/x-flv" = "${config.my.default.video-player}.desktop";
                           "video/webm" = "${config.my.default.video-player}.desktop";
                      "video/x-msvideo" = "${config.my.default.video-player}.desktop";
                      "video/quicktime" = "${config.my.default.video-player}.desktop";
                       "video/x-ms-wmv" = "${config.my.default.video-player}.desktop";
                           "video/mpeg" = "${config.my.default.video-player}.desktop";
                           "video/3gpp" = "${config.my.default.video-player}.desktop";

          #############################################################   ARCHIVE

                      "application/zip" = "${config.my.default.archive-manager}.desktop";
          "application/x-7z-compressed" = "${config.my.default.archive-manager}.desktop";
                  "application/vnd.rar" = "${config.my.default.archive-manager}.desktop";
                    "application/x-tar" = "${config.my.default.archive-manager}.desktop";

          #############################################################   BROWSER

               "x-scheme-handler/https" = "${config.my.default.browser}.desktop";
                "x-scheme-handler/http" = "${config.my.default.browser}.desktop";
               "x-scheme-handler/about" = "${config.my.default.browser}.desktop";
             "x-scheme-handler/unknown" = "${config.my.default.browser}.desktop";
                            "text/html" = "${config.my.default.browser}.desktop";

          ########################################################   FILE_MANAGER

                      "inode/directory" = "${config.my.default.file-manager}.desktop";

          #############################################################   WINDOWS

          "application/vnd.microsoft.portable-executable" = "wine.desktop";

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
            default = ["gtk" "kde" "gnome" "gnome-keyring" "hyprland" "wlr" "cosmic" "xapp" "lxqt" "luminous" "shana" "termfilechooser" "kwallet"];
            "org.freedesktop.impl.portal.FileChooser" = ["shana"];
          };
          hyprland = {
            default = ["kde" "hyprland" "gtk" "gnome" "gnome-keyring" "shana" "termfilechooser" "kwallet"];
           #"org.freedesktop.impl.portal.Secret" = ["kwallet"];
            "org.freedesktop.impl.portal.Settings" = ["hyprland" "kde" "gtk" "gnome"];
            "org.freedesktop.impl.portal.FileChooser" = ["shana" "kde" "gtk" "gnome"];
            "org.freedesktop.impl.portal.AppChooser" = ["kde" "gtk" "gnome"];
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

              TERMINAL = config.my.default.terminal;
                EDITOR = config.my.default.tui-editor;
                VISUAL = config.my.default.tui-editor;
       XDG_MENU_PREFIX = "plasma-";

    };

    home.packages = [
      x-cursor
    ];

    systemd.user.services.x-cursor = {
      Unit = {
        Description = "x-cursor";
        After = [ "graphical-session.target" ];
        Wants = [ "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${x-cursor}/bin/x-cursor";
        RemainsAfterExit = "yes";
      };
      Install = {
        WantedBy = ["graphical-session.target"];
      };
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
