{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.display-manager == "lemur") {

  services.xserver.enable = true;

  services.displayManager.lemurs = {
    enable = true;
    package = pkgs.lemurs;
   #settings = { };
  };

};}
