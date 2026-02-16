{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.tools.enable) {

  programs = {

    wireshark = {
      enable = false;
      package = pkgs.wireshark;
      usbmon.enable = true;
      dumpcap.enable = true;
    };

    mtr = {
      enable = false;
      package = pkgs.mtr-gui;
    };

  };

  environment.systemPackages = [
    pkgs.nethogs
  ];

};}
