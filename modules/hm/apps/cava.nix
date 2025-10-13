{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.cava.enable) {

  programs = {
    cava = {
      enable = true;
      package = pkgs.cava; # cavalier; cavalcade;
     #settings = { # example:
     #  general.framerate = 60;
     #  input.method = "alsa";
     #  smoothing.noise_reduction = 88;
     #  color = {
     #    background = "'#000000'";
     #    foreground = "'#FFFFFF'";
     #};

    };

    cavalier = {
      enable = true;
      package = pkgs.cavalier;
      settings = {
	 #cava = {}; # same as above
	 #general = {  # example:
       #  ShowControls = true;
       #  ColorProfiles = [
       #    {
       #      Name = "Default";
       #      FgColors = [
       #        "#ffed333b"
       #        "#ffffa348"
       #        "#fff8e45c"
       #        "#ff57e389"
       #        "#ff62a0ea"
       #        "#ffc061cb"
       #      ];
       #      BgColors = [
       #        "#ff1e1e2e"
       #      ];
       #      Theme = 1;
       #    }
       #  ];
       #  ActiveProfile = 0;
	 #};
      };
    };
  };

};}
