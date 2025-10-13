{ config, pkgs, lib, ... }:

{

  programs.distrobox = {
    enable = true;
    package = pkgs.distrobox;
    enableSystemdUnit = true;
    containers = {

     #debian = {
     #  image = "quay.io/toolbx-images/debian-toolbox:latest";
     #  entry = true;
     #  additional_packages = "python3 git fastfetch";
     # #init_hooks = "pip3 install numpy pandas torch torchvision";
     # #init_hooks = [
     # #  "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
     # #  "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
     # #];
     #};

     #arch = {
     #  image = "quay.io/toolbx/arch-toolbox:latest";
     #  entry = true;
     #  additional_packages = "python git fastfetch";
     # #init_hooks = "pip3 install numpy pandas torch torchvision";
     # #init_hooks = [
     # #  "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker"
     # #  "ln -sf /usr/bin/distrobox-host-exec /usr/local/bin/docker-compose"
     # #];
     #};

    };
  };

}
