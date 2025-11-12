{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "i3" config.my.window-managers) {

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
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
