{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.apps.lutris.enable) {

  programs.lutris = {
    enable = true;
   #package = pkgs.lutris;
    extraPackages = with pkgs; [ mangohud gamemode umu-launcher ]; # winetricks gamescope
    protonPackages = [ pkgs.proton-ge-bin ];
    steamPackage = pkgs.steam;
    winePackages = [ pkgs.wineWowPackages.stagingFull ];
   #runners = { # example:
   #  cemu.package = pkgs.cemu;
   #  pcsx2.config = {
   #    system.disable_screen_saver = true;
   #    runner.runner_executable = "$\{pkgs.pcsx2}/bin/pcsx2-qt";
   #  };
   #};
  };

};
}
