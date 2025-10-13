{ config, pkgs, lib, inputs, system, ... }:

{ config = lib.mkIf (builtins.elem "waybar" config.my.bar-shell.shells) {

  programs.waybar = {
    enable = true;
    package = pkgs.waybar;

    systemd = {
      enable = false;
      target = config.wayland.systemd.target;
      enableInspect = false;
      enableDebug = false;
    };

   #style = { };
   #settings = {
   #  mainBar = {
   #    layer = "top";
   #    position = "top";
   #    height = 30;
   #    output = [
   #      "eDP-1"
   #      "HDMI-A-1"
   #    ];
   #    modules-left = [ "sway/workspaces" "sway/mode" "wlr/taskbar" ];
   #    modules-center = [ "sway/window" "custom/hello-from-waybar" ];
   #    modules-right = [ "mpd" "custom/mymodule#with-css-id" "temperature" ];
   #
   #    "sway/workspaces" = {
   #      disable-scroll = true;
   #      all-outputs = true;
   #    };
   #    "custom/hello-from-waybar" = {
   #      format = "hello {}";
   #      max-length = 40;
   #      interval = "once";
   #      exec = pkgs.writeShellScript "hello-from-waybar" ''
   #        echo "from within waybar"
   #      '';
   #    };
   #  };
   #};

  };

  systemd.user.services.waybar-niri = {
    Unit = {
      Description = "Highly customizable Wayland bar for Sway and Wlroots based compositors.";
      Documentation = "https://github.com/Alexays/Waybar/wiki";
      PartOf = [
        config.programs.waybar.systemd.target
        "tray.target"
      ];
      After = [ config.programs.waybar.systemd.target ];
      ConditionEnvironment = "DESKTOP_SESSION=niri";
      X-Reload-Triggers =
        lib.optional (config.programs.waybar.settings != [ ]) "${config.xdg.configFile."waybar/config".source}"
        ++ lib.optional (config.programs.waybar.style != null) "${config.xdg.configFile."waybar/style.css".source}";
    };

    Service = {
      Environment = lib.optional config.programs.waybar.systemd.enableInspect "GTK_DEBUG=interactive";
      ExecReload = "${pkgs.coreutils}/bin/kill -SIGUSR2 $MAINPID";
      ExecStart = "${config.programs.waybar.package}/bin/waybar${lib.optionalString config.programs.waybar.systemd.enableDebug " -l debug"}";
      KillMode = "mixed";
      Restart = "on-failure";
    };

    Install.WantedBy = [
      config.programs.waybar.systemd.target
      "tray.target"
    ];
  };



};}
