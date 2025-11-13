{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (builtins.elem "i3" config.my.window-managers) {

  services.xserver.windowManager.i3 = {
    enable = true;
    package = config.home-manager.users.${admin}.xsession.windowManager.i3.package;
    updateSessionEnvironment = true;
   #extraSessionCommands = "export XDG_MENU_PREFIX=plasma-";
    extraPackages = with pkgs; [
     #i3status             ##i3 status bar
     #i3lock               ##i3 screenlock
     #i3blocks             ##i3 blocks for status bar
      feh                  ##i3/dwm theming background
    ];
   #configFile = ;
  };

};}
