{ config, pkgs, lib, admin, ... }:

{

  options.my.hardware.android = {

    enable = lib.mkEnableOption "enable android stuff";

  };

  config = lib.mkIf (config.my.hardware.android.enable) {

    programs = {

      adb.enable = true;
      kdeconnect = {
        enable = true;
        package = lib.mkForce config.home-manager.users.${admin}.services.kdeconnect.package;
      };
      droidcam.enable = true;

    };

    environment.systemPackages = with pkgs; [

      scrcpy                        ##Andriod screen mirror
      qtscrcpy

    ];

  };

}
