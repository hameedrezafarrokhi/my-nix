{ config, pkgs, lib, admin, ... }:

{

  options.my.hardware.keyboard = {

    enable = lib.mkEnableOption "enable keyboard layouts";

    xremap.enable = lib.mkEnableOption "enable xremap keyboard mapping";

  };

  imports = [

   #./xremap.nix

  ];

  config = lib.mkIf (config.my.hardware.keyboard.enable) {

    # Configure keymap in X11
    services.xserver.xkb = {
      layout = config.home-manager.users.${admin}.home.keyboard.layout;
     #variant = "";
      # including layout switching. strings concatenated with ",". example"grp:caps_toggle,grp_led:scroll"
      options = "terminate:ctrl_alt_bksp,grp:alt_shift_space_toggle";
     #options = [ "terminate:ctrl_alt_bksp", "grp:alt_shift_space_toggle" ];
     #model = "pc104";
     #dir = "${pkgs.xkeyboard_config}/etc/X11/xkb";
     #extraLayouts = {
       #mine = {  # example (other options available):
       #  description = "My custom xkb layout.";
       #  languages = [ "eng" ];
       #  symbolsFile = /path/to/my/layout;
       #};
     #};
    };

   #buffyboard.enable = true;           # Virtual Keyboard (More Options)

  };

}
