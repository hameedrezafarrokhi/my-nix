{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "polybar" config.my.bar-shell.shells) {

  services.polybar = {

    enable = true;
    package = pkgs.polybarFull;

   #config = {};  # For path usage, otherwise use "settings"
   #extraConfig = '' '';

    script = "polybar example &";  # Script to run polybar like "polybar bar &"

    settings = {

      "bar/example" = {
        width = "100%";
        height = "18pt";
        radius = 6;
       #dpi = 96;
        modules = {
          left = "memory cpu filesystem";
          center = "xworkspaces";
          right = "lock tray pulseaudio date hour";
        };
        cursor-click = "pointer";
        cursor-scroll = "ns-resize";
        enable-ipc = true;
       #tray-position = "right";
       #wm-restack = "generic";
       #wm-restack = "bspwm";
       #wm-restack = :i3";
       #override-redirect = true;
      };

      "module/xworkspaces" = {
        type = "internal/xworkspaces";
        label-active = "%name%";
        label-active-padding = 1;
        label-occupied = "%name%";
        label-occupied-padding = 1;
        label-urgent = "%name%";
        label-urgent-padding = 1;
        label-empty = "";
        label-empty-padding = 0;
      };

      "module/xwindow" = {
        type = "internal/xwindow";
        label = "%title:0:75:...%";
      };

      "module/filesystem" = {
        type = "internal/fs";
        interval = 25;
        mount-0 = "/";
        label-unmounted = "%mountpoint% not mounted";
      };

      "module/pulseaudio" = {
        type = "internal/pulseaudio";
        format-volume-prefix = ''"VOL "'';
        format-volume = "<label-volume>";
        label-volume = "%percentage%%";
        label-muted = "muted";
      };

      "module/lock" = {
        type = "internal/xkeyboard";
       #ignore = ;
        format-margin = 2;
        blacklist-0 = "num lock";
        blacklist-1 = "scroll lock";
        format = "<label-indicator>";
        label-indicator-padding = 1;
        indicator-icon-0 = "caps lock;-CL;+CL";
        label-indicator-off = "";
        label-indicator-on = ''"  Caps "'';
      };

      "module/memory" = {
        type = "internal/memory";
        interval = 2;
        format-prefix = ''"RAM "'';
        label = "%percentage_used:2%%";
      };

      "module/cpu" = {
        type = "internal/cpu";
        interval = 02;
        format-prefix = ''"CPU "'';
        label = "%percentage:2%%";
      };

      "network-base" = {
        type = "internal/network";
        interval = 5;
        format-connected = "<label-connected>";
        format-disconnected = "<label-disconnected>";
      };

      "module/wlan" = {
        "inherit" = "network-base";
        interface-type = "wireless";
      };

      "module/eth" = {
        "inherit" = "network-base";
        interface-type = "wired";
      };

      "module/hour" = {
        type = "internal/date";
        interval = 5;
        date = "%l:%M %p";
        label = "%date%";
        label-padding = 0;
        label-font = 1;
      };

      "module/date" = {
        type = "custom/script";
        interval = 5;
        format = "<label>";
        exec = ''"LC_TIME="en_us_utf8" date +"%a, %b %-d""'';
        label-padding = 0;
        label-font = 1;
        click-left = "gsimplecal";
      };

      "module/tray" = {
        type = "internal/tray";
        tray-spacing = "4px";
      };

      "settings" = {
        screenchange-reload = true;
        pseudo-transparency = true ;
      };

    };

  };

  systemd.user.services.polybar = {
   #enable = {
   # enable = false;
   #};
    Unit = {
     #Description = "Polybar status bar";
     #PartOf = [ "tray.target" ];
     #X-Restart-Triggers = mkIf (configFile != null) "${configFile}";
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=none";
    };
   #Service = {
   #  Type = "forking";
   #  Environment = [ "PATH=${cfg.package}/bin:/run/wrappers/bin" ];
   #  ExecStart =
   #    let
   #      scriptPkg = pkgs.writeShellScriptBin "polybar-start" cfg.script;
   #    in
   #    "${scriptPkg}/bin/polybar-start";
   #  Restart = "on-failure";
   #};
   #
   #Install = {
   #  WantedBy = [ "tray.target" ];
   #};
  };

};}
