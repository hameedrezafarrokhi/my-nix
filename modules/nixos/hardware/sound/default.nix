{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.sound;

in

{

  options.my.hardware.sound = lib.mkOption {

     type = lib.types.nullOr (lib.types.enum [ "pipewire"
       #"pulseaudio"
       ]);
     default = null;

  };

  imports = [

    ./pipewire.nix

  ];

}
