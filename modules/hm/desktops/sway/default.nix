{ config, pkgs, lib, ... }:

let

  cfg = config.my.i3;

in

{

  options.my.sway.enable = lib.mkEnableOption "sway";

  config = lib.mkIf cfg.enable {

    wayland.windowManager.sway = {
      enable = true;
     #package = pkgs.sway;
      xwayland = true;
      checkConfig = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };

     #extraSessionCommands = '' '';
     #extraConfigEarly = '' '';
     #extraConfig = '' '';
      extraOptions = [
        "--unsupported-gpu"
      ];

      config = {

       #assigns = { };

        workspaceLayout = "default"; # "tabbed" "" default" "stacking"
        workspaceAutoBackAndForth = false;
        terminal = config.my.default.terminal;
        modifier = "Mod4";
        menu = "${pkgs.rofi}/bin/rofi -show drun"; # "${pkgs.dmenu}/bin/dmenu_run";
        defaultWorkspace = "workspace number 1";

        modes = config.xsession.windowManager.i3.config.modes;

       #keycodebindings = { };
        keybindings = config.xsession.windowManager.i3.config.keybindings;

        floating = config.xsession.windowManager.i3.config.floating;

       #workspaceOutputAssign = {
       #  "*" = {
       #    workspace
       #    output
       #  };
       #};

        window = config.xsession.windowManager.i3.config.window;

        startup = [
         #{
         # #workspace
         # #notification
         #  command = "feh --bg-fill /home/hrf/Pictures/Wallpapers/background.png";
         #  always = true;
         #}
         #{ command = "export XDG_CURRENT_DESKTOP=i3"; always = true; }
         #{ command = "export XDG_SESSION_DESKTOP=i3"; always = true; }
         #{ command = "export XDG_MENU_PREFIX=plasma-"; always = true; }
         #{ command = "waybar"; always = true; }
        ];

        gaps = config.xsession.windowManager.i3.config.gaps;

        focus = config.xsession.windowManager.i3.config.focus;

      };

      swaynag = {
        enable = true;
       #settings = { };
      };

      systemd = {
        enable = true;
        dbusImplementation = "broker";
        xdgAutostart = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user reset-failed"
          "systemctl --user start sway-session.target"
          "swaymsg -mt subscribe '[]' || true"
          "systemctl --user stop sway-session.target"
        ];
      };

    };

    programs = {

      sway-easyfocus = {
        enable = true;
        package = pkgs.sway-easyfocus;
       #settings = { };
      };

      swayimg = {
        enable = true;
        package = pkgs.swayimg;
       #settings = { };
      };

      swaylock = {
        enable = true;
        package = pkgs.swaylock;
       #settings = { };
      };

      swayr = {
        enable = true;
        package = pkgs.swayr;
       #settings = { };
        systemd = {
          enable = true;
          target = config.wayland.systemd.target;
        };
      };

    };

    services = {

      swayidle = {
        enable = true;
        package = pkgs.swayidle;
        systemdTarget = config.wayland.systemd.target;
        events = [
          { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
          { event = "lock"; command = "lock"; }
        ];
        timeouts = [
          { timeout = 3600; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
	    { timeout = 5400; command = "${pkgs.systemd}/bin/systemctl suspend"; }
        ];
        extraArgs = [ "-w" ];
      };

      swaync = {
        enable = true;
        package = pkgs.swaynotificationcenter;
       #settings = { };
       #style = '' '';
      };

      swayosd = {
        enable = true;
        package = pkgs.swayosd;
       #stylePath = "";
       #topMargin = 1.0;
      };

    };

    systemd.user.services = {

      swayrd.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";

      swayidle.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=none";
      swaync.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=none";
      swayosd.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=none";


      swaync-sway = {
        Unit = {
          Description = "Swaync notification daemon";
          Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          X-Restart-Triggers = lib.mkMerge [
            [ "${config.xdg.configFile."swaync/config.json".source}" ]
            (lib.mkIf (config.services.swaync.style != null) [ "${config.xdg.configFile."swaync/style.css".source}" ])
          ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
         #Type = "dbus";
         #BusName = "org.freedesktop.Notifications";
          ExecStart = "${lib.getExe config.services.swaync.package}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ config.wayland.systemd.target ];
      };

      swayidle-sway = {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ config.services.swayidle.systemdTarget ];
          After = [ config.services.swayidle.systemdTarget ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
          Type = "simple";
          Restart = "always";
          # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
          Environment = [ "PATH=${lib.makeBinPath [ pkgs.bash ]}" ];
          ExecStart =
            let
              mkTimeout =
                t:
                [
                  "timeout"
                  (toString t.timeout)
                  t.command
                ]
                ++ lib.optionals (t.resumeCommand != null) [
                  "resume"
                  t.resumeCommand
                ];

              mkEvent = e: [
                e.event
                e.command
              ];
              args =
                config.services.swayidle.extraArgs ++ (lib.concatMap mkTimeout config.services.swayidle.timeouts) ++ (lib.concatMap mkEvent config.services.swayidle.events);
            in
            "${lib.getExe config.services.swayidle.package} ${lib.escapeShellArgs args}";
        };
        Install = {
          WantedBy = [ config.services.swayidle.systemdTarget ];
        };
      };

      swayosd-sway = {
        Unit = {
          Description = "Volume/backlight OSD indicator";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          Documentation = "man:swayosd(1)";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 10;
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
          Type = "simple";
          ExecStart =
            "${config.services.swayosd.package}/bin/swayosd-server"
            + (lib.optionalString (config.services.swayosd.stylePath != null) " --style ${lib.escapeShellArg config.services.swayosd.stylePath}")
            + (lib.optionalString (config.services.swayosd.topMargin != null) " --top-margin ${toString config.services.swayosd.topMargin}");
          Restart = "always";
          RestartSec = "2s";
        };
        Install = {
          WantedBy = [ config.wayland.systemd.target ];
        };
      };

    };

  };

}
