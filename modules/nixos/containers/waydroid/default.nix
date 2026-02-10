{ config, pkgs, lib, ... }:

let

  cfg = config.my.containers.waydroid;

in

{

  options.my.containers.waydroid.enable = lib.mkEnableOption "enable waydroid";

  config = lib.mkIf (cfg.enable) {

    virtualisation.waydroid = {
      enable = true;
      package = pkgs.waydroid;
    };
    environment.systemPackages = with pkgs; [
      waydroid                                ##Android Emulator
      waydroid-helper                         ##Waydroid Helper
     #nur.repos.ataraxiasjel.waydroid-script  ##Script for ARM Compatibility
     #fdroidcl                                ##Alternative AppStore
     #fdroidserver                            ##Alternative AppStore
     #(callPackage ../../myPackages/waydroid-script.nix { })
    ];

  };

}
