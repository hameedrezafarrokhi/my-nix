{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "cde" config.my.desktops) {

  services.xserver.desktopManager.cde = {
    enable = true;
    extraPackages = with pkgs.xorg; [
      xclock
      bitmap
      xlsfonts
      xfd xrefresh
      xload xwininfo
      xdpyinfo
      xwd
      xwud
    ];
  };

};}
