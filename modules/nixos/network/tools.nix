{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.tools.enable) {

  programs = {

    wireshark = {
      enable = true;
      package = pkgs.wireshark;
      usbmon.enable = true;
      dumpcap.enable = true;
    };

    mtr = {
      enable = true;
      package = pkgs.mtr-gui;
    };

  };

};}
