{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.cpu.brand == "amd") {

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = true;

};}
