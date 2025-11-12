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

      # Bridge for Legacy X Apps thta dont have SNI features ( Choose One )
      snixembed.enable = true; # StandAlone and lightweight ( works great in x11 but breaks wayland wm tray )
      xembed-sni-proxy = { # Part of Plasma ecosystem ( works great in wayland but breaks x11 tray )
        enable = false;
        package = pkgs.kdePackages.plasma-workspace;
      };

      screen-locker = {
        enable = true;
        inactiveInterval = 1;
        lockCmdEnv = [
          "XSECURELOCK_PAM_SERVICE=xsecurelock"
        ];
        lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 10  -n -c 24273a -p default";
        #lib.mkDefault "${pkgs.i3lock}/bin/i3lock -n -c 000000 -f -k ";
        # "${pkgs.betterlockscreen}/bin/betterlockscreen --lock"
        xautolock = {
          enable = true;
          package = pkgs.xautolock; # pkgs.xidlehook
          detectSleep = true;
          extraOptions = [ ];
        };
        xss-lock = {
          package = pkgs.xss-lock;
          extraOptions = [ ];
          screensaverCycle = 60;
        };
      };
     #betterlockscreen = {
     #  enable = true;
     # #package = ;
     #  arguments = [ ];
     #  inactiveInterval = 10;
     #};

      xscreensaver = {
        enable = false;
        package = pkgs.xscreensaver;
        settings = {
          fadeTicks = 20;
          mode = "off"; # "blank" "random" "one"
          lock = true;
         #timeout = "0:02:00";
        };
      };

      picom ={
        enable = true;
        package = pkgs.callPackage ../../../nixos/myPackages/picom-ft.nix { };# pkgs.picom-pijulius; # pkgs.picom;
        backend = "egl"; # "egl", "glx", "xrender", "xr_glx_hybrid"

        shadow = true;
        shadowOpacity = 0.80;
       #shadowOffsets = [ 15 15 ];
        shadowExclude = [
          "name = 'Notification'"
          "class_g ?= 'Notify-osd'"
          "_GTK_FRAME_EXTENTS@:c"
        ];

        fade = true;
        fadeSteps = [ 0.05 0.05 ];
        fadeDelta = 10;
        fadeExclude = [ ];

        activeOpacity = 1.0;
        menuOpacity = 1.0;
        inactiveOpacity = 0.85;
        opacityRules = [
          "100:class_g = 'firefox'"
          "100:class_g = 'chromium'"
          "100:class_g = 'brave-browser'"
          "100:class_g = 'brave'"
          "100:class_g = 'Brave'"
         #"95:class_g =  'kitty'"
         #"95:class_g =  'dolphin'"
        ];

        settings = {
          blur = {
            method = "dual_kawase"; # "gaussian";
            size = 13;
            strength = 7;
            deviation = 6.0;
            background-frame = false;
            kern = "3x3box";
            background-exclude = [
              "window_type = 'Polybar'"
              "window_type = 'desktop'"
              "window_type = 'dock'"
             #"role = 'xborder'"
             #"class_g = 'Conky'"
             #"name = 'Notification'"
              "class_g = 'Dunst'"
             #"_GTK_FRAME_EXTENTS"
              "_GTK_FRAME_EXTENTS@:c"
            ];
          };
         #blur-kern = "3x3box";
          corner-radius = 10;
          shadow-radius = 20;
         #shadow-offset-x = "5";
         #shadow-offset-y = "-5";
          shadow-color = "#000000";
          frame-opacity = 1.0;
          inactive-opacity-override = true;
         #round-borders = 8;
          blur-background-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
            "_GTK_FRAME_EXTENTS@:c"
          ];
          rounded-corners-exclude = [
            "window_type = 'dock'"
            "window_type = 'desktop'"
            "name = 'Notification'"
            "class_g = 'i3-frame'"
            "class_g = 'rofi'"
            "class_g = 'Rofi'"
           #"class_name = 'rofi'"
            "class_g = 'dunst'"
            "class_g = 'Dunst'"
           #"class_name = 'dunst'"
          ];
          vsync = true;
          mark-wmwin-focused = true;
         #mark-ovredir-focused = true;
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
           #popup_menu = { opacity = 1.0; };
           #dropdown_menu = { opacity = 1.0; };
          };


          fade-time = 300;  # Increase fade-time to 300ms for a more gradual fade-in
          fade-duration = 400;  # Slightly longer fade-duration for a smoother transition
          no-fading-openclose = true;  # Keep this to prevent fade during open/close transitions
          no-fading-destroyed-argb = true;

          glx-use-copysubbuffer-mesa = true;
         #glx-copy-from-front = true;
         #glx-swap-method = 2;
          xrender-sync = true;
          xrender-sync-fence = true;


        };

        # FT LABS CONFIG
        extraConfig = ''

# fly-in: Windows fly in from random directions to the screen
# maximize: Windows pop from center of the screen to their respective positions
# minimize: Windows minimize from their position to the center of the screen
# slide-in-center: Windows move from upper-center of the screen to their respective positions
# slide-out-center: Windows move to the upper-center of the screen
# slide-left: Windows are created from the right-most window position and slide leftwards
# slide right: Windows are created from the left-most window position and slide rightwards
# slide-down: Windows are moved from the top of the screen and slide downward
# slide-up: Windows are moved from their position to top of the screen
# squeeze: Windows are either closed or created to/from their center y-position (the animation is similar to a blinking eye)
# squeeze-bottom: Similar to squeeze, but the animation starts from bottom-most y-position
# zoom: Windows are either created or destroyed from/to their center (not the screen center)

animations = true;
#change animation speed of windows in current tag e.g open window in current tag
animation-stiffness-in-tag = 40;
#change animation speed of windows when tag changes
animation-stiffness-tag-change = 40.0;

animation-window-mass = 0.25;
animation-dampening = 1;
animation-clamping = true;

#open windows
animation-for-open-window = "zoom";
#minimize or close windows
animation-for-unmap-window = "squeeze";
#popup windows
animation-for-transient-window = "slide-down"; #available options: slide-up, slide-down, slide-left, slide-right, squeeze, squeeze-bottom, zoom

#set animation for windows being transitioned out while changings tags
animation-for-prev-tag = "minimize";
#"minimize";
#enables fading for windows being transitioned out while changings tags
enable-fading-prev-tag = false;

#set animation for windows being transitioned in while changings tags
animation-for-next-tag = "slide-in-center";
#"slide-in-center";
#enables fading for windows being transitioned in while changings tags
enable-fading-next-tag = false;

        '';

         # PIJULIUS CONFIG
#        extraConfig = ''
#animations = (
#    {
#        triggers = ["close", "hide"];
#        opacity = {
#            curve = "linear";
#            duration = 0.2;  # Slightly longer duration for smoother opacity fade
#            start = "window-raw-opacity-before";
#            end = 0;
#        };
#        shadow-opacity = "opacity";
#        scale-x = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.4;  # Smoother zoom-out
#            start = 1;  # Start at full size
#            end = 0;  # Zoom out to 0
#        };
#        scale-y = "scale-x";
#        shadow-scale-x = "scale-x";
#        shadow-scale-y = "scale-y";
#
#        # Adjust offsets to zoom from the center
#        offset-x = "(1 - scale-x) / 2 * window-width";
#        offset-y = "(1 - scale-y) / 2 * window-height";
#        shadow-offset-x = "offset-x";
#        shadow-offset-y = "offset-y";
#
#        # Add blur effect during close
#        blur = {
#            curve = "linear";
#            duration = 0.4;  # Smooth blur fade
#            start = 0;
#            end = 10;  # Max blur (you can adjust this value for stronger/weaker blur)
#        };
#    },
#    {
#        triggers = ["open", "show"];
#        opacity = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.2;  # Smoother fade-in with longer duration
#            start = 0;
#            end = "window-raw-opacity";
#        };
#        offset-x = "(1 - scale-x) / 2 * window-width";  # Start from center
#        offset-y = "(1 - scale-y) / 2 * window-height";  # Start from center
#        scale-x = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.4;  # Slower zoom-in for smooth effect
#            start = 0;  # Start very small
#            end = 1;  # Zoom in to full size
#        };
#        scale-y = "scale-x";
#        shadow-scale-x = "scale-x";
#        shadow-scale-y = "scale-y";
#        shadow-offset-x = "offset-x";
#        shadow-offset-y = "offset-y";
#    },
#    {
#        triggers = ["geometry"];
#        scale-x = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.2;  # Smoother scaling
#            start = "window-width-before / window-width";
#            end = 1;
#        };
#        scale-y = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.4;  # Smoother scaling
#            start = "window-height-before / window-height";
#            end = 1;
#        };
#        offset-x = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.4;  # Smoother positioning
#            start = "window-x-before - window-x";
#            end = 0;
#        };
#        offset-y = {
#            curve = "cubic-bezier(0.25,0.8,0.25,1)";  # Smooth easing curve
#            duration = 0.4;  # Smoother positioning
#            start = "window-y-before - window-y";
#            end = 0;
#        };
#        shadow-scale-x = "scale-x";
#        shadow-scale-y = "scale-y";
#        shadow-offset-x = "offset-x";
#        shadow-offset-y = "offset-y";
#    },
#    {
#        triggers = ["workspace-out"];
#        offset-x = {
#            duration = 0.15;
#            timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#            start = "0";
#            end = "-window-monitor-height";
#        };
#        shadow-offset-x = "offset-x";
#        opacity = {
#            duration = 0.15;
#            timing = "0.15s linear";
#            start = "window-raw-opacity-before";
#            end = "window-raw-opacity-before";
#        };
#        blur-opacity = "opacity";
#        shadow-opacity = "opacity";
#    },
#    {
#        triggers = ["workspace-out-inverse"];
#        offset-x = {
#            duration = 0.15;
#            timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#            start = "0";
#            end = "window-monitor-height";
#        };
#        shadow-offset-x = "offset-x";
#        opacity = {
#            duration = 0.15;
#            timing = "0.15s linear";
#            start = "window-raw-opacity-before";
#            end = "window-raw-opacity-before";
#        };
#        blur-opacity = "opacity";
#        shadow-opacity = "opacity";
#    },
#    {
#        triggers = ["workspace-in-inverse"];
#        offset-x = {
#            duration = 0.15;
#            timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#            start = "-window-monitor-height";
#            end = "0";
#        };
#        shadow-offset-x = "offset-x";
#        opacity = {
#            duration = 0.15;
#            timing = "0.15s linear";
#            start = "window-raw-opacity";
#            end = "window-raw-opacity";
#        };
#        blur-opacity = "opacity";
#        shadow-opacity = "opacity";
#    },
#    {
#        triggers = ["workspace-in"];
#        offset-x = {
#            duration = 0.15;
#            timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#            start = "window-monitor-height";
#            end = "0";
#        };
#        shadow-offset-x = "offset-x";
#        opacity = {
#            duration = 0.15;
#            timing = "0.15s linear";
#            start = "window-raw-opacity";
#            end = "window-raw-opacity";
#        };
#        blur-opacity = "opacity";
#        shadow-opacity = "opacity";
#    },
#    {
#       triggers = ["focus-change"];
#       scale-x = {
#           curve = "cubic-bezier(0.25,0.8,0.25,1)";
#           duration = 0.2;
#           start = 0.95;
#           end = 1;
#       };
#       scale-y = "scale-x";
#       opacity = {
#           curve = "linear";
#           duration = 0.2;
#           start = 0.8;
#           end = 1;
#       };
#    }
#
#)
#        '';



         # PIJULIUS CONFIG NUMBER2
#        extraConfig = ''
#animations = ({
#    triggers = ["close", "hide"];
#    opacity = {
#        curve = "linear";
#        duration = 0.15;
#        start = "window-raw-opacity-before";
#        end = "window-raw-opacity";
#    };
#    blur-opacity = "0";
#    shadow-opacity = "opacity";
#    offset-x = "(1 - scale-x) / 2 * window-width";
#    offset-y = "(1 - scale-y) / 2 * window-height * 5";
#    scale-x = {
#        curve = "cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#        duration = 0.15;
#        start = 1;
#        end = 0.9;
#    };
#    scale-y = "scale-x";
#    shadow-scale-x = "scale-x";
#    shadow-scale-y = "scale-y";
#    shadow-offset-x = "offset-x";
#    shadow-offset-y = "offset-y";
#}, {
#    triggers = ["open", "show"];
#    opacity = {
#        curve = "linear";
#        duration = 0.15;
#        start = "window-raw-opacity-before";
#        end = "window-raw-opacity";
#    };
#    blur-opacity = {
#        curve = "linear";
#        duration = 0.1;
#        delay = 0.15;
#        start = "window-raw-opacity-before";
#        end = "window-raw-opacity";
#    };
#    shadow-opacity = "opacity";
#    offset-x = "(1 - scale-x) / 2 * window-width";
#    offset-y = "(1 - scale-y) / 2 * window-height * 5";
#    scale-x = {
#        curve = "cubic-bezier(0.24, 0.64, 0.79, 0.98)";
#        duration = 0.15;
#        start = 0.95;
#        end = 1;
#    };
#    scale-y = "scale-x";
#    shadow-scale-x = "scale-x";
#    shadow-scale-y = "scale-y";
#    shadow-offset-x = "offset-x";
#    shadow-offset-y = "offset-y";
#}, {
#    triggers = ["workspace-out"];
#    offset-y = {
#        duration = 0.15;
#        timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#        start = "0";
#        end = "-window-monitor-height";
#    };
#    shadow-offset-y = "offset-y";
#    opacity = {
#        duration = 0.2;
#        timing = "0.2s linear";
#        start = "window-raw-opacity-before";
#        end = "window-raw-opacity-before";
#    };
#    blur-opacity = "opacity";
#    shadow-opacity = "opacity";
#}, {
#    triggers = ["workspace-out-inverse"];
#    offset-y = {
#        duration = 0.15;
#        timing = "0.15s cubic-bezier(0.21, 0.02, 0.76, 0.36)";
#        start = "0";
#        end = "window-monitor-height";
#    };
#    shadow-offset-y = "offset-y";
#    opacity = {
#        duration = 0.2;
#        timing = "0.2s linear";
#        start = "window-raw-opacity-before";
#        end = "window-raw-opacity-before";
#    };
#    blur-opacity = "opacity";
#    shadow-opacity = "opacity";
#}, {
#    triggers = ["workspace-in"];
#    offset-y = {
#        duration = 0.15;
#        timing = "0.15s cubic-bezier(0.24, 0.64, 0.79, 0.98)";
#        start = "window-monitor-height";
#        end = "0";
#    };
#    shadow-offset-y = "offset-y";
#    opacity = {
#        duration = 0.2;
#        timing = "0.2s linear";
#        start = "window-raw-opacity";
#        end = "window-raw-opacity";
#    };
#    blur-opacity = "opacity";
#    shadow-opacity = "opacity";
#}, {
#    triggers = ["workspace-in-inverse"];
#    offset-y = {
#        duration = 0.15;
#        timing = "0.15s cubic-bezier(0.24, 0.64, 0.79, 0.98)";
#        start = "-window-monitor-height";
#        end = "0";
#    };
#    shadow-offset-y = "offset-y";
#    opacity = {
#        duration = 0.2;
#        timing = "0.2s linear";
#        start = "window-raw-opacity";
#        end = "window-raw-opacity";
#    };
#    blur-opacity = "opacity";
#    shadow-opacity = "opacity";
#})
#       '';

       #extraArgs = { };

      };

    };

  };

}
