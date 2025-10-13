{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "notion" config.my.window-managers) {

  services.xserver.windowManager.notion.enable = true;

};}
