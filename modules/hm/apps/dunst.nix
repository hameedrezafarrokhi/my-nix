{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.dunst.enable) {

  services.dunst = {
    enable = true;
    package = pkgs.dunst;
   #waylandDisplay = "";
   #configFile = ;
    settings = {
      global = {
       #icon_path = '' '';
        offset = "(27,60)";
        history_length = 50;
       #close = ctrl+space
       #close_all = ctrl+shift+space
       #history = "ctrl+grave";
       #context = "ctrl+alt+period";
      };
    };
   #iconTheme = {
   #  package = ;
   #  name = ;
   #  size = ;
   #};
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
