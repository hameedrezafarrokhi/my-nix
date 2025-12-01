{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.gaming.native-games.enable) {

  environment.systemPackages = with pkgs; [

   #crosswords                    ##Crosswords game
    space-cadet-pinball           ##Classic pinball
   #pinball                       ##Another pinball

   #gnome-sudoku                  ##Gnome games
   #gnome-mahjongg                ##Gnome games
    gnome-mines                   ##Gnome games
   #gnome-chess                   ##Gnome games
    gnome-nibbles                 ##Gnome games

   #kdePackages.kapman            ##KDE games
   #kdePackages.kbreakout         ##KDE games
   #kdePackages.kmahjongg         ##KDE games
   #kdePackages.knights           ##KDE games
   #kdePackages.kpat              ##KDE games
   #kdePackages.knavalbattle      ##KDE games
   #kdePackages.minuet            ##KDE games (music game)

   #extremetuxracer
   #superTuxKart
    vitetris
   #zeroad
   #zeroad-data
   #wesnoth
   #hedgewars
   #hase
   #bzflag
   #freeciv                       ## LOOOTS of Options
   #megaglest
   #warzone2100
   #fish-fillets-ng

   #minecraft
   #prismlauncher

  ];

};}
