{ config, pkgs, lib, admin, mypkgs, ... }:

{ config = lib.mkIf (config.my.gaming.proton.ge.enable) {

  home.activation = {
    GE-CustomLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf "$HOME/.steam/steam/compatibilitytools.d/proton-ge-custom-ln"
      mkdir -p "$HOME/.steam/steam/compatibilitytools.d/proton-ge-custom-ln"
      ln -sf ${pkgs.proton-ge-custom}/bin/* "$HOME/.steam/steam/compatibilitytools.d/proton-ge-custom-ln"
    '';
  };

};}
