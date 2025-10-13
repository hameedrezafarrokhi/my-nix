{ config, pkgs, lib, ... }:

let

  cfg = config.my.theme;

in

{

  options.my.theme = lib.mkOption {

    type = lib.types.nullOr (lib.types.str);
    default = null;

  };

  imports = [ ./catppuccin-uni.nix ];

}
