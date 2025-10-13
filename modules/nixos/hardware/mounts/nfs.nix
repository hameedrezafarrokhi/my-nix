{ config, pkgs, lib, ... }:

{ config = lib.mkIf (builtins.elem "nfs" config.my.hardware.mounts) {

  # (nofail means system starts if drive isnt available)
  # (rw mean read/write access to drive)

  fileSystems."/mnt/nfs" = {
    device = "192.168.0.100:/nfs/hrf_dude";
    fsType = "nfs";
    options = [ "x-systemd.automount" "noauto" "x-systemd.after=network-online.target" "x-systemd.mount-timeout=90" ];
  };

};}
