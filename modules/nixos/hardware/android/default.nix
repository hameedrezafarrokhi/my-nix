{ config, pkgs, lib, admin, ... }:

let

  android-mount = pkgs.writeShellScriptBin "android-mount" ''
    if [ -e ~/Android/"Internal shared storage" ]; then
      notify-send "Andriod Device" "Already Mounted at ~/Andriod"
      exit 0
    fi
    notify-send "Andriod Device" "Mounting at ~/Andriod"
    mkdir -p ~/Android
    go-mtpfs -android ~/Android/ &
    sleep 2
    [ -e ~/Android/"Internal shared storage" ] && notify-send "Andriod Device" "Mounted"
  '';

  android-umount = pkgs.writeShellScriptBin "android-umount" ''
    if [ ! -e ~/Android/"Internal shared storage" ]; then
      notify-send "Andriod Device" "No Device Mounted"
      exit 0
    fi
    notify-send "Andriod Device" "Unmounting from ~/Andriod"
    fusermount -u ~/Android
    [ ! -e ~/Android/"Internal shared storage" ] && notify-send "Andriod Device" "Unmounted"
  '';

in

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

    environment.systemPackages = [

      pkgs.scrcpy                        ##Andriod screen mirror
      pkgs.qtscrcpy
      pkgs.android-tools
      pkgs.android-file-transfer
      pkgs.go-mtpfs
      pkgs.mtpfs

      android-mount
      android-umount

    ];

  };

}
