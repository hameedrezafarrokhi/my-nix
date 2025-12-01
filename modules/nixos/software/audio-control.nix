{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.audio-control.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

     #helvum                        ##Pipewire control
     #qpwgraph                      ##Pipewire control (Another)
     #easyeffects                   ##Audio effect for Pipewire
     #jamesdsp                      ##Audio effect for Pipewire (Unstable Bad)

      pavucontrol                   ##Pulseaudio control
     #jamesdsp-pulse                ##Audio effect for Pulseaudio

  ] ) config.my.software.audio-control.exclude)

   ++

  config.my.software.audio-control.include;

};}
