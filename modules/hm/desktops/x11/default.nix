{ config, pkgs, lib, ... }:

let

  cfg = config.my.x11;

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

  options.my.x11.enable =  lib.mkEnableOption "x11 configs";

  config = lib.mkIf cfg.enable {

    xsession = {
      enable = true;
      numlock.enable = true;
      preferStatusNotifierItems = true;
      profilePath = ".xprofile";
      scriptPath = ".xsession";
      initExtra = ''
        export GDK_BACKEND=x11 &
      '';
      profileExtra = ''
        export GDK_BACKEND=x11 &
      '';
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

      # Bridge for Legacy X Apps thta dont have SNI features ( Choose One )
      snixembed.enable = true; # StandAlone and lightweight ( works great in x11 but breaks wayland wm tray )
      xembed-sni-proxy = { # Part of Plasma ecosystem ( works great in wayland but breaks x11 tray )
        enable = false;
        package = pkgs.kdePackages.plasma-workspace;
      };

    };

    # "!XDG_BACKEND=wayland"
    systemd.user.services.snixembed.Unit.ConditionEnvironment = "!XDG_SESSION_TYPE=wayland";

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

    home.packages = [ pkgs.wayback-x11 x-cursor ];

  };

}
