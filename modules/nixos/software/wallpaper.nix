{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.wallpaper.enable) {

  environment.systemPackages = with pkgs; [

   #linux-wallpaperengine                ##Live Wallpapers
   #kdePackages.wallpaper-engine-plugin  ##Wallpaper-engine kde plugin
    kdePackages.qtmultimedia             ##Backend stuff
   #komorebi
    mpvpaper
    paperview

  ];

};
}
