{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.wine.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #wine-staging

   #winePackages.stagingFull
   #winePackages.fonts

   #wineWowPackages.stagingFull   ## Wine latest 64/32
   #wineWowPackages.stable        ## Wine stable 64/32
    wineWowPackages.stableFull
   #wineWowPackages.waylandFull   ## Wine wayland 64/32
   #wineWowPackages.fonts

   #wineWow64Packages.stagingFull ## Wine 64 only
   #wineWow64Packages.fonts

   #winetricks                    ## Winetricks stuff
   #bottles                       ## Run windows app/games

  ] ) config.my.software.wine.exclude)

   ++

  config.my.software.wine.include;

};}
