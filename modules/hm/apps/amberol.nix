{config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.vim.enable) {

  services.amberol = {
    enable = true;
    package = pkgs.amberol;
    enableRecoloring = true;
    replaygain = "track"; # "album", "track", "off"
  };

};}
