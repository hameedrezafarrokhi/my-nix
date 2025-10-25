{ config, lib, pkgs, utils, ... }:

{
config = lib.mkIf (config.my.software.disk-utils.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    gparted                       ##Partitioning tool
    gnome-disk-utility            ##Partitioning tool (Gnome)

    baobab                        ##Gnome Disk usage analysis
    kdePackages.filelight         ##KDE Disk usage analysis
   #bleachbit                     ##Disk cleanup

    impression                    ##Bootable image creator
    mediawriter                   ##Fedora Media Writer
    kdePackages.isoimagewriter    ##Bootable image creator (kde)
   #ventoy                        ##Bootable image creator
   #ventoy-full                   ##Bootable image creator (Another)
   #ventoy-full-qt
   #ventoy-full-gtk

  ] ) config.my.software.disk-utils.exclude)

   ++

  config.my.software.disk-utils.include;

  programs = {

    gnome-disks.enable = true;

    partition-manager = {
      enable = true;
      package = lib.mkForce pkgs.kdePackages.partitionmanager;
    };

  };

};}
