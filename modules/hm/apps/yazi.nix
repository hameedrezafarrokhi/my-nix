{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.yazi.enable) {

  programs.yazi = {
    enable = true;
    package = pkgs.yazi;
   #plugins = {};
    enableBashIntegration = true;
   #enableZshIntegration = true;
   #enableFishIntegration = true;
   #enableNushellIntegration = true;
   #flavors = {};
   #theme = {};
   #initLua = ./   .lua;
   #keymap = {};
   #settings = {};
   #shellWrapperName = "yy";
  };

};
}
