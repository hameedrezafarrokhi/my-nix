{ config, pkgs, lib, ... }:

let

  nmreload = pkgs.writeShellScriptBin "nmreload" ''
    active=$(nmcli -t -f NAME,DEVICE connection show --active | head -1 | cut -d: -f1)
    nmcli connection down "$active"
    sleep 0.5
    nmcli connection up "$active"
  '';

  nmdown = pkgs.writeShellScriptBin "nmdown" ''
    active=$(nmcli -t -f NAME,DEVICE connection show --active | head -1 | cut -d: -f1)
    nmcli connection down "$active"
  '';

in

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
    pkgs.netpeek
    pkgs.networkmanager_dmenu
    nmreload
    nmdown
  ];

};}
