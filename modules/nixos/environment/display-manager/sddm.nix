{ config, pkgs, lib, admin, ... }:

{ config = lib.mkIf (config.my.display-manager == "sddm") {

  services.xserver.enable = true;

  services.displayManager = {
    sddm = {
      enable = true;
     #package = ;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
      enableHidpi = true;
      autoNumlock = true;
      settings = {
        General = {
          Numlock = "on";
         #InputMethod = "maliit-keyboard";
        };
       #Wayland = {
       #  CompositorCommand = "${pkgs.kdePackages.kwin}/bin/kwin_wayland --drm --no-global-shortcuts --no-kactivities --no-lockscreen --locale1 --inputmethod maliit-keyboard";
       #};
       #Autologin = {
       #  Session = "plasma.desktop";
       #  User = admin;
       #};
      };
      extraPackages = [

      ];
    };
  };

 #environment.etc."usr/share/sddm/faces/hrf.face.icon".source = ./hrf.face.icon;

  environment.systemPackages = with pkgs; [
   #kdePackages.qtvirtualkeyboard
   #maliit-keyboard

   #(writeTextDir "etc/sddm.conf.d/numlock.conf" ''
   #Numlock=on
   #'')
   #(writeTextDir "/var/lib/sddm/.config/kcminputrc" ''
   #[Keyboard]
   #NumLock=0
   #'')
    # Themes
   #sddm-sugar-dark
   #where-is-my-sddm-theme
   #sddm-chili-theme
   #sddm-astronaut
   #elegant-sddm
   #catppuccin-sddm-corners
   #catppuccin-sddm
    # Changing SDDM Theme Settings
   #(writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
   #[General]
   #background=/etc/nixos/assets/background.png
   #'')
  ];

  # For Testing:
  # sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/breeze

};}
