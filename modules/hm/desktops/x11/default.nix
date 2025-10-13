{ config, pkgs, lib,
#osConfig,
... }:

let

  cfg = config.my.x11;

 #cinnamon-gsettings-overrides = pkgs.cinnamon-gsettings-overrides.override {
 #  extraGSettingsOverridePackages = osConfig.services.xserver.desktopManager.cinnamon.extraGSettingsOverridePackages;
 #  extraGSettingsOverrides = osConfig.services.xserver.desktopManager.cinnamon.extraGSettingsOverrides;
 #};
 #budgie-gsettings-overrides = pkgs.budgie-gsettings-overrides.override {
 #  inherit (osConfig.services.xserver.desktopManager.budgie) extraGSettingsOverrides extraGSettingsOverridePackages;
 #  inherit nixos-background-dark nixos-background-light;
 #};
 #nixos-background-light = pkgs.nixos-artwork.wallpapers.nineish;
 #nixos-background-dark = pkgs.nixos-artwork.wallpapers.nineish-dark-gray;

in

{

  options.my.x11.enable =  lib.mkEnableOption "x11 configs";

  config = lib.mkIf cfg.enable {

    xsession = {
      enable = true;
      numlock.enable = true;
      preferStatusNotifierItems = false;
      profilePath = ".xprofile";
      scriptPath = ".xsession";
          # export XDG_MENU_PREFIX=plasma-
     #initExtra = ''
     #  # Detect session
     #  if [[ $XDG_CURRENT_DESKTOP == "X-Cinnamon" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $CINNAMON_VERSION == "6.4.13" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $XDG_CURRENT_DESKTOP == "MATE" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $MATE_PANEL_EXTRA_MODULES == "/nix/store/46h8bn62vn0y0ik7m6b6hyfsl10cxy1f-mate-panel-with-applets-1.28.6/lib/mate-panel/applets" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie:GNOME" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $BUDGIE_PLUGIN_DATADIR == "/nix/store/g4fsbq7k1va8f0zqy0832gwynlhm2v3f-budgie-desktop-with-plugins-10.9.2/share/budgie-desktop/plugins" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  fi
     #  '';

     #profileExtra = ''
     #  # Detect session
     #  if [[ $XDG_CURRENT_DESKTOP == "X-Cinnamon" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $CINNAMON_VERSION == "6.4.13" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${cinnamon-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $XDG_CURRENT_DESKTOP == "MATE" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $MATE_PANEL_EXTRA_MODULES == "/nix/store/46h8bn62vn0y0ik7m6b6hyfsl10cxy1f-mate-panel-with-applets-1.28.6/lib/mate-panel/applets" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${pkgs.mate.mate-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie:GNOME" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $XDG_CURRENT_DESKTOP == "Budgie" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  elif [[ $BUDGIE_PLUGIN_DATADIR == "/nix/store/g4fsbq7k1va8f0zqy0832gwynlhm2v3f-budgie-desktop-with-plugins-10.9.2/share/budgie-desktop/plugins" ]]; then
     #      export NIX_GSETTINGS_OVERRIDES_DIR="${budgie-gsettings-overrides}/share/gsettings-schemas/nixos-gsettings-overrides/glib-2.0/schemas"
     #  fi
     #'';

       #"export XDG_SESSION_DESKTOP=x11"
       #"export XDG_CURRENT_DESKTOP=x11"

      importedVariables = [ ];
      windowManager.command = lib.mkForce "test -n \"$1\" && eval \"$@\"";
    };

    services = {
      xsettingsd = {
        enable = true;
        package = pkgs.xsettingsd;
        settings = {
          "Net/CursorBlinkTime" = 1000;
          "Net/CursorBlink" = 1;
          "Gdk/UnscaledDPI" = 98304;
          "Gdk/WindowScalingFactor" = 1;
        };
      };
      picom ={
        enable = true;
        package = pkgs.picom;
        backend = "egl"; # "egl", "glx", "xrender", "xr_glx_hybrid"

        shadow = true;
        shadowOpacity = 0.50;
       #shadowOffsets = [ 15 15 ];
        shadowExclude = [
          "name = 'Notification'"
          "class_g ?= 'Notify-osd'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        fade = true;
        fadeSteps = [ 0.028 0.03 ];
        fadeDelta = 3;
       #fadeExclude = [ ];

        activeOpacity = 1.0;
        menuOpacity = 1.0;
        inactiveOpacity = 0.85;
       #opacityRules = [ ];

        settings = {
          blur = {
            method = "gaussian";
            size = 13;
            deviation = 6.0;
          };
         #blur-kern = "3x3box";
          corner-radius = 10;
          shadow-radius = 20;
          shadow-offset-x = "5";
          shadow-offset-y = "-5";
          frame-opacity = 1.0;
          inactive-opacity-override = false;
         #round-borders = 8;
          blur-background-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
            "_GTK_FRAME_EXTENTS@:c"
          ];
          rounded-corners-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
          ];
          vsync = true;
          mark-wmwin-focused = true;
          mark-ovredir-focused = true;
          detect-rounded-corners = true;
          detect-client-opacity = true;
          detect-transient = true;
         #use-damage = true;  # WARNING DEGRADES PERFORMANCE
          wintypes = {
            tooltip = {
              fade = true;
              shadow = false;
              opacity = 0.95;
              focus = true;
              full-shadow = false;
            };
            dock = {
              shadow = false;
              clip-shadow-above = true;
            };
            dnd = { shadow = false; };
            popup_menu = { opacity = 0.95; };
            dropdown_menu = { opacity = 0.95; };
          };


        };
       #extraArgs = { };
      };
    };

    home.packages = [ pkgs.wayback-x11 ];

  };

}
