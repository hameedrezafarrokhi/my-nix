{ config, pkgs, lib, ... }:

  with lib.hm.gvariant;

{ config = lib.mkIf (config.my.apps.resources.enable) {

  dconf.settings = {

    "net/nokyan/Resources" = {
      apps-show-decoder = false;
      apps-show-drive-read-speed = false;
      apps-show-drive-read-total = false;
      apps-show-drive-write-speed = true;
      apps-show-drive-write-total = true;
      apps-show-encoder = false;
      apps-show-gpu-memory = false;
      apps-show-swap = false;
      apps-sort-by = mkUint32 1;
      apps-sort-by-ascending = false;
      graph-data-points = mkUint32 60;
      processes-show-drive-read-speed = true;
      processes-show-drive-write-speed = true;
      show-graph-grids = true;
      show-virtual-drives = false;
      show-virtual-network-interfaces = true;
      sidebar-description = true;
      sidebar-details = true;
      sidebar-meter-type = "ProgressBar";
    };

  };

  home.packages = [
    pkgs.resources
  ];

};}
