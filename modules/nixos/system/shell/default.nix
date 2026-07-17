{ config, pkgs, lib, ... }:

let

  cfg = config.my.shell;

in

{

  options.my.shell = {

    shells = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [ "bash" "fish" "zsh" "dash" "nu" ]);
     default = [ ];

    };

    default = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [ "bash" "fish" "zsh" "dash" "nu" ]);
     default = null;

    };

    alias.enable =  lib.mkEnableOption "enable general aliases";

  };

  imports = [ ./bash.nix ./fish.nix ./zsh.nix ./dash.nix ./nu.nix ];


}
