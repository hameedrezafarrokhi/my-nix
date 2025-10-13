{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.gaming.launchers.enable) {

  environment.systemPackages = with pkgs; [

   #steam                         ##STEAM
   #steam-run                     ##STEAM hack for non-nix-packages
    lutris                        ##Lutris launcher
    heroic
   #(heroic.override {
   #  extraPkgs = pkgs: [
   #    pkgs.gamescope
   #    pkgs.gamemode
   #  ]; } )
    umu-launcher                  ##Umu (steam without steam)
    nero-umu
   #heroic-unwrapped              ##Heroic launcher FSH

  ];

};}
