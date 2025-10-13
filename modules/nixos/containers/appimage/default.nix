{ config, pkgs, lib, ... }:

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

      gearlever                     ##AppImage management
     #appimageupdate
     #appimageupdate-qt             # WARNING BROKEN

    ];

  };

}
