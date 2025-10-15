{ config, lib, pkgs, ... }:

{
config = lib.mkIf (config.my.software.terminals.enable) {

  environment.systemPackages = with pkgs; [

    kitty                         ##Terminal emulator
   #st                            ##Terminal emulator
   #foot                          ##Terminal emulator
   #alacritty                     ##Terminal emulator
   #gnome-terminal                ##Terminal emulator (gnome)
   #kdePackages.konsole           ##Terminal emulator (kde)
   #xfce.xfce4-terminal           ##Terminal emulator (xfce)

    # Drop Down
    tilda                         ##Dropdown terminal
   #kdePackages.yakuake           ##Dropdown terminal plugin (kde)
   #gnomeExtensions.yakuake       ##Dropdown terminal plugin (gnome)
    guake
   #kitti3
 ###hyper                        ## WARNING BROKEN LONG TIME
    tdrop                        ## anything dropdown!
    hdrop                        ## tdrop for hyprland

  ];

};
}
