{ config, lib, pkgs, ... }:

let

  cfg = config.my.x11;

in

{

  options.my.x11.enable = lib.mkEnableOption "x11 settings";

  config = lib.mkIf cfg.enable {

    services.xserver.enable = true;

    services.xserver.displayManager.startx = {
      enable = true;
      generateScript = true;
     #extraCommands = '' '';
    };

    environment.systemPackages = [
      pkgs.wayback-x11
     #pkgs.i3status             ##i3 status bar
     #pkgs.i3lock               ##i3 screenlock
     #pkgs.i3blocks             ##i3 blocks for status bar
     #pkgs.picom                ##i3/dwm main compositor
      pkgs.feh                  ##i3/dwm theming background
     #pkgs.dunst                ##i3/dwm notification daemon
     #pkgs.lxappearance         ##i3/dwm theming client
      pkgs.dmenu                ##i3/dwm app launcher menu
      pkgs.rofi                 ##i3/dwm app launcher menu (alternative)
      pkgs.xclip                ## Clipboard_manager
      pkgs.variety              ## Wallpaper_manager
     #pkgs.plank                ## Dock
    ];

    programs = {
      i3lock = {
        enable = true;
        u2fSupport = true;
        package = pkgs.i3lock-fancy-rapid; # pkgs.i3lock;
      };
    };

    security.wrappers.xscreensaver-auth = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${pkgs.xscreensaver}/libexec/xscreensaver/xscreensaver-auth";
    };

  };

}
