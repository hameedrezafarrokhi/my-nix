{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/disk/by-id/ata-Samsung_SSD_870_EVO_500GB_S7BWNJ0WB40572P";
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
              size = "256G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
           #media = {
           #  size = "100%";
           #  content = {
           #   #type = "filesystem";
           #    format = "ntfs";
           #    mountpoint = "/mnt/laptop-media";
           #    mountOptions = [ "auto" "nofail" "rw" ];
           #  };
           #};
          };
        };
      };
    };
  };
}
