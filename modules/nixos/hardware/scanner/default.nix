{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.scanner;

in

{

  options.my.hardware.scanner.enable = lib.mkEnableOption "enable scanners";

  config = lib.mkIf cfg.enable {

    hardware.sane = {
      enable = true;
      backends-package = pkgs.sane-backends;
      extraBackends = [ pkgs.hplipWithPlugin pkgs.sane-airscan pkgs.kdePackages.libksane pkgs.kdePackages.ksanecore ];
      openFirewall = true;
     #disabledDefaultBackends = [ "escl" ];
     #netConf = "";
     #snapshot = true; # dev driver
    };
    services = {
      udev.packages = [ pkgs.sane-airscan ];
      ipp-usb.enable = true;
    };

  };

}
