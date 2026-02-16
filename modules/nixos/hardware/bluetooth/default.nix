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

      hsphfpd.enable = false;  # Conflict with Wireplumber

     #disabledPlugins = [ ];

     #network = { };
     #input = { };

      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
          FastConnectable = true;
        };
        Policy = {
          AutoEnable=true;
        };
      };

    };

    services.blueman.enable = false;

    environment.systemPackages = with pkgs; [

     #bluez
      bluez-tools
     #blueman
     #bluedevil

    ];

  };

}
