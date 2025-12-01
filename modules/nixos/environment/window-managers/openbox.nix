{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "openbox" config.my.window-managers) {

  services.xserver.windowManager.openbox.enable = true;

  environment.systemPackages = [

    pkgs.obconf
    pkgs.jgmenu

  ];

};}
