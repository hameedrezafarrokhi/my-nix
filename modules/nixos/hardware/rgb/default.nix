{ config, pkgs, lib, ... }:

{

  options.my.hardware.rgb = {

    enable = lib.mkEnableOption "rgb stuff";

  };

  config = {

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
