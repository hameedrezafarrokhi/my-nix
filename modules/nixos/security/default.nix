{ config, pkgs, lib, ... }:

{

  imports = [

    ./polkit
    ./sudo
    ./pam
    ./tpm

  ];

}
