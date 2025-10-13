{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.connectivity.enable) {

  environment.systemPackages = with pkgs; [

    scrcpy                        ##Andriod screen mirror
    qtscrcpy

  ];

};
}
