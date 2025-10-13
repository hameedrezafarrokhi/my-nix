{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.hardware.fan == "fancontrol") {

  hardware.fancontrol = {
    enable = true;   # REQUIRES CONFIG
   #config = '' '';

  };

};}
