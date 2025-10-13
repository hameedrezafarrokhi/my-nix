{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.software.wine.enable) {

  environment.systemPackages = with pkgs; [

   wine-staging

   #winePackages.stagingFull
   #winePackages.fonts

   #wineWowPackages.stagingFull   ## Wine latest 64/32
   #wineWowPackages.stable        ## Wine stable 64/32
   #wineWowPackages.waylandFull   ## Wine wayland 64/32
   #wineWowPackages.fonts

   #wineWow64Packages.stagingFull ## Wine 64 only
   #wineWow64Packages.fonts

    winetricks                    ## Winetricks stuff
   #bottles                       ## Run windows app/games

  ];

};}
