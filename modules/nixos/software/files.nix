{ config, lib, pkgs, utils, mypkgs, ... }:

{ config = lib.mkIf (config.my.software.files.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( [

    pkgs.kdePackages.dolphin
    pkgs.kdePackages.dolphin-plugins

   #pkgs.nemo                          ##Cinnamon filemanager
   #pkgs.nemo-with-extensions          ##Cinnamon filemanager

   #pkgs.nautilus                      ##Gnome filemanager

   #pkgs.xfce.thunar
   #(xfce.thunar.override {
   #  thunarPlugins = [
   #    pkgs.thunar-media-tags-plugin
   #    pkgs.thunar-archive-plugin
   #    pkgs.thunar-vcs-plugin
   #    pkgs.thunar-volman
   #  ];
   #})

   #pkgs.krusader                      ##Complex filemanager

   #pkgs.pcmanfm                       ##LXQT filemanager

   #pkgs.lf                            ##CLI filemanager
   #pkgs.fff                           ##CLI filemanager

   #pkgs.filezilla                     ##FTP file transfer
    pkgs.warp                          ##File secure transfer app
   #pkgs.dropbox                       ##Dropbox client (unofficial)

   #pkgs.fsearch                       ##Search tool
   #pkgs.kdePackages.kfind             ##Search tool (kde)
   #pkgs.metadata-cleaner              ##File metadata cleaner

    pkgs.kdePackages.ark               ##KDE archive manager
    pkgs.file-roller                   ##Archive manager Gnome
   #pkgs.peazip                        ##Archive manager (insecure in stable)
    pkgs.rar                           ##RAR protocol
   #pkgs.unrar                         ##RAR protocol extra
    pkgs.unzip                         ##ZIP protocol
    pkgs.file                          ##file utility like mime type finder

  ] ) config.my.software.files.exclude)

   ++

  config.my.software.files.include;

  programs = {

    yazi = {
      enable = true;
      package = pkgs.yazi;
      plugins = { inherit (pkgs.yaziPlugins.starship); };
     #initLua = ./  .lua;
     #flavors = {};
     #settings = {
     #  yazi = {};
     #  keymap = {};
     #  theme = {};
     #};
    };

    thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-media-tags-plugin
        thunar-archive-plugin
        thunar-vcs-plugin
        thunar-volman
      ];
    };

    nautilus-open-any-terminal = {
      enable = false;
      terminal = config.my.default.terminal;
    };

  };

};}
