{ config, lib, pkgs, ... }:

{ config = lib.mkIf (config.my.apps.lutris.enable) {

  programs.lutris = {
    enable = true;
   #package = pkgs.lutris;
    extraPackages = with pkgs; [ mangohud gamemode umu-launcher ]; # winetricks #  gamescope
    protonPackages = [ pkgs.proton-ge-bin ];
   #steamPackage = pkgs.steam; # pkgs.streamlink is default
   #winePackages = [ pkgs.wineWowPackages.stagingFull ]; # lutris Downloads wine on load anyways
   #runners = { # example:
   #  cemu.package = pkgs.cemu;
   #  pcsx2.config = {
   #    system.disable_screen_saver = true;
   #    runner.runner_executable = "$\{pkgs.pcsx2}/bin/pcsx2-qt";
   #  };
   #};
  };

  home.packages = [ pkgs.heroic ];

};}
