{ config, pkgs, lib, ... }:

let

  cfg = config.my.niri;

in

{

  options.my.niri.enable = lib.mkEnableOption "niri";

  config = lib.mkIf cfg.enable {

   #services = {
   #  polkit-gnome = {
   #    enable = true;
   #    package = pkgs.polkit_gnome;
   #  };
   #};

    programs.niriswitcher = {

      enable = true;
      package = pkgs.niriswitcher;
     #style = ; # Path or '' extra css ''
      settings = {
        keys = {
          modifier = "Alt";
          switch = {
            next = "Tab";
            prev = "Shift+Tab";
          };
        };
        center_on_focus = true;
        appearance = {
          system_theme = "dark";
          icon_size = 64;
        };
      };

    };

    services = lib.mkDefault {

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

      swaync-niri = {
        Unit = {
          Description = "Swaync notification daemon";
          Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          X-Restart-Triggers = lib.mkMerge [
            [ "${config.xdg.configFile."swaync/config.json".source}" ]
            (lib.mkIf (config.services.swaync.style != null) [ "${config.xdg.configFile."swaync/style.css".source}" ])
          ];
          ConditionEnvironment = "DESKTOP_SESSION=niri";
        };
        Service = {
         #Type = "dbus";
         #BusName = "org.freedesktop.Notifications";
          ExecStart = "${lib.getExe config.services.swaync.package}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ config.wayland.systemd.target ];
      };

      swayidle-niri = {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ config.services.swayidle.systemdTarget ];
          After = [ config.services.swayidle.systemdTarget ];
          ConditionEnvironment = "DESKTOP_SESSION=niri";
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

      swayosd-niri = {
        Unit = {
          Description = "Volume/backlight OSD indicator";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          Documentation = "man:swayosd(1)";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 10;
          ConditionEnvironment = "DESKTOP_SESSION=niri";
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

  imports = [

    ./niri-dms.nix
    ./niri-noctalia.nix

  ];

}
