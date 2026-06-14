{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.ram-tmp;

in

{

  options.my.hardware.ram-tmp = {

    zram.enable = lib.mkEnableOption "enable zram";
    tmpfs.enable =  lib.mkEnableOption "enable tmpfs";
    nohang.enable =  lib.mkEnableOption "enable nohang";

  };

  imports = [

    ./zram.nix
    ./tmpfs.nix
    ./nohang.nix

  ];

}
