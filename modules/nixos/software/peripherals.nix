{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.peripherals.enable) {

  environment.systemPackages = with pkgs; [

   #kdePackages.kdeconnect-kde    ##KDE mobile connect

   #openrgb                       ##RBG control
   #openrgb-with-all-plugins      ##RBG control full

    piper                         ##Gaming mouse config
   #libratbag                     ##Library for piper
   #qjoypad                       ##Controller as Mouse  # WARNING BROKEN
    joystickwake                  ##Joystick screen waker
   #jstest-gtk                    ##Joystick tester   # WARNING BROKEN

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

  ];

};
}
