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

};}
