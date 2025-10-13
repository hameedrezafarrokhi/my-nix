{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.ram-tmp;

in

{

  options.my.hardware.ram-tmp = {

    zram.enable = lib.mkEnableOption "enable zram";
    tmpfs.enable =  lib.mkEnableOption "enable tmpfs";

  };

  imports = [

    ./zram.nix
    ./tmpfs.nix

  ];

}
