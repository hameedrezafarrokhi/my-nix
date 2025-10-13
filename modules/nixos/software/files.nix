{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.files.enable) {

  environment.systemPackages = with pkgs; [

    kdePackages.dolphin
    kdePackages.dolphin-plugins
   #nemo                          ##Cinnamon filemanager
    nemo-with-extensions          ##Cinnamon filemanager
    nautilus                      ##Gnome filemanager
    (xfce.thunar.override {
      thunarPlugins = [
        xfce.thunar-media-tags-plugin
        xfce.thunar-archive-plugin
        xfce.thunar-vcs-plugin
        xfce.thunar-volman
      ];
    })
   #krusader                      ##Complex filemanager
   #pcmanfm                       ##LXQT filemanager
    lf                            ##CLI filemanager
    fff                           ##CLI filemanager

    filezilla                     ##FTP file transfer
    warp                          ##File secure transfer app
   #dropbox                       ##Dropbox client (unofficial)

    fsearch                       ##Search tool
    kdePackages.kfind             ##Search tool (kde)
    metadata-cleaner              ##File metadata cleaner

    kdePackages.ark               ##KDE archive manager
   #file-roller                   ##Archive manager Gnome
    peazip                        ##Archive manager (insecure in stable)
    rar                           ##RAR protocol
   #unrar                         ##RAR protocol extra
    unzip                         ##ZIP protocol
    file                          ##file utility like mime type finder

  ];

};
}
