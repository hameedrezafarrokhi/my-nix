{ config, pkgs, lib, ... }:

let

  cfg = config.my.containers.podman;

in

{

  options.my.containers.podman.enable = lib.mkEnableOption "enable podman";

  config = lib.mkIf cfg.enable {

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
        backend = "podman"; # one of "podman", "docker"
      };

      podman = {
        enable = true;
        package = pkgs.podman;
        dockerCompat = true; #WARNING Create an alias mapping docker to podman
        dockerSocket = {
          enable = true;
        };
        autoPrune = {
          enable = true;
         #flags = [
         #  "--all"
         #];
          dates = "weekly";
        };
        defaultNetwork = {
          settings = {
            dns_enabled = true;
          };
        };
       #networkSocket = {
       #  enable = true;
       # #tls = { }; # submodules
       #  server = "ghostunnel"; # value "ghostunnel" (singular enum)
       #  port = 2376;
       #  openFirewall = true;
       #  listenAddress = "0.0.0.0";
       #};
       #extraPackages = with pkgs; [ ];
      };
    };

    environment.systemPackages = with pkgs; [
      dive
      podman-tui
      passt
      podman-desktop
      pods
      fetchit
      distrobox
     #distrobox-tui
      lilipod
      boxbuddy
     #distroshelf
     #gnome-boxes

    ];

  };

}
