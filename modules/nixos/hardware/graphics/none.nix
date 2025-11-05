{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.hardware.gpu == "none") {

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

};}
