{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.hardware-monitor.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #htop                          ##System monitor cli
   #btop

   #mission-center                ##Mission control center
    resources                     ##Mission control center
   #monitorets                    ##System monitor widgets

   #inspector                     ##PC hardware info
   #lshw                          ##Find PCIE for gpu
    pciutils                      ##Lspci is better than lshw for pci finidng
   #gpu-viewer                    ##View gpu drivers
   #mesa-demos                    # FORMER NAME: glxinfo

  ] ) config.my.software.hardware-monitor.exclude)

   ++

  config.my.software.hardware-monitor.include;

  programs = {

    htop = {
      enable = true;
      package = pkgs.htop;
     #settings = {};
    };

  };

};}
