{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.display-manager == "cosmic-greeter") {

  services.xserver.enable = true;

  services.displayManager.cosmic-greeter = {
    enable = true;
    package = pkgs.cosmic-greeter;
  };

};}
