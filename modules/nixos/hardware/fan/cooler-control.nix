{ config, pkgs, lib, ... }:

{ config = lib.mkIf (config.my.hardware.fan == "cooler-control") {

  # Fans
  programs.coolercontrol = {
    enable = true;
   #nvidiaSupport = lib.elem "nvidia" config.services.xserver.videoDrivers;
  };

};}
