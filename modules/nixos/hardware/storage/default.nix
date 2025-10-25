{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.storage;

in

{

  options.my.hardware.storage.enable = lib.mkEnableOption "enable storage optimizations";

  config = lib.mkIf cfg.enable {

    boot.supportedFilesystems = [ "ntfs" ];

    services.udisks2 = {
      enable = true;
      package = pkgs.udisks2;
      mountOnMedia = true;
      settings = {
        "udisks2.conf" = {
          defaults = {
            encryption = "luks2";
          };
          udisks2 = {
            modules = [
              "*"
            ];
            modules_load_preference = "ondemand";
          };
        };
      };
    };

    services.fstrim = {
      enable = true;
      interval = "weekly";
    };

    # Times out for sata drives
   #hardware.sata.timeout = {
   #  enable = true;
   #  deciSeconds = 70; # 0 is disable
   # #drives = {
   # #  <device-name> = {   # without specifying the drive, Nothing happens
   # #    name = " "; # sda sdb sdc ...
   # #    idBy = "path"; # one of "path", "wwn"
   # #  };
   # #};
   #};

    # gracefully shutdown HDDs during reboot/shutdwon
    hardware.usbStorage.manageShutdown = true;

    programs = {
      usbtop.enable = true; #btop for usb and bus bandwidth
    };

    environment.systemPackages = with pkgs; [

      ntfs3g                        ##Protocol for NTFS
     #samba4Full                         ##Protocol for NAS
      nfs-utils                     ##Protocol for NAS
      fuse                          ##allows filesystems for stuff
     #fuse3                         ##another version of FUSE

    ];

  };

}
