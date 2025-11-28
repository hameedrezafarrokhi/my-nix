{ config, lib, pkgs, admin, ... }:

{

  my = {
    boot = {
      kernel = pkgs.linuxPackages_6_12;
    };
    hardware = {
      gpu = "nvidia-660m";
      mounts = [ "nirvana" ];
    };
  };

  home-manager = {

    users = {
      ${admin} = {

        my = {
          kde.appletrc = "nirvana";
          gaming.proton.sarek.enable = true;
          display = {
            primary = {
              name = "LVDS-1";
              x = "1366";
              y = "768";
              rate = "60.00";
              dpi = "";
            };
            external = {
              name = "HDMI-1";
              x = "1920";
              y = "1080";
              rate = "60.00";
              dpi = "";
              position = "right";
            };
          };
        };

      };
    };

  };

  # only on a device that doesnt have swap on it already
 #zramSwap.writebackDevice = "/dev/disk/by-uuid/f730a9d7-0671-4367-bcce-2ae1a019ffd9";

  swapDevices = [
    {
      device = "/var/swapfile";
      size = 16384; # 8192;
    }
  ];

}
