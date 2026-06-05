{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.helix.enable) {

  programs.helix = {

    enable = true;
    package = pkgs.helix; # pkgs.evil-helix
    extraPackages = [ pkgs.marksman ];
    languages = { };

    defaultEditor = false;
    ignores = [ ];
    settings = { };
    extraConfig = '' '';
   #themes = { };

  };

};}
