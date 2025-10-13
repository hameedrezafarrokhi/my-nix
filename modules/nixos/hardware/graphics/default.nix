{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.gpu;

in

{

  options.my.hardware.gpu = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [ "nvidia-660m" "amd" "none" ]);
     default = null;

  };

  imports = [

    ./amd.nix
    ./nvidia-660m.nix
    ./none.nix

  ];

}
