{ config, pkgs, lib, ... }:

let

  cfg = config.my.bar-shell;

in

{

  options.my.bar-shell = {

    shells = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [

       "ags"
       "quickshell"
       "waybar"
       "polybar"
       "tint2"
       "trayer"

     ]);
     default = [ ];

    };

  };

  imports = [

    ./ags.nix
    ./quickshell.nix
    ./waybar.nix
    ./polybar.nix
    ./tint2.nix
    ./trayer.nix

  ];

}
