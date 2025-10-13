{ config, pkgs, lib, ... }:

{

  options.my.hardware.bluetooth = {

    enable = lib.mkEnableOption "enable bluetooth";

  };

  config = lib.mkIf (config.my.hardware.bluetooth.enable) {

    hardware.bluetooth = {
      enable = true;
      package = pkgs.bluez;
      powerOnBoot = true;
      settings = {
        Policy = {
          AutoEnable=true;
        };
      };
    };
    services.blueman.enable = true;

    environment.systemPackages = with pkgs; [

     #bluez
      bluez-tools
     #blueman
     #bluedevil

    ];

  };

}
