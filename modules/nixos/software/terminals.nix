{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.terminals.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    kitty                         ##Terminal emulator
    st                            ##Terminal emulator
    foot                          ##Terminal emulator
    alacritty                     ##Terminal emulator
    ghostty
    wezterm
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

  ] ) config.my.software.terminals.exclude)

   ++

  config.my.software.terminals.include;

};}
