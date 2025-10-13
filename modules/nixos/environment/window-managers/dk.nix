{ config, pkgs, lib, myStuff, ... }:

{ config = lib.mkIf (builtins.elem "dk" config.my.window-managers) {

  services.xserver.windowManager.dk = {
    enable = true;
    package = pkgs.dk; #Apply Patches here with Overrides
  #extraSessionCommands = "";
  };

};}
