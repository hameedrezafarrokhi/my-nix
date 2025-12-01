{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.printer;

in

{

  options.my.hardware.printer.enable = lib.mkEnableOption "enable printers";

  config = {

    services.printing = {
      enable = if cfg.enable then true else false;
      openFirewall = true;
    };

  };

}
