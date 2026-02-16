{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.custom-desktop-entries;
  xremapPath = toString ../../../nixos/hardware/keyboard/xremap-conf.yaml;
 #x-cursor = pkgs.writeShellScriptBin "x-cursor" ''xsetroot -cursor_name left_ptr'';

in

{

  options.my.custom-desktop-entries.enable =  lib.mkEnableOption "custom-desktop-entries";

  config = lib.mkIf cfg.enable {

    # location:       /run/current-system/etc/profiles/per-user/hrf/share/applications/
    # system entries: /run/current-system/sw/share/applications/

    xdg.desktopEntries = {
     #"xremap" = {
     #  name="xremap";
     #  exec="${(pkgs.writeShellScriptBin "xremap-desktop" ''
     #     systemctl --user stop xremap.service && xremap --watch --mouse ${xremapPath}
     #   '')}/bin/xremap-desktop";
     #  categories=["System"];
     #};
      "org.kde.dolphin" = {
        name="Dolphin";
        genericName = "File Manager";
        exec="env XDG_MENU_PREFIX=plasma- dolphin"; # QT_QPA_PLATFORMTHEME=kde
        categories=["Qt" "KDE" "System" "FileTools" "FileManager"];
        mimeType= ["inode/directory"];
       #noDisplay=;
       #prefersNonDefaultGPU=;
       #startupNotify=;
       #terminal=;
        type="Application";
        comment="Manage your files";
        icon="${inputs.assets}/icons/dolphin.svg";
        settings = {
          X-DocPath="dolphin/index.html";
          InitialPreference="10";
          Keywords="files;file management;file browsing;samba;network shares;Explorer;Finder;";
          X-DBUS-ServiceName="org.kde.dolphin";
          X-KDE-Shortcuts="Meta+E";
          StartupWMClass="dolphin";
        };
      };
      "Timeshift-gtk" = {
        name="Timeshift-gtk";
        genericName="System Restore Utility";
        comment="System Restore Utility";
        terminal=false;
        type="Application";
        exec="sudo -E ${pkgs.timeshift}/bin/timeshift-gtk";
        categories=["System"];
        icon="${inputs.assets}/icons/backup-clock.svg";
        startupNotify = null;
        prefersNonDefaultGPU = null;
        noDisplay = false;
       #settings = { DBusActivatable = "false"; "X-Ubuntu-Gettext-Domain=onboard"; };
       #actions = {};
      };
      "Gparted-gtk" = {
        name="Gparted-gtk";
        genericName="Partition Editor";
        comment="Create, reorganise, and delete partitions";
        terminal=false;
        type="Application";
        exec="sudo -E ${pkgs.gparted}/bin/gparted";
        categories=["GNOME" "System" "Filesystem"];
        icon="${inputs.assets}/icons//floppy-disk.svg";
        startupNotify = null;
        prefersNonDefaultGPU = null;
        noDisplay = false;
       #settings = { DBusActivatable = "false"; "X-Ubuntu-Gettext-Domain=onboard"; };
       #actions = {};
      };
      "XFiles" = {
        name="XFiles";
        genericName = "File Manager";
        exec="xfiles"; # QT_QPA_PLATFORMTHEME=kde
        categories=["System" "FileTools" "FileManager"];
        mimeType= ["inode/directory"];
        type="Application";
        comment="Manage your files the simple way";
        icon="${inputs.assets}/icons/xfiles.png";
        settings = {
          Keywords="files;file management;file browsing;Explorer;Finder;";
        };
      };


############## REMOVING AUTO GENERATED AND UNWANTED AUTOSTARTS

    };

    xdg = {

      configFile."./autostart/org.kde.xwaylandvideobridge.desktop".text = ''

        [Desktop Entry]
        OnlyShowIn=KDE;
        X-KDE-StartupNotify=false
        X-KDE-autostart-phase=2
        X-GNOME-Autostart-enabled=true
        NoDisplay=true

        Type=Application
        Name=Xwayland Video Bridge
        GenericName=Share screens and windows to XWayland applications
        Icon=xwaylandvideobridge
        Exec=xwaylandvideobridge
        StartupNotify=false
        Categories=Qt;KDE;Utility;X-KDE-Utilities-Desktop;

      '';

      configFile."./autostart/nm-applet.desktop".text = ''

        [Desktop Entry]
        Name=NetworkManager Applet
        Comment=Manage your network connections
        Icon=nm-device-wireless
        Exec=nm-applet
        Terminal=false
        Type=Application
        NoDisplay=true
        NotShowIn=KDE;GNOME;Hyprland;niri;Cosmic;cosmic;COSMIC;
        X-GNOME-UsesNotifications=true

      '';

      configFile."./autostart/kalarm.autostart.desktop".text = ''

        # KDE Config File
        [Desktop Entry]
        Hidden=true
        Name=KAlarm
        Exec=kalarmautostart kalarm --tray
        Icon=kalarm
        Type=Application
        X-DocPath=kalarm/index.html
        Comment=KAlarm autostart at login
        X-KDE-autostart-phase=2
        X-KDE-autostart-condition=kalarmrc:General:AutoStart:false

      '';

      #NotShowIn=KDE;GNOME;Hyprland;niri;Cosmic;cosmic;COSMIC;
      configFile."./autostart/blueman.desktop".text = ''

        [Desktop Entry]
        OnlyShowIn=none;
        Hidden=true
        Name=Blueman Applet
        Comment=Blueman Bluetooth Manager
        Icon=blueman
        Exec=blueman-applet
        Terminal=false
        Type=Application
        Categories=

      '';

     #configFile."./autostart/x-cursor.desktop".text = ''
     #
     #  [Desktop Entry]
     #  NotShowIn=KDE;GNOME;Hyprland;niri;
     #  Name=X-Cursor
     #  Comment=X-Cursor
     #  Icon=
     #  Exec=${x-cursor}/bin/x-cursor
     #  Terminal=false
     #  Type=Application
     #  Categories=
     #
     #'';

     #configFile."./autostart/org.​kde.​yakuake.desktop".text = ''
     #
     #  [Desktop Entry]
     #  Hidden=true
     #  Name=Yakuake
     #  GenericName=Drop-down Terminal
     #  Exec=yakuake
     #  Icon=yakuake
     #  Type=Application
     #  Terminal=false
     #  Categories=Qt;KDE;System;TerminalEmulator;
     #  Comment=A drop-down terminal emulator based on KDE Konsole technology.
     #  StartupNotify=false
     #  DBusActivatable=true
     #
     #'';

    };

    home.packages = [
     #x-cursor
    ];

  };

}
