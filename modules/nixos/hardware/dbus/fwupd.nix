{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.hardware.fwupd.enable) {

  services.fwupd = {
    enable = true;
    package = pkgs.fwupd;
   #extraRemotes = [ ];
   #daemonSettings = { };
   #uefiCapsuleSettings = { };
   #extraTrustedKeys = { };
    daemonSettings = {
      EspLocation = config.boot.loader.efi.efiSysMountPoint;
     #DisabledPlugins = [ ];
     #DisabledDevices = [ ];
    };
  };

};}
