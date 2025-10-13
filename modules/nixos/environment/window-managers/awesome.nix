{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "awesome" config.my.window-managers) {

  services.xserver.windowManager.awesome = {
    enable = true;
    package = pkgs.awesome;
    luaModules = [ pkgs.luaPackages.vicious pkgs.luaPackages.awesome-wm-widgets ];
    noArgb = false;
  };

};}
