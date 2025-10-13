{ config, pkgs, lib, myStuff, ... }:

{ config = lib.mkIf (builtins.elem "dwl" config.my.window-managers) {

  programs.dwl = {
    enable = true;
    package = pkgs.dwl; #Apply Patches here with Overrides
  #extraSessionCommands = "";
  };

};}
