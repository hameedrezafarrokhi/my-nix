{ config, pkgs, lib, ... }:

let

  cfg = config.my.hardware.dbus;

in

{

  options.my.hardware.dbus.enable = lib.mkEnableOption "enable dbus";
  options.my.hardware.fwupd.enable = lib.mkEnableOption "enable fwupd";

  config = lib.mkIf cfg.enable {

    boot.initrd.systemd.dbus.enable = false; # Whether to enable dbus in stage 1.
    services.dbus = {
     #enable = true;                         # doesnt exist anymore
      dbusPackage = pkgs.dbus;
      brokerPackage = pkgs.dbus-broker;
      implementation = "broker";             # one of "dbus" or "broker"
      apparmor = "disabled";
     #packages = [  ];                       # packages that include dbus stuff that needs to be passed on
    };
    services.xserver.updateDbusEnvironment = true;

  };

  imports = [

    ./fwupd.nix

  ];

}
