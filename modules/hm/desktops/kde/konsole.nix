{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.kde.konsole.enable) {

  programs.konsole = {
    enable = true;
    defaultProfile = config.home.username;
    profiles = {
      ${config.home.username} = {
        name = config.home.username;
       #command = "${pkgs.zsh}/bin/zsh";
       #extraConfig = {};
      };
    };
   #extraConfig = {};
   #customColorSchemes = {
   #  Konsole-catppuccin-macchiato = ../../theme/Konsole-catppuccin-macchiato.colorscheme;
   #};
  };

};}
