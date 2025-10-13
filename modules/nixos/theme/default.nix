{ config, pkgs, lib, ... }:

let

  cfg = config.my.systemTheme;

in

{

  options.my.systemTheme = lib.mkOption {

    type = lib.types.nullOr (lib.types.str);
    default = null;

  };

  imports = [ ./catppuccin-uni.nix ];

}
