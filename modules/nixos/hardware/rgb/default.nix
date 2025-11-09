{ config, pkgs, lib, ... }:

{

  options.my.hardware.rgb = {

    enable = lib.mkEnableOption "rgb stuff";

  };

  config = lib.mkIf config.my.hardware.rgb.enable {

    services = {

      hardware.openrgb = {
        package = pkgs.openrgb-with-all-plugins;
        enable = true;
       #motherboard = " ";  # "amd" "intel" null
       #server.port = 6742;
      };

    };

  };

}
