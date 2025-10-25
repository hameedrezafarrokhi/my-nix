{ config, lib, pkgs, ... }:

{

  imports = [

    ./locale
    ./shell
    ./font
    ./console
    ./systemd
    ./tasks
    ./search
    ./services

  ];

}
