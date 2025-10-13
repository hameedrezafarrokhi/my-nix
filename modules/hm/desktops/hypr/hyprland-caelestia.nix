{ inputs, config, pkgs, lib, system, ... }:

let


in

{ config = lib.mkIf (builtins.elem "hyprland-caelestia" config.my.rices-shells) {

  programs.quickshell = {
    enable = true;
    systemd.enable = false;
  };

  home.packages = [
    inputs.caelestia-shell.packages.${system}.default
    inputs.caelestia-cli.packages.${system}.default
  ];

  programs.caelestia = {
    enable = true;
    package = inputs.caelestia-shell.packages.${system}.default;
    systemd = {
      enable = false;
     #target = "";
    };
   #environment = [ ]; # Variables
    settings = {
      appearance = {
        anim = {
          durations = {
            scale = 0.8;
          };
        };
        font = {
          family = {
            material = "Material Symbols Rounded";
            mono = "Comic Mono";
            sans = "Comic Sans MS";
          };
          size = {
            scale = 0.9;
          };
        };
        padding = {
          scale = 1;
        };
        rounding = {
          scale = 1;
        };
        spacing = {
          scale = 0.9;
        };
        transparency = {
          enabled = true;
          base = 0.9;
          layers = 0.85;
        };
      };
      general = {
        apps = {
          terminal = ["kitty"];
          audio = ["pavucontrol"];
        };
      };
      background = {
        desktopClock = {
          enabled = true;
        };
        enabled = true;
      };
      bar = {
        dragThreshold = 20;
        sizes = {
          innerWidth = 35;
        };
        entries = [
          {
   	       id = "logo";
   	       enabled = true;
   	    }
   	    {
   	       id = "workspaces";
   	       enabled = true;
   	    }
   	    {
   	       id = "spacer";
   	       enabled = true;
   	    }
   	    {
   	       id = "activeWindow";
   	       enabled = true;
   	    }
   	    {
   	       id = "spacer";
   	       enabled = true;
   	    }
   	    {
   	       id = "tray";
   	       enabled = true;
   	    }
   	    {
   	       id = "clock";
   	       enabled = true;
   	    }
   	    {
   	       id = "statusIcons";
   	       enabled = true;
   	    }
   	    {
   	       id = "power";
   	       enabled = true;
   	    }
        ];
        persistent = true;
        showOnHover = true;
        status = {
          showAudio = true;
          showBattery = true;
          showBluetooth = true;
          showKbLayout = true;
          showNetwork = true;
        };
        tray = {
          background = false;
          recolour = true;
        };
        workspaces = {
          activeIndicator = true;
          activeLabel = "󰮯";
          activeTrail = false;
          label = "  ";
          occupiedBg = false;
          occupiedLabel = "󰮯";
          perMonitorWorkspaces = true;
          showWindows = true;
          shown = "5";
        };
      };
      border = {
        rounding = 25;
        thickness = 10;
      };
      dashboard = {
        enabled = true;
        dragThreshold = 50;
        mediaUpdateInterval = 500;
        showOnHover = true;
        visualiserBars = 45;
      };
      launcher = {
        actionPrefix = ">";
        dragThreshold = 50;
        vimKeybinds = false;
        enableDangerousActions = true;
        maxShown = 8;
        maxWallpapers = 30;
        useFuzzy = {
          apps = true;
          actions = true;
          schemes = true;
          variants = true;
          wallpapers = true;
        };
      };
      lock = {
        recolourLogo = true;
      };
      notifs = {
        actionOnClick = false;
        clearThreshold = 0.3;
        defaultExpireTimeout = 5000;
        expandThreshold = 20;
        expire = false;
      };
      osd = {
        hideDelay = 2000;
      };
      paths = {
        mediaGif = "root:/assets/bongocat.gif";
        sessionGif = "root:/assets/kurukuru.gif";
        wallpaperDir = "~/Pictures/Wallpapers";
      };
      services = {
        audioIncrement = 0.1;
        weatherLocation = "10,10";
        useFahrenheit = false;
        useTwelveHourClock = false;
        smartScheme = true;
      };
      session = {
        dragThreshold = 30;
        vimKeybinds = false;
        commands = {
          logout = ["loginctl" "terminate-user" ""];
          shutdown = ["systemctl" "poweroff"];
          hibernate = ["systemctl" "hibernate"];
          reboot = ["systemctl" "reboot"];
        };
      };
    };
   #extraConfig = "";

    cli = {
      enable = true;
      package = inputs.caelestia-cli.packages.${system}.default;
     #settings = {};
     #extraConfig = "{}";
    };
  };

  systemd.user.services.caelestia-hypr-uwsm = {
    Unit = {
      Description = "Caelestia Shell Service";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
     #ConditionEnvironment = "XDG_SESSION_DESKTOP=Hyprland-Caelestia";
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Caelestia-uwsm";
    };
    Service = {
      Type = "exec";
      ExecStart = "${inputs.caelestia-shell.packages.${system}.default}/bin/caelestia-shell";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "5s";
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_QPA_PLATFORMTHEME=qt6ct"
      ];
      Slice = "session.slice";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

  systemd.user.services.caelestia-hypr = {
    Unit = {
      Description = "Caelestia Shell Service";
      After = ["graphical-session.target"];
      PartOf = ["graphical-session.target"];
     #ConditionEnvironment = "XDG_SESSION_DESKTOP=Hyprland-Caelestia";
      ConditionEnvironment = "DESKTOP_SESSION=Hyprland-Caelestia";
    };
    Service = {
      Type = "exec";
      ExecStart = "${inputs.caelestia-shell.packages.${system}.default}/bin/caelestia-shell";
      Restart = "on-failure";
      RestartSec = "5s";
      TimeoutStopSec = "5s";
      Environment = [
        "QT_QPA_PLATFORM=wayland"
        "QT_QPA_PLATFORMTHEME=qt6ct"
      ];
      Slice = "session.slice";
    };
    Install = {
      WantedBy = ["graphical-session.target"];
    };
  };

};}
