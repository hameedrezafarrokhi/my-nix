{ config, pkgs, lib, ... }:

let

  cfg = config.my.mango;

in

{

  options.my.mango.enable = lib.mkEnableOption "mango";

  config = lib.mkIf cfg.enable {

    wayland.windowManager.mango = {
      enable = true;
     #package = ;
      systemd = {
        enable = true;
        variables = [ "--all" ];
        extraCommands = [
          "systemctl --user reset-failed"
          "systemctl --user start mango-session.target"
        ];
        xdgAutostart = true;
      };

      settings = ''
        numlockon=1

        bind=SUPER,right,focusstack next,
        bind=SUPER,left,focusstack prev,

        bind=SUPER,1,comboview,1
        bind=SUPER,2,comboview,2
        bind=SUPER,3,comboview,3
        bind=SUPER,4,comboview,4
        bind=SUPER,5,comboview,5
        bind=SUPER,6,comboview,6
        bind=SUPER,7,comboview,7
        bind=SUPER,8,comboview,8
        bind=SUPER,9,comboview,9

        bind=SUPER,1,toggletag 1,
        bind=SUPER,2,toggletag 2,
        bind=SUPER,3,toggletag 3,
        bind=SUPER,4,toggletag 4,
        bind=SUPER,5,toggletag 5,
        bind=SUPER,6,toggletag 6,
        bind=SUPER,7,toggletag 7,
        bind=SUPER,8,toggletag 8,
        bind=SUPER,9,toggletag 9,
        bind=SUPER,10,toggletag 1,

        bind=SUPER,i,incnmaster,+1
        bind=SUPER,p,incnmaster,-1

        bind=SUPER,t,setlayout,tile
        bind=SUPER,v,setlayout,vertical_grid
        bind=SUPER,c,setlayout,spiral
        bind=SUPER,x,setlayout,scroller
        bind=SUPER,n,switch_layout
        bind=SUPER,a,togglegaps

        tagrule=id:1,layout_name:tile
        tagrule=id:2,layout_name:tile
        tagrule=id:3,layout_name:tile
        tagrule=id:4,layout_name:tile
        tagrule=id:5,layout_name:tile
        tagrule=id:6,layout_name:tile
        tagrule=id:7,layout_name:tile
        tagrule=id:8,layout_name:tile
        tagrule=id:9,layout_name:tile

        mousebind=SUPER,btn_left,moveresize,curmove
        mousebind=SUPER,btn_right,moveresize,curresize

        repeat_rate=35
        repeat_delay=200

        bind=SUPER,q,killclient,
        bind=SUPER+SHIFT,r,reload_config
        bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl set +5%

        animations=1
        gappih=5
        gappiv=5
        gappoh=5
        gappov=5
        borderpx=4
        no_border_when_single=0
        focuscolor=0x005577ff

        blur=0
        blur_layer=1
        blur_optimized=1
        blur_params_num_passes = 2
        blur_params_radius = 5
        blur_params_noise = 0.02
        blur_params_brightness = 0.9
        blur_params_contrast = 0.9
        blur_params_saturation = 1.2

        shadows = 1
        layer_shadows = 1
        shadow_only_floating=1
        shadows_size = 12
        shadows_blur = 15
        shadows_position_x = 0
        shadows_position_y = 0
        shadowscolor= 0x000000ff

        animations=1
        layer_animations=1
        animation_type_open=zoom
        animation_type_close=slide
        layer_animation_type_open=slide
        layer_animation_type_close=slide
        animation_fade_in=1
        animation_fade_out=1
        tag_animation_direction=1
        zoom_initial_ratio=0.3
        zoom_end_ratio=0.7
        fadein_begin_opacity=0.6
        fadeout_begin_opacity=0.8
        animation_duration_move=500
        animation_duration_open=400
        animation_duration_tag=350
        animation_duration_close=800
        animation_curve_open=0.46,1.0,0.29,1.1
        animation_curve_move=0.46,1.0,0.29,1
        animation_curve_tag=0.46,1.0,0.29,1
        animation_curve_close=0.08,0.92,0,1

        scroller_structs=20
        scroller_default_proportion=0.8
        scroller_focus_center=0
        scroller_prefer_center=1
        edge_scroller_pointer_focus=1
        scroller_default_proportion_single=1.0
        scroller_proportion_preset=0.5,0.8,1.0

        bind=SUPER+SHIFT,f,togglefullscreen,
        bind=SUPER,f,togglefloating,

        bind=CTRL+SHIFT,k,smartmovewin,up
        bind=CTRL+SHIFT,j,smartmovewin,down
        bind=CTRL+SHIFT,h,smartmovewin,left
        bind=CTRL+SHIFT,l,smartmovewin,right

        bind=SUPER,j,focusstack,next
        bind=SUPER,k,focusstack,prev
        bind=SUPER,h,focusdir,left
        bind=SUPER,l,focusdir,right

        bind=SUPER+SHIFT,k,exchange_client,up
        bind=SUPER+SHIFT,j,exchange_client,down
        bind=SUPER+SHIFT,h,exchange_client,left
        bind=SUPER+SHIFT,l,exchange_client,right

        gesturebind=none,left,3,focusdir,left
        gesturebind=none,right,3,focusdir,right
        gesturebind=none,up,3,focusdir,up
        gesturebind=none,down,3,focusdir,down
        gesturebind=none,left,4,viewtoleft_have_client
        gesturebind=none,right,4,viewtoright_have_client
        gesturebind=none,up,4,toggleoverview
        gesturebind=none,down,4,toggleoverview
        bind=SUPER,0,toggleoverview


      '';

      #waybar &
      autostart_sh = ''
        swww-daemon &
        xremap --watch --mouse ~/.config/xremap/xremap.yaml &
      '';

    };

    services = lib.mkDefault {

     #swayidle = {
     #  enable = true;
     #  package = pkgs.swayidle;
     #  systemdTarget = config.wayland.systemd.target;
     #  events = [
     #    { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
     #    { event = "lock"; command = "lock"; }
     #  ];
     #  timeouts = [
     #    { timeout = 3600; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
     #    { timeout = 5400; command = "${pkgs.systemd}/bin/systemctl suspend"; }
     #  ];
     #  extraArgs = [ "-w" ];
     #};

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

      swaync-mango = {
        Unit = {
          Description = "Swaync notification daemon";
          Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          X-Restart-Triggers = lib.mkMerge [
            [ "${config.xdg.configFile."swaync/config.json".source}" ]
            (lib.mkIf (config.services.swaync.style != null) [ "${config.xdg.configFile."swaync/style.css".source}" ])
          ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=mango";
        };

        Service = {
         #Type = "dbus";
         #BusName = "org.freedesktop.Notifications";
          ExecStart = "${lib.getExe config.services.swaync.package}";
          Restart = "on-failure";
        };
        Install.WantedBy = [ config.wayland.systemd.target ];
      };

     #swayidle-mango = {
     #  Unit = {
     #    Description = "Idle manager for Wayland";
     #    Documentation = "man:swayidle(1)";
     #    PartOf = [ config.services.swayidle.systemdTarget ];
     #    After = [ config.services.swayidle.systemdTarget ];
     #    ConditionEnvironment = "XDG_CURRENT_DESKTOP=mango";
     #  };
     #  Service = {
     #    Type = "simple";
     #    Restart = "always";
     #    # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
     #    Environment = [ "PATH=${lib.makeBinPath [ pkgs.bash ]}" ];
     #   #ExecStart =
     #   #  let
     #   #    mkTimeout =
     #   #      t:
     #   #      [
     #   #        "timeout"
     #   #        (toString t.timeout)
     #   #        t.command
     #   #      ]
     #   #      ++ lib.optionals (t.resumeCommand != null) [
     #   #        "resume"
     #   #        t.resumeCommand
     #   #      ];
     #   #
     #   #    mkEvent = e: [
     #   #      e.event
     #   #      e.command
     #   #    ];
     #   #    args =
     #   #      config.services.swayidle.extraArgs ++ (lib.concatMap mkTimeout config.services.swayidle.timeouts) ++ (lib.concatMap mkEvent config.services.swayidle.events);
     #   #  in
     #   #  "${lib.getExe config.services.swayidle.package} ${lib.escapeShellArgs args}";
     #  };
     #  Install = {
     #    WantedBy = [ config.services.swayidle.systemdTarget ];
     #  };
     #};

      swayosd-mango = {
        Unit = {
          Description = "Volume/backlight OSD indicator";
          PartOf = [ config.wayland.systemd.target ];
          After = [ config.wayland.systemd.target ];
          Documentation = "man:swayosd(1)";
          StartLimitBurst = 5;
          StartLimitIntervalSec = 10;
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=mango";
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
