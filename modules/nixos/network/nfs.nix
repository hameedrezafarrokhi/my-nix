{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.network.nfs.enable) {

  services.rpcbind.enable = true;

};}
