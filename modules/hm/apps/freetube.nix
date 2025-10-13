{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.freetube.enable) {

  programs.freetube = {
    enable = true;
    package = pkgs.freetube;
    settings = {
      allowDashAv1Formats = true;
      checkForUpdates     = false;
      defaultQuality      = "360";
    };
  };

};
}
