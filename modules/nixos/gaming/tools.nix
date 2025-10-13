{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.gaming.tools.enable) {

  environment.systemPackages = with pkgs; [

   #gamescope                     ##FSR stuff
   #gamemode                      ##Ferral gamemode optimization
    mangohud                      ##FPS overlay
    goverlay                      ##FPS overlay GUI
    mangojuice                    ##Goverlay alternative
    protonplus                    ##Proton stuff
    protonup-qt                   ##Proton stuff
   #protonup-ng
   #protonup-rs
   #protontricks                  ##Proton stuff
    ludusavi                      ##Scan all games launcher
    cartridges                    ##Export game saves

  ];

};}
