{ config, pkgs, lib, inputs, ... }:

let

  cfg = config.my.qtile;

in

{

  options.my.qtile.enable = lib.mkEnableOption "qtile";

  config = lib.mkIf cfg.enable {

    xdg.configFile = {

     #qtile-conf = {
     #  target = "qtile/";
     #  source = ./.;
     #};

    };

  };

}
