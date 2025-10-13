{ config, pkgs, lib, admin, mypkgs, ... }:

{ config = lib.mkIf (config.my.gaming.proton.cachy.enable) {

  home.activation = {
    CachyLink = lib.hm.dag.entryAfter ["writeBoundary"] ''
      rm -rf "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
      mkdir -p "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
      ln -sf ${pkgs.proton-cachyos}/bin/* "$HOME/.steam/steam/compatibilitytools.d/proton-cachy-ln"
    '';
  };

};}
