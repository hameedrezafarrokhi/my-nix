{ config, lib, pkgs, ... }:

{

  imports = [

    ./flatpak
    ./appimage
    ./podman
    ./docker
    ./waydroid

  ];

}
