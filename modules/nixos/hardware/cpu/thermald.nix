{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.hardware.cpu.thermald.enable) {

  services.thermald = {
    enable = true;
    ignoreCpuidCheck = true;
    package = pkgs.thermald;
    debug = false;
   #configFile = ;  ##(NO Needed)

  };

};}
