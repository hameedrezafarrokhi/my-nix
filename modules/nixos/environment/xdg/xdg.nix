{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.xdg.enable) {

  xdg = {
    menus.enable = true;
    sounds.enable = true;
    autostart.enable = true;
    icons = {
      enable = true;
     #fallbackCursorThemes = [ "default" "breeze_cursors" "Breeze Dark" "Catppuccin Macchiato Sapphire" "Nordic-cursors" ];
    };
  };

  # XDG autostart files for sessions without a desktop manager
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

};}
