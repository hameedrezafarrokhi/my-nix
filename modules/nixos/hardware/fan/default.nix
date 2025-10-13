{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.fan;

in

{

  options.my.hardware.fan = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [ "cooler-control" "fancontrol" ]);
     default = null;

  };

  imports = [

    ./cooler-control.nix
    ./fancontrol.nix

  ];

}
