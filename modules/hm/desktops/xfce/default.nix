{ config, pkgs, lib, ... }:

let

  cfg = config.my.xfce;

in

{

  options.my.xfce.enable = lib.mkEnableOption "xfce";

  config = lib.mkIf cfg.enable {

    xfconf.settings = {

     #xfce4-session = {     # Example
     #  "startup/ssh-agent/enabled" = false;
     #  "general/LockCommand" = "${pkgs.lightdm}/bin/dm-tool lock";
     #};
     #xfce4-desktop = {
     #  "backdrop/screen0/monitorLVDS-1/workspace0/last-image" =
     #    "${pkgs.nixos-artwork.wallpapers.stripes-logo.gnomeFilePath}";
     #};

      xfwm4 = {
        "general/button_layout" = "OTS|HMC";
        "general/snap_to_windows" = true;
      };

      xfce4-keyboard-shortcuts = {
        "xfwm4/custom/<Super>1" = "workspace_1_key";
        "xfwm4/custom/<Super>2" = "workspace_2_key";
        "xfwm4/custom/<Super>3" = "workspace_3_key";
        "xfwm4/custom/<Super>4" = "workspace_4_key";
        "xfwm4/custom/<Super>5" = "workspace_5_key";
        "xfwm4/custom/<Super>6" = "workspace_6_key";
        "xfwm4/custom/<Super>7" = "workspace_7_key";
        "xfwm4/custom/<Super>8" = "workspace_8_key";
        "xfwm4/custom/<Super>9" = "workspace_9_key";
        "xfwm4/custom/<Super>0" = "workspace_0_key";

        "xfwm4/custom/<Shift><Super>at"          = "move_window_workspace_2_key";
        "xfwm4/custom/<Shift><Super>exclam"      = "move_window_workspace_1_key";
        "xfwm4/custom/<Shift><Super>numbersign"  = "move_window_workspace_3_key";
        "xfwm4/custom/<Shift><Super>dollar"      = "move_window_workspace_4_key";
        "xfwm4/custom/<Shift><Super>percent"     = "move_window_workspace_5_key";
        "xfwm4/custom/<Shift><Super>asciicircum" = "move_window_workspace_6_key";
        "xfwm4/custom/<Shift><Super>ampersand"   = "move_window_workspace_7_key";
        "xfwm4/custom/<Shift><Super>asterisk"    = "move_window_workspace_8_key";
        "xfwm4/custom/<Shift><Super>parenleft"   = "move_window_workspace_9_key";
        "xfwm4/custom/<Shift><Super>parenright"  = "move_window_workspace_10_key";
        "xfwm4/custom/<Shift><Super>Right"       = "move_window_next_workspace_key";
        "xfwm4/custom/<Shift><Super>Left"        = "move_window_prev_workspace_key";

        "xfwm4/custom/<Super>c" = "close_window_key";

        "commands/custom/<Super>space" = "xfce4-appfinder --collapsed";
        "commands/custom/<Super><Alt>space" = "xfce4-appfinder";
        "commands/custom/<Primary><Super>space" = "xfce4-popup-applicationsmenu";
        "commands/custom/<Shift><Alt>E" = "xfce4-session-logout";
        "commands/custom/<Shift><Alt>L" = "xflock4";
      };

    };

  };

}
