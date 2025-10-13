{ config, pkgs, lib, ... }:

let

  cfg = config.my.boot.bootloader;

in

{

  options.my.boot.bootloader = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [ "systemd-boot" "grub" "limine" "refind" ]);
     default = null;

  };

  imports = [
    ./systemd-boot.nix
    ./grub.nix
    ./limine.nix
    ./refind.nix
  ];

}
