{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.sowm;
  sowm = pkgs.callPackage ./sowm.nix {

    #patches = [
    #
    #  # Titlebar
    #  (fetchpatch {
    #    url = "https://patch-diff.githubusercontent.com/raw/dylanaraps/sowm/pull/57.patch";
    #    sha256 = "sha256-AAAffBjz7+0Khyn9cAAAzReoLTqAAA9gVGshYARGAAA=";
    #  })
    #
    #];

    conf = ''
      #ifndef CONFIG_H
      #define CONFIG_H

      #define MOD Mod4Mask

      const char* menu[]    = {"rofi", "-show", "drun", "-theme", ".config/rofi/themes/main.rasi",  0};
      const char* term[]    = {"${config.my.default.terminal}",                          0};
      const char* scrot[]   = {"flameshot", "gui", "--path", "Pictures/Screenshots/",    0};
      const char* briup[]   = {"brtctl", "get", "1",                                     0};
      const char* bridown[] = {"brtctl", "get", "1",                                     0};
      const char* voldown[] = {"amixer", "sset", "Master", "5%-",         0};
      const char* volup[]   = {"amixer", "sset", "Master", "5%+",         0};
      const char* volmute[] = {"amixer", "sset", "Master", "toggle",      0};

      static struct key keys[] = {
          {MOD,                XK_1,      ws_go,      {.i = 1}},
          {MOD|ShiftMask,      XK_1,      win_to_ws,  {.i = 1}},
          {MOD,                XK_2,      ws_go,      {.i = 2}},
          {MOD|ShiftMask,      XK_2,      win_to_ws,  {.i = 2}},
          {MOD,                XK_3,      ws_go,      {.i = 3}},
          {MOD|ShiftMask,      XK_3,      win_to_ws,  {.i = 3}},
          {MOD,                XK_4,      ws_go,      {.i = 4}},
          {MOD|ShiftMask,      XK_4,      win_to_ws,  {.i = 4}},
          {MOD,                XK_5,      ws_go,      {.i = 5}},
          {MOD|ShiftMask,      XK_5,      win_to_ws,  {.i = 5}},
          {MOD,                XK_6,      ws_go,      {.i = 6}},
          {MOD|ShiftMask,      XK_6,      win_to_ws,  {.i = 6}},

          {MOD,                XK_c,      win_kill,   {0}},
          {MOD,                XK_s,      win_center, {0}},
          {MOD,                XK_Return, win_fs,     {0}},

          {MOD,                XK_Tab,    win_next,   {0}},
          {MOD|ShiftMask,      XK_Tab,    win_prev,   {0}},

          {MOD,                XK_space,  run,        {.com = menu}},
          {MOD,                XK_p,      run,        {.com = scrot}},
          {MOD|ShiftMask,      XK_Return, run,        {.com = term}},

          {0,   XF86XK_AudioLowerVolume,  run,        {.com = voldown}},
          {0,   XF86XK_AudioRaiseVolume,  run,        {.com = volup}},
          {0,   XF86XK_AudioMute,         run,        {.com = volmute}},
          {0,   XF86XK_MonBrightnessUp,   run,        {.com = briup}},
          {0,   XF86XK_MonBrightnessDown, run,        {.com = bridown}},
      };

      #endif
    '';

  };

in

{

  options = {
    services.xserver.windowManager.sowm = {
      enable = mkEnableOption "sowm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before sowm is started.
        '';
      };
      package = mkPackageOption pkgs "sowm" {
        example = ''
          pkgs.callPackage ./sowm.nix {
            patches = [
              (super.fetchpatch {
                url = "https://patch-diff.githubusercontent.com/raw/dylanaraps/sowm/pull/57.patch";
                sha256 = "sha256-AAAffBjz7+0Khyn9cAAAzReoLTqAAA9gVGshYARGAAA=";
              })
            ];
          }
        '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "sowm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "sowm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${sowm}/bin/sowm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      pkgs.xsetroot
    ];

    services.xserver.windowManager.sowm = {
      enable = true;
      extraSessionCommands = '' '';
      package = sowm;
    };

  };

}
