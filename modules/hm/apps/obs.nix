{ config, pkgs, lib,  ... }:

{ config = lib.mkIf (config.my.apps.obs.enable) {

  programs.obs-studio = {
    enable = true;
    package = pkgs.obs-studio;
    plugins = [
      pkgs.obs-studio-plugins.wlrobs
      pkgs.obs-studio-plugins.obs-vaapi
      pkgs.obs-studio-plugins.obs-media-controls
      pkgs.obs-studio-plugins.droidcam-obs
      pkgs.obs-studio-plugins.obs-vkcapture
      pkgs.obs-studio-plugins.obs-gstreamer
      pkgs.obs-studio-plugins.obs-pipewire-audio-capture
    ];
  };

};}
