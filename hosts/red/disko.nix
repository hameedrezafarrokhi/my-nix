{
  disko.devices = {
    disk = {
      main = {
                                                      # ssd
       #device = "/dev/disk/by-id/ata-ADATA_XPG_EX500_43A313212082";
                                                      # hdd
        device = "/dev/disk/by-id/ata-ADATA_XPG_EX500_439262E8505D";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              type = "EF00";
              size = "500M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
