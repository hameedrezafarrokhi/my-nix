{ config, pkgs, lib, ... }:

{

  options.my.hardware.android = {

    enable = lib.mkEnableOption "enable android stuff";

  };

  config = lib.mkIf (config.my.hardware.android.enable) {

    programs = {

      adb.enable = true;
      kdeconnect = {
        enable = true;
        package = lib.mkForce pkgs.kdePackages.kdeconnect-kde;
      };
      droidcam.enable = true;

    };

    environment.systemPackages = with pkgs; [

      scrcpy                        ##Andriod screen mirror
      qtscrcpy

    ];

  };

}
