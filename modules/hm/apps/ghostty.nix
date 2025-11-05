{ config, pkgs, lib, mypkgs, ... }:

{ config = lib.mkIf (config.my.apps.ghostty.enable) {

  programs.ghostty = {

    enable = true;
    package = mypkgs.stable.ghostty;
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
