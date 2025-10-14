{ config, pkgs, lib, ... }:

let

  cfg = config.my.i3;

in

{

  options.my.sway.enable = lib.mkEnableOption "sway";

  config = lib.mkIf cfg.enable {

    wayland.windowManager.sway = {
      enable = true;
     #package = pkgs.sway;
      xwayland = true;
      checkConfig = true;
      wrapperFeatures = {
        base = true;
        gtk = true;
      };

     #extraSessionCommands = '' '';
     #extraConfigEarly = '' '';
     #extraConfig = '' '';
      extraOptions = [
        "--unsupported-gpu"
      ];

      config = {

       #assigns = { };

        workspaceLayout = "default"; # "tabbed" "" default" "stacking"
        workspaceAutoBackAndForth = false;
        terminal = config.my.default.terminal;
        modifier = "Mod4";
        menu = "${pkgs.rofi}/bin/rofi -show drun"; # "${pkgs.dmenu}/bin/dmenu_run";
        defaultWorkspace = "workspace number 1";

        modes = config.xsession.windowManager.i3.config.modes;

       #keycodebindings = { };
        keybindings = config.xsession.windowManager.i3.config.keybindings;

        floating = config.xsession.windowManager.i3.config.floating;

       #workspaceOutputAssign = {
       #  "*" = {
       #    workspace
       #    output
       #  };
       #};

        window = config.xsession.windowManager.i3.config.window;

        startup = [
         #{
         # #workspace
         # #notification
         #  command = "feh --bg-fill /home/hrf/Pictures/Wallpapers/background.png";
         #  always = true;
         #}
         #{ command = "export XDG_CURRENT_DESKTOP=i3"; always = true; }
         #{ command = "export XDG_SESSION_DESKTOP=i3"; always = true; }
         #{ command = "export XDG_MENU_PREFIX=plasma-"; always = true; }

        ];

        gaps = config.xsession.windowManager.i3.config.gaps;

        focus = config.xsession.windowManager.i3.config.focus;

      };

      swaynag = {
        enable = true;
       #settings = { };
      };

      systemd = {
        enable = true;
        dbusImplementation = "broker";
        xdgAutostart = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user reset-failed"
          "systemctl --user start sway-session.target"
          "swaymsg -mt subscribe '[]' || true"
          "systemctl --user stop sway-session.target"
        ];
      };

    };

    programs = {

      sway-easyfocus = {
        enable = true;
        package = pkgs.sway-easyfocus;
       #settings = { };
      };

      swayimg = {
        enable = true;
        package = pkgs.swayimg;
       #settings = { };
      };

      swaylock = {
        enable = true;
        package = pkgs.swaylock;
       #settings = { };
      };

      swayr = {
        enable = true;
        package = pkgs.swayr;
       #settings = { };
        systemd = {
          enable = true;
          target = config.wayland.systemd.target;
        };
      };

    };

    services = {

      swayidle = {
        enable = true;
        package = pkgs.swayidle;
        systemdTarget = config.wayland.systemd.target;
        events = [
          { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
          { event = "lock"; command = "lock"; }
        ];
        timeouts = [
          { timeout = 100; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
	    { timeout = 200; command = "${pkgs.systemd}/bin/systemctl suspend"; }
        ];
        extraArgs = [ "-w" ];
      };

      swaync = {
        enable = true;
        package = pkgs.swaynotificationcenter;
       #settings = { };
       #style = '' '';
      };

      swayosd = {
        enable = true;
        package = pkgs.swayosd;
       #stylePath = "";
       #topMargin = 1.0;
      };

    };

    systemd.user.services = {
      swayrd.Unit.ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
      swayidle.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=sway";
      swaync.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=sway";
      swayosd.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=sway";
    };
  };

}
