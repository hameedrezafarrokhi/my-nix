{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.printer;

in

{

  options.my.hardware.printer.enable = lib.mkEnableOption "enable printers";

  config = lib.mkIf cfg.enable {

    services.printing = {
      enable = true;
      openFirewall = true;
    };

  };

}
