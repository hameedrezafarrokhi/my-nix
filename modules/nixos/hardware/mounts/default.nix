{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.mounts;

in

{

  options.my.hardware.mounts = lib.mkOption {

     type = lib.types.listOf (lib.types.enum [ "nirvana" "blue" "nfs" ]);
     default = [ ];

  };

  imports = [

    ./blue.nix
    ./nirvana.nix
    ./nfs.nix

  ];

}
