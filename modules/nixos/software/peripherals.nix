{ config, lib, pkgs, mypkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.peripherals.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

   #kdePackages.kdeconnect-kde    ##KDE mobile connect

   #openrgb                       ##RBG control
   #openrgb-with-all-plugins      ##RBG control full

    piper                         ##Gaming mouse config
   #libratbag                     ##Library for piper
   #qjoypad                       ##Controller as Mouse
    joystickwake                  ##Joystick screen waker
   #jstest-gtk                    ##Joystick tester

   #xsane                         ##Scanner app
   #hplip                         ##HP scanner stuff
   #hplipWithPlugin               ##HP scanner stuff full
   #kdePackages.ksanecore
   #kdePackages.libksane
   #kdePackages.skanlite
   #simple-scan
   #scanbd            # NEEDS A LARGE CONFIG FILE

   #coolercontrol.coolercontrol-gui ##Fan control gui
   #coolercontrol.coolercontrold    ##Fan control
   #fanctl                          ##Fan control (another)  # WARNING BASED ON FANCONTROL WHICH IS BAAAAAAD

    displaycal                    ##Display Calibration Tool

  ] ) config.my.software.peripherals.exclude)

   ++

  config.my.software.peripherals.include

   ++

  [
    mypkgs.stable.qjoypad
    mypkgs.stable.jstest-gtk
  ];

};}
