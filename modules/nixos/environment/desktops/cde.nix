{ config, pkgs, lib, mypkgs, ... }:

{ config = lib.mkIf (builtins.elem "cde" config.my.desktops) {

  services.xserver.desktopManager.cde = {
    enable = true;
    extraPackages = with pkgs; [
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
