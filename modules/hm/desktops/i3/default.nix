{ config, pkgs, lib, ... }:

let

  cfg = config.my.i3;

in

{

  options.my.i3.enable = lib.mkEnableOption "i3";

  config = lib.mkIf cfg.enable {

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3;

     #extraConfig = '' '';

      config = {

       #assigns = { };

        workspaceLayout = "default"; # "tabbed" "" default" "stacking"
        workspaceAutoBackAndForth = false;
        terminal = config.my.default.terminal;
        modifier = "Mod4";
        menu = "${pkgs.rofi}/bin/rofi -show drun"; # "${pkgs.dmenu}/bin/dmenu_run";
        defaultWorkspace = "workspace number 1";

        modes = {
          resize = {
            Down = "resize grow height 10 px or 10 ppt";
            Escape = "mode default";
            Left = "resize shrink width 10 px or 10 ppt";
            Return = "mode default";
            Right = "resize grow width 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
          };
        };

       #keycodebindings = { };
        keybindings =
        let
          mod = config.xsession.windowManager.i3.config.modifier;
        in {
          "${mod}+1"           = "workspace number 1";
          "${mod}+2"           = "workspace number 2";
          "${mod}+3"           = "workspace number 3";
          "${mod}+4"           = "workspace number 4";
          "${mod}+5"           = "workspace number 5";
          "${mod}+6"           = "workspace number 6";
          "${mod}+7"           = "workspace number 7";
          "${mod}+8"           = "workspace number 8";
          "${mod}+9"           = "workspace number 9";
          "${mod}+0"           = "workspace number 10";
          "${mod}+Up"          = "focus up";
          "${mod}+Down"        = "focus down";
          "${mod}+Left"        = "focus left";
          "${mod}+Right"       = "focus right";

          "${mod}+Shift+1"     = "move container to workspace number 1";
          "${mod}+Shift+2"     = "move container to workspace number 2";
          "${mod}+Shift+3"     = "move container to workspace number 3";
          "${mod}+Shift+4"     = "move container to workspace number 4";
          "${mod}+Shift+5"     = "move container to workspace number 5";
          "${mod}+Shift+6"     = "move container to workspace number 6";
          "${mod}+Shift+7"     = "move container to workspace number 7";
          "${mod}+Shift+8"     = "move container to workspace number 8";
          "${mod}+Shift+9"     = "move container to workspace number 9";
          "${mod}+Shift+0"     = "move container to workspace number 10";
          "${mod}+Shift+Down"  = "move down";
          "${mod}+Shift+Left"  = "move left";
          "${mod}+Shift+Right" = "move right";
          "${mod}+Shift+Up"    = "move up";

          "${mod}+Shift+minus" = "move scratchpad";
          "${mod}+Shift+plus"  = "scratchpad show";

          "${mod}+c"           = "kill";
          "${mod}+Shift+c"     = "reload";
          "${mod}+space"       = "exec ${pkgs.rofi}/bin/rofi -show drun";

          "Mod1+Shift+e"       = "exec i3-msg exit";
          "Mod1+Shift+Ctrl+r"  = "restart";
          "Mod1+Shift+f"       = "floating toggle";
          "Mod1+Shift+a"       = "focus parent";
          "Mod1+Shift+p"       = "layout toggle split";
          "Mod1+Shift+Return"  = "fullscreen toggle";
          "Mod1+Shift+h"       = "split h";
          "Mod1+Shift+r"       = "mode resize";
          "Mod1+Shift+s"       = "layout stacking";
          "Mod1+Shift+ctrl+space"= "focus mode_toggle";
          "Mod1+Shift+v"       = "split v";
          "Mod1+Shift+w"       = "layout tabbed";
        };

        floating = {
          titlebar = true;
          modifier = config.xsession.windowManager.i3.config.modifier;
         #criteria = [ ];
          border = 2;
        };

       #workspaceOutputAssign = {
       #  "*" = {
       #    workspace
       #    output
       #  };
       #};

        window = {
          titlebar = false;
          hideEdgeBorders = "none"; # "none", "vertical", "horizontal", "both", "smart"
          border = 3;
         #commands = [
         #  {
         #    command = "";
         #    criteria = { };
         #  }
         #];
        };

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

        gaps = {
          vertical = 4;
          top = 4;
          smartGaps = false;
          smartBorders = "off";
          right = 4;
          outer = 4;
          left = 4;
          inner = 7;
          horizontal = 4;
          bottom = 4;
        };

        focus = {
          wrapping = "yes";
          newWindow = "smart";
          mouseWarping = true;
         #forceWrapping
          followMouse = true;
        };

      };
    };

    programs = {

     #i3blocks = {
     #  enable = true;
     #  package = pkgs.i3blocks;
     # #bars = {};
     #};

      i3status-rust = {
	  enable = true;
        package = pkgs.i3status-rust;
        bars = {
          top = {
           #settings = { };
            blocks = [
              {
                alert = 10.0;
                block = "disk_space";
                info_type = "available";
                interval = 60;
                path = "/";
                warning = 20.0;
              }
              {
                block = "memory";
                format = " $icon $mem_used_percents ";
                format_alt = " $icon $swap_used_percents ";
              }
              {
                block = "cpu";
                interval = 1;
              }
              {
                block = "load";
                format = " $icon $1m ";
                interval = 1;
              }
              {
                block = "sound";
              }
              {
                block = "time";
                format = " $timestamp.datetime(f:'%a %d/%m %R') ";
                interval = 60;
              }
            ];
          };
        };
      };

    };

  };

}
