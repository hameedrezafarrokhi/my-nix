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
       "ashell"
       "polybar"
       "tint2"
       "trayer"
       "ignis"

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
    ./ashell.nix
    ./ignis.nix

  ];

}
