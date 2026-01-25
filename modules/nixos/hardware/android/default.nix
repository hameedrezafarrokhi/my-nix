{ config, pkgs, lib, admin, ... }:

{

  options.my.hardware.android = {

    enable = lib.mkEnableOption "enable android stuff";

  };

  config = lib.mkIf (config.my.hardware.android.enable) {

    programs = {

     #adb.enable = true;  # WARNING DEPRICATED

      kdeconnect = {
        enable = true;
        package = lib.mkForce config.home-manager.users.${admin}.services.kdeconnect.package;
      };

      droidcam.enable = true;

      localsend = {
        enable = true;
        package = pkgs.localsend;
        openFirewall = true;
      };

    };

    environment.systemPackages = with pkgs; [

      scrcpy                        ##Andriod screen mirror
      qtscrcpy
      android-tools

    ];

  };

}
