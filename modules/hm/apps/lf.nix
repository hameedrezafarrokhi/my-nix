{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.lf.enable) {

  programs.lf = {
    enable = true;
    package = pkgs.lf;
   #settings = {};
   #keybindings = {};
   #cmdKeybindings = {};
   #commands = {};
   #extraConfig = '' '';
   #previewer = {
   # keybinding = "";
   # source = pkgs. ;
   #};
  };

};}
