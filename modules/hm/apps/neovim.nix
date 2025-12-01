{ config, pkgs, lib,  ... }:

{ config = lib.mkIf (config.my.apps.neovim.enable) {

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
   #extraPackages = [ ];
   #plugins = [ ];
    withNodeJs = false;
    withPython3 = true;
    withRuby = true;
   #extraWrapperArgs = [ ];
   #finalPackage = ;
    defaultEditor = true;
   #extraConfig = '' '';
   #settings = { };
   #generatedConfigs = { };
   #generatedConfigViml = '' '';
   #coc = {};
    viAlias = false;
    vimAlias = false;
    vimdiffAlias = false;

  };

};}
