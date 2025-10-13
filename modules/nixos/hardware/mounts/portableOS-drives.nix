{ config, pkgs, lib, ... }:

{

  # (nofail means system starts if drive isnt available)
  # (rw mean read/write access to drive)

  # Local Laptop drivers

 fileSystems."/mnt/laptop-debian" = {
   device = "/dev/disk/by-uuid/09bc68a7-619c-441b-82bc-a5ec6a0b2905";
   fsType = "ext4";
   options = [ "auto" "nofail" "rw" ];
 };

 fileSystems."/mnt/laptop-windows" = {
   device = "/dev/disk/by-uuid/86DCAF76DCAF5F65";
   fsType = "ntfs";
   options = [ "auto" "nofail" "rw" ];
 };

 fileSystems."/mnt/laptop-media" = {
   device = "/dev/disk/by-uuid/5FF1628145AE7FD8";
   fsType = "ntfs";
   options = [ "auto" "nofail" "rw" ];
 };

 # Local PC drivers

 fileSystems."/mnt/pc-arch" = {
   device = "/dev/disk/by-uuid/1c00e31a-1769-4b37-8e72-17fc5924000c";
    fsType = "ext4";
    options = [ "auto" "nofail" "rw" ];
  };

  fileSystems."/mnt/pc-windows" = {
    device = "/dev/disk/by-uuid/8688627588626421";
    fsType = "ntfs";
    options = [ "auto" "nofail" "rw" ];
  };

  fileSystems."/mnt/pc-media" = {
    device = "/dev/disk/by-uuid/7FEFE39A74C41434";
    fsType = "ntfs";
    options = [ "auto" "nofail" "rw" ];
  };

  fileSystems."/mnt/pc-backup" = {
    device = "/dev/disk/by-uuid/7588bf42-c995-4f67-99ae-e9175641bea9";
    fsType = "ext4";
    options = [ "auto" "nofail" "rw" ];
  };

}
