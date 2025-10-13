{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.fd.enable) {

  programs.fd = {
    enable = true;
    package = pkgs.fd;
    hidden = true;
    extraOptions = [ ];
    ignores = [ ];
  };

};}
