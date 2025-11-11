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
        setxkbmap -layout us,ir -option "grp:alt_caps_toggle" &
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
        package = pkgs.picom-pijulius; # pkgs.picom;
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
         #shadow-offset-x = "5";
         #shadow-offset-y = "-5";
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
            "class_name = 'rofi'"
            "class_g = 'Rofi'"
            "class_g = 'rofi'"
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

        extraConfig = ''
animations = ({
    triggers = ["close", "hide"];
    opacity = {
        curve = "linear";
        duration = 0.15;
        start = "window-raw-opacity-before";
        end = "window-raw-opacity";
    };
    blur-opacity = "0";
    shadow-opacity = "opacity";
    offset-x = "(1 - scale-x) / 2 * window-width";
    offset-y = "(1 - scale-y) / 2 * window-height * 5";
    scale-x = {
        curve = "cubic-bezier(0.21, 0.02, 0.76, 0.36)";
        duration = 0.15;
        start = 1;
        end = 0.9;
    };
    scale-y = "scale-x";
    shadow-scale-x = "scale-x";
    shadow-scale-y = "scale-y";
    shadow-offset-x = "offset-x";
    shadow-offset-y = "offset-y";
}, {
    triggers = ["open", "show"];
    opacity = {
        curve = "linear";
        duration = 0.15;
        start = "window-raw-opacity-before";
        end = "window-raw-opacity";
    };
    blur-opacity = {
        curve = "linear";
        duration = 0.1;
        delay = 0.15;
        start = "window-raw-opacity-before";
        end = "window-raw-opacity";
    };
    shadow-opacity = "opacity";
    offset-x = "(1 - scale-x) / 2 * window-width";
    offset-y = "(1 - scale-y) / 2 * window-height * 5";
    scale-x = {
        curve = "cubic-bezier(0.24, 0.64, 0.79, 0.98)";
        duration = 0.15;
        start = 0.95;
        end = 1;
    };
    scale-y = "scale-x";
    shadow-scale-x = "scale-x";
    shadow-scale-y = "scale-y";
    shadow-offset-x = "offset-x";
    shadow-offset-y = "offset-y";
}, {
    triggers = ["workspace-out"];
    offset-y = {
        duration = 0.15;
        timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
        start = "0";
        end = "-window-monitor-height";
    };
    shadow-offset-y = "offset-y";
    opacity = {
        duration = 0.2;
        timing = "0.2s linear";
        start = "window-raw-opacity-before";
        end = "window-raw-opacity-before";
    };
    blur-opacity = "opacity";
    shadow-opacity = "opacity";
}, {
    triggers = ["workspace-out-inverse"];
    offset-y = {
        duration = 0.15;
        timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
        start = "0";
        end = "window-monitor-height";
    };
    shadow-offset-y = "offset-y";
    opacity = {
        duration = 0.2;
        timing = "0.2s linear";
        start = "window-raw-opacity-before";
        end = "window-raw-opacity-before";
    };
    blur-opacity = "opacity";
    shadow-opacity = "opacity";
}, {
    triggers = ["workspace-in"];
    offset-y = {
        duration = 0.15;
        timing = "0.15s cubic-bezier(0.24, 0.64, 0.79, 0.98)";
        start = "window-monitor-height";
        end = "0";
    };
    shadow-offset-y = "offset-y";
    opacity = {
        duration = 0.2;
        timing = "0.2s linear";
        start = "window-raw-opacity";
        end = "window-raw-opacity";
    };
    blur-opacity = "opacity";
    shadow-opacity = "opacity";
}, {
    triggers = ["workspace-in-inverse"];
    offset-y = {
        duration = 0.15;
        timing = "0.15s cubic-bezier(0.24, 0.64, 0.79, 0.98)";
        start = "-window-monitor-height";
        end = "0";
    };
    shadow-offset-y = "offset-y";
    opacity = {
        duration = 0.2;
        timing = "0.2s linear";
        start = "window-raw-opacity";
        end = "window-raw-opacity";
    };
    blur-opacity = "opacity";
    shadow-opacity = "opacity";
})

        '';

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

    home.packages = [ pkgs.wayback-x11 x-cursor pkgs.xbacklight ];

  };

}
