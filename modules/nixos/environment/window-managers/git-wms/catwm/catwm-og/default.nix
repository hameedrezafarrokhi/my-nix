{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.catwm-og;
  xremap-catwm = pkgs.writeShellScriptBin "xremap-catwm" ''
    sleep 7
    xremap --watch --mouse .config/xremap/xremap.yaml
  '';
  catwm-og = pkgs.callPackage ./catwm-og.nix {
    conf = ''

      #ifndef CONFIG_H
      #define CONFIG_H

      // Mod (Mod1 == alt) and master size
      #define MOD             Mod4Mask
      #define MASTER_SIZE     0.5

      // Colors
      #define FOCUS           "rgb:bc/57/66"
      #define UNFOCUS         "rgb:88/88/88"

      // Borders and gap
      #define BORDER_SIZE     4
      #define GAP_SIZE        6

      const char* dmenucmd[] = {"rofi","-show","drun","-theme",".config/rofi/themes/main.rasi",NULL};
      const char* urxvtcmd[] = {"${config.my.default.terminal}",NULL};
      const char* lockcmd[]  = {"x-lock",NULL};
      const char* next[]     = {"playerctl","next",NULL};
      const char* prev[]     = {"playerctl","previous",NULL};
      const char* toggle[]   = {"ncmpcpp","play-pause",NULL };
      const char* voldown[]  = {"pamixer","-ud","5",NULL};
      const char* volup[]    = {"pamixer","-ui","5",NULL};

      // Avoid multiple paste
      #define DESKTOPCHANGE(K,N) \
          {  MOD,             K,                          change_desktop, {.i = N}}, \
          {  MOD|ShiftMask,   K,                          client_to_desktop, {.i = N}},

      // Shortcuts
      static struct key keys[] = {
          // MOD                 KEY                         FUNCTION        ARGS
          {  MOD|ShiftMask,      XK_Down,                    decrease,       {NULL}},
          {  MOD|ShiftMask,      XK_Up,                      increase,       {NULL}},
          {  MOD,                XK_c,                       kill_client,    {NULL}},
          {  MOD,                XK_Right,                   next_win,       {NULL}},
          {  Mod1Mask,           XK_Tab,                     next_win,       {NULL}},
          {  Mod1Mask|ShiftMask, XK_Tab,                     prev_win,       {NULL}},
          {  MOD,                XK_Left,                    prev_win,       {NULL}},
          {  MOD,                XK_Up,                      move_up,        {NULL}},
          {  MOD,                XK_Down,                    move_down,      {NULL}},
          {  MOD,                XK_s,                       swap_master,    {NULL}},
          {  MOD,                XK_Return,                  switch_mode,    {NULL}},
          {  MOD|ShiftMask,      XK_l,                       spawn,          {.com = lockcmd}},
          {  0,                  XF86XK_AudioNext,           spawn,          {.com = next}},
          {  0,                  XF86XK_AudioPrev,           spawn,          {.com = prev}},
          {  0,                  XF86XK_AudioPlay,           spawn,          {.com = toggle}},
          {  0,                  XF86XK_AudioLowerVolume,    spawn,          {.com = voldown}},
          {  0,                  XF86XK_AudioRaiseVolume,    spawn,          {.com = volup}},
          {  MOD,                XK_space,                   spawn,          {.com = dmenucmd}},
          {  MOD|ShiftMask,      XK_Return,                  spawn,          {.com = urxvtcmd}},
          {  MOD|ShiftMask,      XK_Right,                   next_desktop,   {NULL}},
          {  MOD|ShiftMask,      XK_Left,                    prev_desktop,   {NULL}},
             DESKTOPCHANGE(      XK_0,                                       0)
             DESKTOPCHANGE(      XK_1,                                       1)
             DESKTOPCHANGE(      XK_2,                                       2)
             DESKTOPCHANGE(      XK_3,                                       3)
             DESKTOPCHANGE(      XK_4,                                       4)
             DESKTOPCHANGE(      XK_5,                                       5)
             DESKTOPCHANGE(      XK_6,                                       6)
             DESKTOPCHANGE(      XK_7,                                       7)
             DESKTOPCHANGE(      XK_8,                                       8)
             DESKTOPCHANGE(      XK_9,                                       9)
          {  Mod1Mask|ShiftMask, XK_e,                       quit,           {NULL}}
      };

      #endif

    '';
  };

in

{

  options = {
    services.xserver.windowManager.catwm-og = {
      enable = mkEnableOption "catwm-og";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before catwm-og is started.
        '';
      };
      package = mkPackageOption pkgs "catwm-og" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "catwm-og" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "catwm-og";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${catwm-og}/bin/catwm-og &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package xremap-catwm ];

    services.xserver.windowManager.catwm-og = {
      enable = true;
      extraSessionCommands = ''
        #sleep 2
        systemctl --user stop numlockx.service
        numlockx off
        pkill numlockx
        systemctl --user stop xremap.service
        pkill xremap
        sleep 2
        xremap-catwm &
      '';
      package = catwm-og;
    };

  };

}
