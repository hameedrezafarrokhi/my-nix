{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.cpu.brand == "intel") {

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = true;

};}
