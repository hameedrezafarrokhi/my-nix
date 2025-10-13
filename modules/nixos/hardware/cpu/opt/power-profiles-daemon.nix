{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.hardware.cpu.opt == "power-profiles-daemon") {

  # Using Builtin KDE Tool
  services.power-profiles-daemon = {
    enable = true;
    package = pkgs.power-profiles-daemon;
  };

};}
