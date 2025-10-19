{ config, pkgs, lib, mypkgs, ... }:

let

  cfg = config.my.containers.appimage;

in

{

  options.my.containers.appimage.enable = lib.mkEnableOption "enable appimage";

  config = lib.mkIf cfg.enable {

    programs.appimage = {
      enable = true;
      binfmt = true;
     #package = pkgs.appimage-run.override { extraPkgs = pkgs: [ pkgs.ffmpeg pkgs.imagemagick ]; }
    };

    environment.systemPackages = with pkgs; [

      pkgs.gearlever                     ##AppImage management
     #pkgs.appimageupdate
      mypkgs.stable.appimageupdate-qt

    ];

  };

}
