{ config, pkgs, lib, admin, mypkgs, ... }:

let

  proton-sarek-async = pkgs.callPackage ../../nixos/myPackages/sarek.nix { };

in

{ config = lib.mkIf (config.my.gaming.proton.ge.enable) {

  home.activation = {
    SarekLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf "$HOME/.steam/steam/compatibilitytools.d/proton-sarek-ln"
      mkdir -p "$HOME/.steam/steam/compatibilitytools.d/proton-sarek-ln"
      ln -sf ${proton-sarek-async.steamcompattool}/* "$HOME/.steam/steam/compatibilitytools.d/proton-sarek-ln"
    '';
  };

};}
