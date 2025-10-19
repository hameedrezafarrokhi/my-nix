{ config, lib, pkgs, admin, ... }:

{

  my = {
    boot = {
      kernel = pkgs.linuxPackages_6_12;
    };
    hardware = {
      gpu = "nvidia-660m";
      mounts = [ "nirvana" "blue" ];
    };
  };

  home-manager = {
    users = {
      ${admin} = {
        my = {
          kde = {
            appletrc = "nirvana";
          };
        };
      };
    };
  };

 #zramSwap.writebackDevice = "/dev/disk/by-uuid/f730a9d7-0671-4367-bcce-2ae1a019ffd9";

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 8192;
    }
  ];

}
