{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.apps.bazaar.enable) {

 #home.packages = [ pkgs.bazaar_git ];

 #chaotic.bazaar = {
 #  enable = true;
 # #contentConfig = '' '';
 # #blocklist = " ";
 #};

};}
