{ config, lib, pkgs, ... }:

{

  imports = [

    ./desktops
    ./window-managers
    ./display-manager
    ./xdg
    ./dconf
    ./x11

  ];

}
