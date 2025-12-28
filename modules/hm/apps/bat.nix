{ config, pkgs, lib, mypkgs, ... }:

{ config = lib.mkIf (config.my.apps.bat.enable) {

  programs.bat = {

    enable = true;
    package = mypkgs.stable.bat;
    extraPackages = with mypkgs.stable.bat-extras; [
     #core
      batdiff
      batman
      batwatch
      batpipe
      batgrep
      prettybat
    ];
   #config = { };
   #syntaxes = { };
   #themes = { };

  };

};}
