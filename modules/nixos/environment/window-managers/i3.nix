{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "i3" config.my.window-managers) {

  services.xserver.windowManager.i3 = {
    enable = true;
    package = pkgs.i3;
    updateSessionEnvironment = true;
   #extraSessionCommands = "export XDG_MENU_PREFIX=plasma-";
    extraPackages = with pkgs; [
      i3status             ##i3 status bar
      i3lock               ##i3 screenlock
      i3blocks             ##i3 blocks for status bar
     #picom                ##i3/dwm main compositor
      feh                  ##i3/dwm theming background       i
     #dunst                ##i3/dwm notification daemon
     #lxappearance         ##i3/dwm theming client
      dmenu                ##i3/dwm app launcher menu
      rofi                 ##i3/dwm app launcher menu (alternative)
      grim                 ##i3/dwm screenshot_functionality
      slurp                ##i3/dwm screenshot_functionality
      xclip                ## Clipboard_manager
      variety              ## Wallpaper_manager
      plank                ## Dock
    ];
   #configFile = ;
  };

};}
