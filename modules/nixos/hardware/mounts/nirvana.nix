{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "nirvana" config.my.hardware.mounts) {

  # (nofail means system starts if drive isnt available)
  # (rw mean read/write access to drive)

  # Local drivers

 fileSystems."/mnt/windows" = {
   device = "/dev/disk/by-uuid/86DCAF76DCAF5F65";
   fsType = "ntfs";
   options = [ "auto" "nofail" "rw" ];
 };

 fileSystems."/mnt/media" = {
   device = "/dev/disk/by-uuid/00DA0670DA066270";
   fsType = "ntfs";
   options = [ "auto" "nofail" "rw" ];
 };

};}
