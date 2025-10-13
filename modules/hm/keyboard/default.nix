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
     #options = ;

    };

  };

}
