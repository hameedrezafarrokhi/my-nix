{ config, pkgs, lib, ... }:

{

  options.my.hardware.fusuma= {
    enable = lib.mkEnableOption "fusuma touch guesture daemon";
  };

  config = lib.mkIf (config.my.hardware.fusuma.enable) {
    environment.systemPackages = [
      pkgs.fusuma
    ];
  };

}
