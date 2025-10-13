{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "lumina" config.my.desktops) {

  services.xserver.desktopManager.lumina.enable = true;

};}
