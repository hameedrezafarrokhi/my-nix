{ config, pkgs, lib, admin, mypkgs, ... }:

let

  proton-cachyos = pkgs.callPackage ../../nixos/myPackages/proton-cachyos.nix { };

in

{ config = lib.mkIf (config.my.gaming.proton.cachy.enable) {

  home.activation = {
    CachyLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
      mkdir -p "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
      ln -sf ${proton-cachyos.steamcompattool}/* "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
    '';
  };

};}
