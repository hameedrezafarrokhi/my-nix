{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.hardware-monitor.enable) {

  environment.systemPackages = with pkgs; [

    mission-center                ##Mission control center
    resources                     ##Mission control center
    monitorets                    ##System monitor widgets

    inspector                     ##PC hardware info
    lshw                          ##Find PCIE for gpu
    pciutils                      ##Lspci is better than lshw for pci finidng
    gpu-viewer                    ##View gpu drivers
    glxinfo

  ];

};
}
