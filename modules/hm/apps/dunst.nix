{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.dunst.enable) {

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
