{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.hardware.fwupd.enable) {

  services.rpcbind.enable = true;

};}
