{ config, lib, pkgs, utils, ... }:

{ config = lib.mkIf (config.my.software.terminals.enable) {

  environment.systemPackages =

  (utils.removePackagesByName ( with pkgs; [

    kitty                         ##Terminal emulator

    (st.override {
      patches = [
        (pkgs.fetchurl {
          url = "https://st.suckless.org/patches/xresources/st-xresources-20230320-45a15676.diff";
          sha256 = "sha256-/ETVhdSM8d+wD7MMTixM+RmLd/VakfaO974mpcdXBKg=";
        })
      ];
    })

    foot                          ##Terminal emulator
    alacritty                     ##Terminal emulator
   #ghostty
    wezterm
   #gnome-terminal                ##Terminal emulator (gnome)
   #kdePackages.konsole           ##Terminal emulator (kde)
   #xfce.xfce4-terminal           ##Terminal emulator (xfce)

    # Drop Down
   #tilda                         ##Dropdown terminal
   #kdePackages.yakuake           ##Dropdown terminal plugin (kde)
   #gnomeExtensions.yakuake       ##Dropdown terminal plugin (gnome)
   #guake
   #kitti3
   #hyper                        ## web based terminal?
   #tdrop                        ## anything dropdown!
   #hdrop                        ## tdrop for hyprland

  ] ) config.my.software.terminals.exclude)

   ++

  config.my.software.terminals.include;

};}
