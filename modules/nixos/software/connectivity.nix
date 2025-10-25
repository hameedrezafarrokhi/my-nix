{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.connectivity.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    scrcpy                        ##Andriod screen mirror
    qtscrcpy

  ] ) config.my.software.connectivity.exclude)

   ++

  config.my.software.connectivity.include;

};}
