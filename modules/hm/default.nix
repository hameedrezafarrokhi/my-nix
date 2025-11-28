{ config, lib, pkgs, nix-path, ... }:

{

  imports = [

    ./nix
    ./bar-shell
    ./apps
    ./desktops
    ./distrobox
    ./theme
    ./custom-desktop-entries
    ./firefox
    ./shells
    ./flatpak
    ./fonts
    ./nix-artwork
    ./ssh
    ./xdg
    ./keyboard
    ./gaming
    ./inputs-readme-files
    ./secrets
    ./audio
    ./display

  ];

}
