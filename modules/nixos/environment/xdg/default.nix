{ config, pkgs, lib, ... }:

let

  cfg = config.my.xdg;

in

{

  options.my.xdg.enable = lib.mkEnableOption "enable xdg";

  imports = [

    ./portals.nix
    ./mimes.nix
    ./xdg.nix
    ./default-apps.nix

  ];

}
