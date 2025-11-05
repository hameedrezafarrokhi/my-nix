{ config, lib, pkgs, admin, ... }:

{

 #my = { };

  home-manager = {
    users = {
      ${admin} = {
        my = {
          kde = {
            appletrc = "red";
          };
        };
      };
    };
  };

 #zramSwap.writebackDevice = "/dev/disk/by-uuid/f730a9d7-0671-4367-bcce-2ae1a019ffd9";

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 16384; # 8192;
    }
  ];

}
