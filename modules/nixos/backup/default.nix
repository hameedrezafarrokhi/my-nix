{ config, lib, pkgs, ... }:

{

  imports = [

    ./borg
    ./rsync

  ];

}
