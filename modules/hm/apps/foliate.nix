{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.foliate.enable) {

  programs.foliate = {
    enable = true;
    package = pkgs.foliate;
   #themes = { # example:
   #  label = "My Theme";
   #  light = {
   #    fg = "#89b4fa";
   #    bg = "#1e1e2e";
   #    link = "#89b4fa";
   #  };
   #  dark = { };
   #};
   #settings = { # example:
   #  myTheme = {
   #    color-scheme = 0;
   #    library = {
   #      view-mode = "grid";
   #      show-covers = true;
   #    };
   #    "viewer/view" = {
   #      theme = "myTheme.json";
   #    };
   #    "viewer/font" = {
   #      monospace = "Maple Mono";
   #      default-size = 12;
   #    };
   #  };
   #};
  };

};}
