{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.fusuma.enable) {

  services.fusuma = {
    enable = true;
    package = pkgs.fusuma;
    extraPackages = [ ];
   #settings = { };
  };

};}
