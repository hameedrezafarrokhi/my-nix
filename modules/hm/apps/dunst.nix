{ config, pkgs, lib, ... }:

let

  dunst-sound-toggle = pkgs.writeShellScriptBin "dunst-sound-toggle" ''
    if [ -f $HOME/.cache/dunst-mute ]; then
      rm $HOME/.cache/dunst-mute
      notify-send -e -u low -t 2000 "Notification Sounds" "On"
    else
      touch $HOME/.cache/dunst-mute
      notify-send -e -u low -t 2000 "Notification Sounds" "Off"
    fi
  '';

  dunst-notif-center = pkgs.callPackage ../../nixos/myPackages/dunst-notif-center/default.nix { };

in

{ config = lib.mkIf (config.my.apps.dunst.enable) {

  home.packages = [
    dunst-sound-toggle
  ];

  services.dunst = {

    enable = true;
    package = pkgs.dunst;

   #waylandDisplay = "";
   #configFile = ;

    settings = {

      global = {
        history_length = 50;
        follow = "keyboard";
       #close = ctrl+space
       #close_all = ctrl+shift+space
       #history = "ctrl+grave";
       #context = "ctrl+alt+period";
      };
      urgency_low = {
        timeout = 10;
      };
      urgency_normal = {
        timeout = 20;
      };
      urgency_critical = {
        timeout = 30;
      };

    };

  };

  systemd.user.services.dunst = {
   #Unit = {
   #  ConditionEnvironment = "!XDG_SESSION_DESKTOP=Hyprland-Caelestia";
   #};
    Service = {
      ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER i3 || pgrep -u $USER sway || || pgrep -u $USER bspwm'";
    };
  };

  systemd.user.services.dunst-notif-center = {
    Unit = {
     Description = "Dunst Notification Center";
     ConditionEnvironment = "XDG_CURRENT_DESKTOP=none+bspwm";
     X-Restart-Triggers = [ "${config.xdg.configHome}/dunst-notif-center/config.toml" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${dunst-notif-center}/bin/dunst-notif-center -d";
      Restart = "on-failure";
      KillMode = "mixed";
      TimeoutStopSec = 5;
    };
   #Install = {
   #  WantedBy = [ "graphical-session.target" ];
   #};
  };

};}
