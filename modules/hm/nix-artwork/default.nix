{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.nix-artwork;

in

{

  options.my.nix-artwork.enable =  lib.mkEnableOption "nix-artwork";

  config = lib.mkIf cfg.enable {

    home.activation = {
      nix-artwork = lib.hm.dag.entryAfter ["writeBoundary"] ''
        rm -rf "$HOME/Pictures/nix-artwork"
        mkdir -p "$HOME/Pictures/nix-artwork"
        ln -sf ${inputs.nix-artwork}/* "$HOME/Pictures/nix-artwork"
      '';
    };

  };

}
