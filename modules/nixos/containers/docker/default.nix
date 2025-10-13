{ config, pkgs, lib, ... }:

let

  cfg = config.my.containers.docker;

in

{

  options.my.containers.docker.enable = lib.mkEnableOption "enable docker";

  config = lib.mkIf (cfg.enable) {

    # Podman Container
    virtualisation = {

      containers = {
        enable = true;
       #policy = { };
       #storage.settings = { }; TOML Value
       #registries = {
       # #block = [ ];
       # #insecure = [ ];
       #  search = [
       #    "docker.io"
       #    "quay.io"
       #  ];
       #};
       #containersConf = {
       #  settings = { }; # TOML Value
       #  cniPlugins = with pkgs; [ ];
       #};
      };

      oci-containers = {
        backend = "docker"; # one of "podman", "docker"
      };

      docker = {
        enable = true;
        enableOnBoot = false;
        package = pkgs.docker;
        extraPackages = [ ];
        logDriver = "journald"; # one of "none", "json-file", "syslog", "journald", "gelf", "fluentd", "awslogs", "splunk", "etwlogs", "gcplogs", "local"
       #storageDriver = null; # one of "aufs", "btrfs", "devicemapper", "overlay", "overlay2", "zfs"
        daemon = {
          settings = {
            live-restore = true;
            ipv6 = true;
          };
        };
       #liveRestore = { };
        listenOptions = [ "/run/docker.sock" ];
       #extraOptions = '' '';
        autoPrune = {
          enable = false;
          randomizedDelaySec = "0";
          persistent = true;
          dates = "weekly";
         #flags = [
         #  "--all"
         #];
        };

        rootless = {
          enable = false;
          package = pkgs.docker;
          setSocketVariable = true;
          extraPackages = [ ];
          daemon = {
           #settings = { }; # JSON Value
          };
        };
      };
    };

    environment.systemPackages = with pkgs; [
      dive
      passt
      fetchit
      distrobox
      lilipod
      boxbuddy
     #distrobox-tui
     #distroshelf
     #gnome-boxes

    ];

  };

}
