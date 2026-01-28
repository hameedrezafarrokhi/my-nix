{ config, lib, pkgs, mypkgs, ... }:

{ config = lib.mkIf (config.my.gaming.native-games.enable) {

  environment.systemPackages = [

   #pkgs.crosswords                    ##Crosswords game
    pkgs.space-cadet-pinball  ##Classic pinball
   #pkgs.pinball                       ##Another pinball

   #pkgs.gnome-sudoku                  ##Gnome games
   #pkgs.gnome-mahjongg                ##Gnome games
    pkgs.gnome-mines                   ##Gnome games
   #pkgs.gnome-chess                   ##Gnome games
    pkgs.gnome-nibbles                 ##Gnome games

   #pkgs.kdePackages.kapman            ##KDE games
   #pkgs.kdePackages.kbreakout         ##KDE games
   #pkgs.kdePackages.kmahjongg         ##KDE games
   #pkgs.kdePackages.knights           ##KDE games
   #pkgs.kdePackages.kpat              ##KDE games
   #pkgs.kdePackages.knavalbattle      ##KDE games
   #pkgs.kdePackages.minuet            ##KDE games (music game)

   #pkgs.extremetuxracer
   #pkgs.superTuxKart

   #pkgs.zeroad
   #pkgs.zeroad-data
   #pkgs.wesnoth
   #pkgs.hedgewars
   #pkgs.hase
   #pkgs.bzflag
   #pkgs.freeciv                       ## LOOOTS of Options
   #pkgs.megaglest
   #pkgs.warzone2100
   #pkgs.fish-fillets-ng

   #pkgs.minecraft
   #pkgs.prismlauncher

   #pkgs.brogue-ce

  ];

};}
