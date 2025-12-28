{ config, pkgs, lib,  ... }:

{ config = lib.mkIf (config.my.apps.mpv.enable) {

  programs.mpv = {
    enable = true;
    package = pkgs.mpv;

   #includes = [ ]mpvScripts.;

   #bindings = { };

    config = {
      loop = "inf";
      keep-open = "yes";
      hwdec-codecs = "all";
     #hwdec = "vaapi";
     #vo-vaapi-scaling = "fast";
    };
   #extraInput = '' '';

   #profiles = { };
   #defaultProfiles = [ ];

    scripts = with pkgs.mpvScripts; [
      uosc
      mpris
    ];
   #scriptOpts = { };

  };

};}
