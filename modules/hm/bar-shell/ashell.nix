{ pkgs, lib, config, inputs, ...}:

{ config = lib.mkIf (builtins.elem "ashell" config.my.bar-shell.shells) {

  programs.ashell = {

    enable = true;
    package = pkgs.ashell;

    systemd = {
      enable = false;
      target = config.wayland.systemd.target;
    };

    settings = {

      log_level = "warn";
     #outputs = { Targets = ["eDP-1"]; };
      position = "Top";
      app_launcher_cmd = "rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons";

      modules = {
        left = [ [ "appLauncher" "Workspaces" ] ]; # , "Updates"
        center = [ "WindowTitle" ];
        right = [ "SystemInfo" [ "Clock"  "Tray" "Privacy" "Settings" ] ];
      };

     #updates = {
     #  check_cmd = "checkupdates; paru -Qua"
     #  update_cmd = 'alacritty -e bash -c "paru; echo Done - Press enter to exit; read" &'
     #};

      workspaces = {
        enable_workspace_filling = true;
      };

      "[CustomModule]" = {
        name = "appLauncher";
        icon = "󱗼";
        command = "rofi -show drun -modi drun -line-padding 4 -hide-scrollbar -show-icons";
      };

      window_title = {
        truncate_title_after_length = 100;
      };

      settings = {
        lock_cmd = "playerctl --all-players pause; hyprlock &";
        audio_sinks_more_cmd = "pavucontrol -t 3";
        audio_sources_more_cmd = "pavucontrol -t 4";
        wifi_more_cmd = "nm-connection-editor";
        vpn_more_cmd = "nm-connection-editor";
        bluetooth_more_cmd = "blueman-manager";
      };

    };

  };

};}
