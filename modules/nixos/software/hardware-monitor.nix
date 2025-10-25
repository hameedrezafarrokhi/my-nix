{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.hardware-monitor.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    mission-center                ##Mission control center
    resources                     ##Mission control center
    monitorets                    ##System monitor widgets

    inspector                     ##PC hardware info
    lshw                          ##Find PCIE for gpu
    pciutils                      ##Lspci is better than lshw for pci finidng
    gpu-viewer                    ##View gpu drivers
    glxinfo

  ] ) config.my.software.hardware-monitor.exclude)

   ++

  config.my.software.hardware-monitor.include;

};}
