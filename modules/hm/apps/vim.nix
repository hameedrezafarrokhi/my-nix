{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.vim.enable) {

  programs.vim = {
    enable = true;
   #package = pkgs.vim-full;
   #plugins = [ ];
   #defaultEditor = false;
   #extraConfig = '' '';
   #settings = { };
  };

};}
