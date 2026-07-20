{ config, pkgs, lib, mypkgs, inputs, ... }:

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
     #mypkgs.stable.appimageupdate-qt

     #inputs.app-manager.packages.x86_64-linux.default
      inputs.app-manager.packages.${pkgs.stdenv.hostPlatform.system}.default

    ];

  };

}

 # For QT apps that wont run: QT_PLUGIN_PATH= appimage-run DuckStation-x64.appimage
