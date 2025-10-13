{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.superfile.enable) {

  programs.superfile = {
    enable = true;
    package = pkgs.superfile;
    metadataPackage = pkgs.exiftool;
    hotkeys = {
      confirm = [
        "enter"
        "right"
        "l"
      ];
    };
    settings = {
      default_sort_type = 0;
    };
  };

};}
