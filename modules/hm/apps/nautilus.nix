{ config, pkgs, lib, ... }:

  with lib.hm.gvariant;

{ config = lib.mkIf (config.my.apps.nautilus.enable) {

  dconf.settings = {

   #"com/github/stunkymonkey/nautilus-open-any-terminal" = {
   #  terminal = config.my.default.terminal;     # WARNING NOT WORKING
   #};

    "org/gtk/settings/file-chooser" = {
     #date-format = "regular";
     #location-mode = "path-bar";
     #show-hidden = true;
     #show-size-column = true;
     #show-type-column = true;
     #sidebar-width = 162;
     #sort-column = "name";
      sort-directories-first = true;
     #sort-order = "descending";
     #type-format = "category";
     #window-position = mkTuple [ 0 24 ];
     #window-size = mkTuple [ 671 674 ];
    };

  };

  home.packages = [
    pkgs.nautilus-open-any-terminal
  ];

};}
