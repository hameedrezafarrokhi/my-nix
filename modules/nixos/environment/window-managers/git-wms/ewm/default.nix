{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.ewm;
  ewm = pkgs.callPackage ./ewm.nix {
    conf =''
      #ifndef CONFIG_H
      #define CONFIG_H
      #define MOD Mod4Mask
      #define ROUND_CORNERS 5

      const char* menu[]    = {"rofi", "-show", "drun", "-theme", ".config/rofi/themes/main.rasi",    0};
      const char* term[]    = {"${config.my.default.terminal}",                                       0};
      const char* briup[]   = {"brillo", "-A", "3",                                                   0};
      const char* bridown[] = {"brillo", "-U", "3",                                                   0};
      const char* voldown[] = {"pactl", "set-sink-volume", "0", "-5%",                             NULL};
      const char* volup[]   = {"pactl", "set-sink-volume", "0", "+5%",                             NULL};
      const char* volmute[] = {"pactl", "set-sink-mute",   "0", "toggle",                          NULL};
      const char* scratch[] = {"${config.my.default.terminal}",                                       0};

      static struct key keys[] = {

          {MOD,                 XK_c,          win_kill,                {0}},
          {MOD,                 XK_h,          win_center,              {0}},
          {MOD,                 XK_Return,     win_fs,                  {0}},
          {Mod1Mask|ShiftMask,  XK_e,          wm_quit,                 {0}},
          {MOD,                 XK_r,          toggle_win_resize_mouse, {0}},

          {Mod1Mask,            XK_Tab,        win_next,                {0}},
          {Mod1Mask|ShiftMask,  XK_Tab,        win_prev,                {0}},

          {MOD,                 XK_space,      run,                     {.com = menu}},
          {MOD|ShiftMask,       XK_Return,     run,                     {.com = term}},
          {MOD,                 XK_apostrophe, scratchpad_toggle,       {.com = scratch}},

          {0,   XF86XK_AudioLowerVolume,       run,                     {.com = voldown}},
          {0,   XF86XK_AudioRaiseVolume,       run,                     {.com = volup}},
          {0,   XF86XK_AudioMute,              run,                     {.com = volmute}},
          {0,   XF86XK_MonBrightnessUp,        run,                     {.com = briup}},
          {0,   XF86XK_MonBrightnessDown,      run,                     {.com = bridown}},

          {MOD|Mod1Mask,        XK_Up,         win_half,                {.com = (const char*[]){"n"}}},
          {MOD|Mod1Mask,        XK_Down,       win_half,                {.com = (const char*[]){"s"}}},
          {MOD|Mod1Mask,        XK_Right,      win_half,                {.com = (const char*[]){"e"}}},
          {MOD|Mod1Mask,        XK_Left,       win_half,                {.com = (const char*[]){"w"}}},

          {MOD,                 XK_1,          ws_go,                   {.i = 1}},
          {MOD|ShiftMask,       XK_1,          win_to_ws,               {.i = 1}},
          {MOD,                 XK_2,          ws_go,                   {.i = 2}},
          {MOD|ShiftMask,       XK_2,          win_to_ws,               {.i = 2}},
          {MOD,                 XK_3,          ws_go,                   {.i = 3}},
          {MOD|ShiftMask,       XK_3,          win_to_ws,               {.i = 3}},
          {MOD,                 XK_4,          ws_go,                   {.i = 4}},
          {MOD|ShiftMask,       XK_4,          win_to_ws,               {.i = 4}},
          {MOD,                 XK_5,          ws_go,                   {.i = 5}},
          {MOD|ShiftMask,       XK_5,          win_to_ws,               {.i = 5}},
          {MOD,                 XK_6,          ws_go,                   {.i = 6}},
          {MOD|ShiftMask,       XK_6,          win_to_ws,               {.i = 6}},
      };
      #endif
    '';
  };

in

{

  options = {
    services.xserver.windowManager.ewm = {
      enable = mkEnableOption "ewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before ewm is started.
        '';
      };
      package = mkPackageOption pkgs "ewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "ewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "ewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${ewm}/bin/ewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.ewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = ewm;
    };

  };

}
