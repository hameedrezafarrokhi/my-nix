{ config, pkgs, lib, ... }:

let

  cfg = config.my.shells;

in

{

  options.my.shells = lib.mkOption {
     type = lib.types.listOf (lib.types.enum [ "bash" "fish" "zsh" ]);
     default = [ "bash" ];
  };
  options.my.defaultShell = lib.mkOption {
     type = lib.types.str;
     default = "bash";
  };

  options.my.shellAliases = lib.mkEnableOption "shell aliases";

  imports = [

    ./bash.nix
    ./fish.nix
    ./aliases.nix

  ];

}
