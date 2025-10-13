{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "blue" config.my.hardware.mounts) {

  # (nofail means system starts if drive isnt available)
  # (rw mean read/write access to drive)

 # Local drivers

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

};}
