{ config, pkgs, lib, ... }:

{
config = lib.mkIf (config.my.apps.btop.enable) {

  programs.btop = {
    enable = true;
    package = pkgs.btop;
   #settings = {};
   #extraConfig = '' '';
   #themes = {};
  };

};
}
