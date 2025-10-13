{ config, pkgs, lib, ... }:

let

  cfg = config.my.network;

in

{

  options.my.network = {

    enable = lib.mkEnableOption "enable tpm";
    ssh.enable  = lib.mkEnableOption "enable ssh";
    vpn.enable  = lib.mkEnableOption "enable vpn softwares";
    shares.enable  = lib.mkEnableOption "network sharing tools, samba nfs dleyna etc";
    avahi.enable  = lib.mkEnableOption "avahi mDNS things";
    nm-applet.enable  = lib.mkEnableOption "nm-applet";
    nfs.enable  = lib.mkEnableOption "nfs";

  };

  imports = [

    ./networking.nix
    ./ssh.nix
    ./vpn.nix
    ./shares.nix
    ./avahi.nix
    ./nm-applet.nix
    ./nfs.nix

  ];

}
