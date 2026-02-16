{ config, pkgs, lib, ... }:

let

  cfg = config.my.i3;

  i3-master = pkgs.writeShellScriptBin "i3-master" ''
    pkill i3-auto-layout
    systemctl --user restart i3a-master-stack.service
  '';
  i3-tile = pkgs.writeShellScriptBin "i3-tile" ''
    systemctl --user stop i3a-master-stack.service
    systemctl --user stop i3a-master-stack-sway.service
    i3-auto-layout
  '';
  i3-manual = pkgs.writeShellScriptBin "i3-manual" ''
    systemctl --user stop i3a-master-stack.service
    systemctl --user stop i3a-master-stack-sway.service
    pkill i3-auto-layout
  '';

in

{

  options.my.i3.enable = lib.mkEnableOption "i3";

  config = lib.mkIf cfg.enable {

    home.packages = [

      pkgs.i3lock
      pkgs.i3status
      pkgs.i3blocks

      pkgs.i3a
      pkgs.i3-layout-manager
      pkgs.i3altlayout
      pkgs.i3-auto-layout

      pkgs.i3-ratiosplit
      pkgs.i3-swallow
      pkgs.i3-resurrect

      pkgs.i3-volume
      pkgs.i3-wk-switch
      pkgs.i3-easyfocus
      pkgs.i3-cycle-focus
      pkgs.i3-open-next-ws
      pkgs.i3-balance-workspace

      pkgs.autotiling
      pkgs.autotiling-rs
      pkgs.swaytools
      pkgs.sway-overfocus

      pkgs.xkb-switch-i3
      pkgs.kitti3

      i3-master
      i3-tile
      i3-manual

    ];

    systemd.user.services = {
      i3a-master-stack = {
        Unit = {
          Description = "i3a-master-stack";
        };
        Service = {
          ExecStart= "${pkgs.i3a}/bin/i3a-master-stack --stack=dwm --stack-size=40";
          Restart = "on-failure";
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER i3'";
        };
      };
      i3a-swallow = {
        Unit = {
          Description = "i3a-swallow";
        };
        Service = {
          ExecStart= "${pkgs.i3a}/bin/i3a-swallow";
          Restart = "on-failure";
          ExecCondition = "${pkgs.bash}/bin/bash -c 'pgrep -u $USER i3'";
        };
      };
    };

    xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3; # pkgs.i3-rounded


      # i3-rounded config
      # smart_borders on
      # smart_borders no_gaps
      # hide_edge_borders smart_no_gaps
      # for_window [class=".*"] border pixel 0
      # border_radius 10

      # i3a Stuff
      # bindsym $mod+s exec "i3a-scale-cycle -f 1.0,1.5,2.0 -o HDMI-1 -o HDMI-2 --next"
      # exec "systemctl --user start i3a-master-stack.service"

      # bindsym Mod4+Ctrl+Up exec i3a-resize-compass up 2ppt
      # bindsym Mod4+Ctrl+Down exec i3a-resize-compass down 2ppt
      # bindsym Mod4+Ctrl+Right exec i3a-resize-compass right 2ppt
      # bindsym Mod4+Ctrl+Left exec i3a-resize-compass left 2ppt

      extraConfig = ''

        for_window [class=".*"] inhibit_idle fullscreen
        for_window [class="Plank"] floating enable, border none, sticky enable
        for_window [window_type="dock"] floating enable, border none, sticky enable

        bindsym XF86AudioRaiseVolume exec ", volumectl -u up"
        bindsym XF86AudioLowerVolume exec ", volumectl -u down"
        bindsym XF86AudioMute exec ", volumectl toggle-mute"
        bindsym XF86AudioMicMute exec ", volumectl -m toggle-mute"

        exec_always --no-startup-id i3-auto-layout

        bindsym Mod4+Shift+h exec i3a-swap

        bindsym Mod4+minus exec i3a-move-to-empty

        bindsym Mod4+j exec i3a-cycle-focus down
        bindsym Mod4+k exec i3a-cycle-focus up

        bindsym Mod4+grave exec i3a-trail mark
        bindsym Mod4+Tab exec i3a-trail next
        bindsym Mod4+Shift+Tab exec i3a-trail previous

        bindsym Mod4+n exec i3a-trail new-trail
        bindsym Mod4+Shift+n exec i3a-trail delete-trail
        bindsym Mod4+bracketright exec i3a-trail next-trail
        bindsym Mod4+bracketleft exec i3a-trail previous-trail

        bindsym Mod1+space exec layout_manager

        exec "systemctl --user start i3a-swallow.service"

        bindsym Mod4+d exec i3-master
        bindsym Mod4+t exec i3-tile
        bindsym Mod4+m exec i3-manual

        for_window [class="Blueman-manager"] floating enable, resize set width 90 ppt height 60 ppt

        # set floating (nontiling) for special apps:
        for_window [class="Pavucontrol" ] floating enable, resize set width 90 ppt height 60 ppt
        for_window [class="Bluetooth-sendto" instance="bluetooth-sendto"] floating enable

        # set floating for window roles
        for_window [window_role="pop-up"] floating enable
        for_window [window_role="bubble"] floating enable
        for_window [window_role="task_dialog"] floating enable
        for_window [window_role="Preferences"] floating enable
        for_window [window_type="dialog"] floating enable
        for_window [window_type="menu"] floating enable
        for_window [window_role="About"] floating enable
        for_window [title="File Operation Progress"] floating enable, border pixel 1, sticky enable, resize set width 40 ppt height 30 ppt
        for_window [title="Picture in picture"] floating enable, sticky enable
        for_window [title="nmtui"] floating enable,  resize set width 50 ppt height 70 ppt
        for_window [title="htop"] floating enable, resize set width 50 ppt height 70 ppt
        for_window [class="Xsensors"] floating enable
        for_window [title="Save File"] floating enable

      '';

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
            Down = "resize shrink height 10 px or 10 ppt";
            Escape = "mode default";
            Left = "resize shrink width 10 px or 10 ppt";
            Return = "mode default";
            Right = "resize grow width 10 px or 10 ppt";
            Up = "resize grow height 10 px or 10 ppt";
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

          "${mod}+Shift+plus"  = "move scratchpad";
          "${mod}+Shift+minus" = "scratchpad show";

          "${mod}+c"           = "kill";
          "Mod1+Shift+r"       = "reload";
          "${mod}+space"       = "exec ${pkgs.rofi}/bin/rofi -show drun -modi drun -show-icons ";

          "Mod1+Shift+e"       = "exit";
          "Mod1+Shift+Ctrl+r"  = "restart";
          "${mod}+f"           = "floating toggle";
          "Mod1+Shift+a"       = "focus parent";
          "${mod}+w"           = "layout toggle split";
          "${mod}+Shift+Return"= "fullscreen toggle";
         #"Mod1+Shift+h"       = "split h";
          "${mod}+r"           = "mode resize";
          "${mod}+s"           = "layout stacking";
          "${mod}+a"           = "focus mode_toggle";
         #"Mod1+Shift+v"       = "split v";
          "${mod}+i"           = "layout tabbed";

          "${mod}+Ctrl+Up"     = "resize grow height 10px";
          "${mod}+Ctrl+Down"   = "resize shrink height 10px";
          "${mod}+Ctrl+Right"  = "resize grow width 10px";
          "${mod}+Ctrl+Left"   = "resize shrink width 10px";

          "XF86AudioPlay"      = "exec playerctl play";
          "XF86AudioPause"     = "exec playerctl pause";
          "XF86AudioNext"      = "exec playerctl next";
          "XF86AudioPrev"      = "exec playerctl previous";



        };

        floating = {
          titlebar = true;
          modifier = config.xsession.windowManager.i3.config.modifier;
          criteria = [
           #{
           #  class = "Plank";
           #}
          ];
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
