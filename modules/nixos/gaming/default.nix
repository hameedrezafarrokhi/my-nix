{ config, pkgs, lib, ... }:

let

  cfg = config.my.gaming;

in

{

  options.my.gaming = {

    steam.enable = lib.mkEnableOption "enable steam";
    launchers.enable = lib.mkEnableOption "enable launchers";
    native-games.enable = lib.mkEnableOption "some natve games collection";
    tools.enable = lib.mkEnableOption "gaming tools and softwares";
    emulators.enable = lib.mkEnableOption "emulation softwares";

  };

  imports = [

    ./steam.nix
    ./native-games.nix
    ./launchers.nix
    ./tools.nix
    ./emulators.nix

  ];

}
