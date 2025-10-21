{ config, lib, pkgs, modulesPath, ... }:

{

  imports = [

    (modulesPath + "/installer/scan/not-detected.nix")

    ./graphics
    ./cpu
    ./ram-tmp
    ./fan
    ./bluetooth
    ./sound
    ./keyboard
    ./libinput
    ./touchegg
    ./dbus
    ./storage
    ./gamepads
    ./printer
    ./scanner
    ./logitech
    ./mounts
    ./power
    ./cd

  ];

  hardware = {
    enableAllFirmware = true;
    enableAllHardware = true; # add this if using a non nixos kernel: boot.initrd.allowMissingModules = true;
    enableRedistributableFirmware = true;
  };

}
