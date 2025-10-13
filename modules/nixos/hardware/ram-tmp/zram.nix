{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.hardware.ram-tmp.zram.enable) {

  # ZSWAP

 #boot.initrd.systemd.enable = true; # ONLY FOR LZ4
 #boot.kernelParams = [
 #  "zswap.enabled=1"
 #  "zswap.compressor=lz4"
 #  "zswap.max_pool_percent=50"
 #  "zswap.shrinker_enabled=1"
 #];

  # ZRAM

  zramSwap = {
    enable = true;
    priority = 5;
    memoryPercent = 50;
    memoryMax = null;
    algorithm = "lz4";
    swapDevices = 1;
    writebackDevice = lib.mkDefault null;
  };

  services.zram-generator = {
    enable = true;
    package = pkgs.zram-generator;
   #settings = { };
  };

};}
