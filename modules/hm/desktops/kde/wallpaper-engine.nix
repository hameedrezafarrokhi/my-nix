{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.kde.wallpaper-engine.enable) {

  home.packages = [ pkgs.kdePackages.wallpaper-engine-plugin ];

  services.linux-wallpaperengine = {
    enable = true;
    package = pkgs.linux-wallpaperengine;
    clamping = null; # one of "clamp", "border", "repeat"
    assetsPath = "${config.home.homeDirectory}/Videos/Hidamari";
   #wallpapers = [
   #
   #];
  };

};
}
