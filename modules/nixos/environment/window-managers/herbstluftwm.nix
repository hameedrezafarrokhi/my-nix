{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "herbstluftwm" config.my.window-managers) {

  services.xserver.windowManager.herbstluftwm = {
    enable = true;
    package = pkgs.herbstluftwm;
   #configFile = ;
  };

};}
