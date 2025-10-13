{ config, pkgs, lib, ... }:

let

  cfg = config.my.gaming;

in

{

  options.my.gaming = {

    proton = {
      cachy.enable = lib.mkEnableOption "enable cachy proton";
      ge.enable = lib.mkEnableOption "enable ge proton";
      sarek.enable = lib.mkEnableOption "enable ge proton";
    };

  };

  imports = [

    ./proton-sarek.nix
    ./proton-ge.nix
    ./proton-cachy.nix

  ];

}
