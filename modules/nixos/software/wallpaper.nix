{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.wallpaper.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #linux-wallpaperengine                ##Live Wallpapers
   #kdePackages.wallpaper-engine-plugin  ##Wallpaper-engine kde plugin
    kdePackages.qtmultimedia             ##Backend stuff
   #komorebi
    mpvpaper
    paperview
    xwinwrap

  ] ) config.my.software.wallpaper.exclude)

   ++

  config.my.software.wallpaper.include;

};}
