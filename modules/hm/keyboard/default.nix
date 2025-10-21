{ config, pkgs, lib, ... }:

let

  cfg = config.my.keyboard;

in

{

  options.my.keyboard = {

    xremap.enable = lib.mkEnableOption "enable xremap keyboard mapping";

  };

  imports = [

    ./xremap.nix

  ];

  config = {

    home.keyboard = {

      layout = "us,ir";
     #model = ;
     #variant = ;
      options = [

       #"grp:caps_toggle"
        "terminate:ctrl_alt_bksp"
        "grp:alt_shift_space_toggle"

      ];

    };

  };

}
