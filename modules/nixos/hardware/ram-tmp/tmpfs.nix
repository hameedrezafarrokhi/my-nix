{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.ram-tmp.tmpfs.enable) {

  boot.tmp = {

    cleanOnBoot = true;

    useTmpfs = false;
    tmpfsHugeMemoryPages = "within_size";
    tmpfsSize = "50%";

    useZram = true;
    zramSettings = {
      zram-size = "ram * 0.5";
      compression-algorithm = "lz4";
      fs-type = "ext4";
      options = "X-mount.mode=1777,discard";

    };
  };

};}
