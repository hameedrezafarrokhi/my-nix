{ config, pkgs, lib, ... }:

let

  cfg = config.my.i3;

  sway-tile = pkgs.writeShellScriptBin "sway-tile" ''
    systemctl --user stop i3a-master-stack-sway.service
    systemctl --user stop i3a-master-stack.service
    autotiling
  '';
  sway-manual = pkgs.writeShellScriptBin "sway-manual" ''
    pkill autotiling
    systemctl --user stop i3a-master-stack-sway.service
    systemctl --user stop i3a-master-stack.service
  '';
  sway-master = pkgs.writeShellScriptBin "sway-master" ''
    pkill autotiling
    systemctl --user restart i3a-master-stack-sway.service
  '';

in

{

  options.my.sway.enable = lib.mkEnableOption "sway";

  config = lib.mkIf cfg.enable {

    systemd.user.services = {
      i3a-master-stack-sway = {
        Unit = {
          Description = "i3a-master-stack-sway";
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
          ExecStart= "${pkgs.i3a}/bin/i3a-master-stack --stack=dwm --stack-size=40";
          Restart = "on-failure";
        };
      };
      i3a-swallow-sway = {
        Unit = {
          Description = "i3a-swallow-sway";
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
          ExecStart= "${pkgs.i3a}/bin/i3a-swallow";
          Restart = "on-failure";
        };
      };
    };

    home.packages = [

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

      sway-tile
      sway-manual
      sway-master

      pkgs.pamixer
      pkgs.playerctl

    ];

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
      extraConfig = ''

        #for_window [class=".*"] focus; opacity 1.0
        #for_window [class=".*"] opacity 0.2

        exec_always --no-startup-id autotiling
        exec "systemctl --user start i3a-swallow.service"

        bindsym Mod4+t exec sway-tile
        bindsym Mod4+m exec sway-manual
        bindsym Mod4+d exec sway-master

        for_window [class=".*"] inhibit_idle fullscreen
        for_window [app_id=".*"] inhibit_idle fullscreen

        input type:keyboard {
           repeat_delay 250
           repeat_rate 50
           xkb_numlock enabled
           xkb_layout "us,ir"
           xkb_options "grp:alt_caps_toggle"
        }

        input "type:touchpad" {
            dwt enabled
            tap enabled
            middle_emulation enabled
        }

        input "1:1:AT_Translated_Set_2_keyboard" {
            xkb_layout "us,ir"
        }

        bindsym {
           XF86AudioRaiseVolume exec pamixer -ui 10 && pamixer --get-volume > $SWAYSOCK.wob
           XF86AudioLowerVolume exec pamixer -ud 10  && pamixer --get-volume > $SWAYSOCK.wob
           XF86AudioMute exec pamixer --toggle-mute && ( pamixer --get-mute && echo 0 > $SWAYSOCK.wob ) || pamixer --get-volume > $SWAYSOCK.wob
        }

        for_window [app_id="blueman-manager"] floating enable,  resize set width 90 ppt height 60 ppt

        # set floating (nontiling) for special apps:
        for_window [app_id="pavucontrol" ] floating enable, resize set width 90 ppt height 60 ppt
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
        for_window [app_id="firedragon" title="Library"] floating enable, border pixel 1, sticky enable, resize set width 40 ppt height 30 ppt
        for_window [app_id="floating_shell_portrait"] floating enable, border pixel 1, sticky enable, resize set width 30 ppt height 40 ppt
        for_window [title="Picture in picture"] floating enable, sticky enable
        for_window [title="nmtui"] floating enable,  resize set width 50 ppt height 70 ppt
        for_window [title="htop"] floating enable, resize set width 50 ppt height 70 ppt
        for_window [app_id="xsensors"] floating enable
        for_window [title="Save File"] floating enable
        for_window [app_id="firedragon" title="firedragon — Sharing Indicator"] kill


      '';

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
         #{ command = "swaybar --bar_id top"; always = true; }
         #{ command = "export XDG_SESSION_DESKTOP=i3"; always = true; }
         #{ command = "export XDG_MENU_PREFIX=plasma-"; always = true; }
         #{ command = "waybar"; always = true; }
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
        settings = {
         #chars = "fjghdkslaemuvitywoqpcbnxz";
         #window_background_color = "1d1f21";
          window_background_opacity = 0.2;
         #label_background_color: '1d1f21'
          label_background_opacity = 1.0;
         #label_text_color = "c5c8c6";
         #focused_background_color: '285577'
          focused_background_opacity = 1.0;
         #focused_text_color = "ffffff";
         #font_family = "monospace";
         #font_weight: bold
         #font_size: medium
         #label_padding_x: 4
         #label_padding_y: 0
         #label_margin_x: 4
         #label_margin_y: 2
          show_confirmation = true;
        };
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
          { timeout = 3600; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
	    { timeout = 5400; command = "${pkgs.systemd}/bin/systemctl suspend"; }
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

      swayidle.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=none";
      swaync.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=none";
      swayosd.Unit.ConditionEnvironment = lib.mkForce "XDG_CURRENT_DESKTOP=none";


      swaync-sway = {
        Unit = {
          Description = "Swaync notification daemon";
          Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          X-Restart-Triggers = lib.mkMerge [
            [ "${config.xdg.configFile."swaync/config.json".source}" ]
            (lib.mkIf (config.services.swaync.style != null) [ "${config.xdg.configFile."swaync/style.css".source}" ])
          ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
         #Type = "dbus";
         #BusName = "org.freedesktop.Notifications";
          ExecStart = "${lib.getExe config.services.swaync.package}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ config.wayland.systemd.target ];
      };

      swayidle-sway = {
        Unit = {
          Description = "Idle manager for Wayland";
          Documentation = "man:swayidle(1)";
          PartOf = [ config.services.swayidle.systemdTarget ];
          After = [ config.services.swayidle.systemdTarget ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
          Type = "simple";
          Restart = "always";
          # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
          Environment = [ "PATH=${lib.makeBinPath [ pkgs.bash ]}" ];
          ExecStart =
            let
              mkTimeout =
                t:
                [
                  "timeout"
                  (toString t.timeout)
                  t.command
                ]
                ++ lib.optionals (t.resumeCommand != null) [
                  "resume"
                  t.resumeCommand
                ];

              mkEvent = e: [
                e.event
                e.command
              ];
              args =
                config.services.swayidle.extraArgs ++ (lib.concatMap mkTimeout config.services.swayidle.timeouts) ++ (lib.concatMap mkEvent config.services.swayidle.events);
            in
            "${lib.getExe config.services.swayidle.package} ${lib.escapeShellArgs args}";
        };
        Install = {
          WantedBy = [ config.services.swayidle.systemdTarget ];
        };
      };

      swayosd-sway = {
        Unit = {
          Description = "Volume/backlight OSD indicator";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          Documentation = "man:swayosd(1)";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 10;
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=sway";
        };
        Service = {
          Type = "simple";
          ExecStart =
            "${config.services.swayosd.package}/bin/swayosd-server"
            + (lib.optionalString (config.services.swayosd.stylePath != null) " --style ${lib.escapeShellArg config.services.swayosd.stylePath}")
            + (lib.optionalString (config.services.swayosd.topMargin != null) " --top-margin ${toString config.services.swayosd.topMargin}");
          Restart = "always";
          RestartSec = "2s";
        };
        Install = {
          WantedBy = [ config.wayland.systemd.target ];
        };
      };

    };

  };

}
