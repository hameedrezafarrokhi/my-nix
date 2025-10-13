{ config, lib, pkgs, mypkgs, admin, ... }:

{

  my = {
    hardware = {
      gpu = "amd";
      mounts = [ "blue" "nfs" ];
    };
  };

  home-manager = {
    users = {
      ${admin} = {
        my = {
          kde = {
            appletrc = "blue";
          };
        };
      };
    };
  };

}
