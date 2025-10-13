{ config, lib, pkgs, ... }:

{

  imports = [

    ./boot
    ./hardware
    ./environment
    ./security
    ./network
    ./system
    ./user
    ./nix
    ./theme
    ./containers
    ./gaming
    ./backup
    ./software
    ./home-manager
    ./inputs-readme-files
    ./secrets

  ];

}
