{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.ghostty.enable) {

  programs.ghostty = {

    enable = true;
    package = pkgs.ghostty;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;

    installVimSyntax = false;
    installBatSyntax = true;

    clearDefaultKeybinds = false;

    settings = {

    };

   #theme = { };

  };

};}
