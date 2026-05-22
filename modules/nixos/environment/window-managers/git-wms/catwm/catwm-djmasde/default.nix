{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.catwm-djmasde;
  catwm-djmasde = pkgs.callPackage ./catwm-djmasde.nix {
    conf = ''

      #ifndef CONFIG_H
      #define CONFIG_H

      /* Mod (Mod1 == alt) and master size
         and I added panel size and  the windows key (Mod4 == Super)
         added shortcuts for different tiling modes
         added shortcuts for moving the window to the next workspace and back
         */
      #define MOD1            Mod1Mask
      #define MOD4            Mod4Mask
      #define MASTER_SIZE     0.5
      #define PANEL_HEIGHT    20
      #define BORDER_WIDTH    4
      #define ATTACH_ASIDE    1 /* 0=TRUE, 1=New window is master */
      #define DEFAULT_MODE    2 /* 0 = Horizontal, 1 = Fullscreen, 2 = Vertical */

      // Colors
      #define FOCUS           "#664422" // dkorange
      //#define FOCUS           "#956671" // pinkish
      #define UNFOCUS         "#004050" // blueish

      //if have gmrun...
      //const char* dmenucmd[] = {"gmrun",NULL};
      const char* dmenucmd[] = {"rofi","-show","drun","-theme",".config/rofi/themes/main.rasi",NULL};
      const char* urxvtcmd[] = {"${config.my.default.terminal}",NULL};
      const char* lockcmd[]  = {"x-lock",NULL};
      const char* next[]     = {"playerctl","next",NULL};
      const char* prev[]     = {"playerctl","previous",NULL};
      const char* toggle[]   = {"ncmpcpp","play-pause",NULL };
      const char* voldown[]  = {"pamixer","-ud","5",NULL};
      const char* volup[]    = {"pamixer","-ui","5",NULL};
      const char* firecmd[]  = {"${config.my.default.browser-alt-name}",NULL};
      const char* leafpad[]  = {"leafpad",NULL};
      const char* paharo[]   = {"pidgin",NULL};

      // for reboot and shutdown
      const char* rebootcmd[]     = {"sudo","reboot",NULL};
      const char* shutdowncmd[]   = {"sudo","shutdown","-h","now",NULL};

      // Avoid multiple paste
      #define DESKTOPCHANGE(K,N) \
          {  MOD4,             K,                          change_desktop, {.i = N}}, \
          {  MOD4|ShiftMask,   K,                          client_to_desktop, {.i = N}},
      // Shortcuts
      static struct key keys[] = {
          // MOD               KEY                         FUNCTION          ARGS
          {  MOD4|ShiftMask,   XK_Up,                      increase,         {NULL}},
          {  MOD4|ShiftMask,   XK_Down,                    decrease,         {NULL}},
          {  MOD4,             XK_c,                       kill_client,      {NULL}},
          {  MOD4,             XK_Right,                   next_win,         {NULL}},
          {  MOD1,             XK_Tab,                     next_win,         {NULL}},
          {  MOD1|ShiftMask,   XK_Tab,                     prev_win,         {NULL}},
          {  MOD4,             XK_k,                       prev_win,         {NULL}},
          {  MOD4|ShiftMask,   XK_l,                       spawn,            {.com = lockcmd}},
          {  0,                XF86XK_AudioNext,           spawn,            {.com = next}},
          {  0,                XF86XK_AudioPrev,           spawn,            {.com = prev}},
          {  0,                XF86XK_AudioPlay,           spawn,            {.com = toggle}},
          {  0,                XF86XK_AudioLowerVolume,    spawn,            {.com = voldown}},
          {  0,                XF86XK_AudioRaiseVolume,    spawn,            {.com = volup}},
          {  MOD4,             XK_space,                   spawn,            {.com = dmenucmd}},
          {  MOD4,             XK_b,                       spawn,            {.com = firecmd}},
          {  MOD4|ShiftMask,   XK_Return,                  spawn,            {.com = urxvtcmd}},
          {  MOD4,             XK_apostrophe,              spawn,            {.com = leafpad}},
          {  MOD4,             XK_t,                       spawn,            {.com = paharo}},
          {  MOD4,             XK_Up,                      move_up,          {NULL}},
          {  MOD4,             XK_Down,                    move_down,        {NULL}},
          {  MOD4,             XK_s,                       swap_master,      {NULL}},
          {  MOD4,             XK_Return,                  toggle_fullscreen,{NULL}},
          {  MOD4|ControlMask, XK_1,                       switch_vertical,  {NULL}},
          {  MOD4|ControlMask, XK_2,                       switch_horizontal,{NULL}},
          {  MOD1|ShiftMask,   XK_e,                       catkill,          {NULL}},
      //    {  MOD1|ControlMask, XK_r,                       spawn,          {.com = rebootcmd}},
      //    {  MOD1|ControlMask, XK_s,                       spawn,          {.com = shutdowncmd}},
             DESKTOPCHANGE(   XK_1,                                       0)
             DESKTOPCHANGE(   XK_2,                                       1)
             DESKTOPCHANGE(   XK_3,                                       2)
             DESKTOPCHANGE(   XK_4,                                       3)
             DESKTOPCHANGE(   XK_5,                                       4)
             DESKTOPCHANGE(   XK_6,                                       5)
             DESKTOPCHANGE(   XK_7,                                       6)
             DESKTOPCHANGE(   XK_8,                                       7)
             DESKTOPCHANGE(   XK_9,                                       8)
             DESKTOPCHANGE(   XK_0,                                       9)
      };

      #endif

    '';
  };

in

{

  options = {
    services.xserver.windowManager.catwm-djmasde = {
      enable = mkEnableOption "catwm-djmasde";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before catwm-djmasde is started.
        '';
      };
      package = mkPackageOption pkgs "catwm-djmasde" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "catwm-djmasde" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "catwm-djmasde";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${catwm-djmasde}/bin/catwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [
      cfg.package
      pkgs.dzen2
    ];

    services.xserver.windowManager.catwm-djmasde = {
      enable = true;
      extraSessionCommands = '' '';
      package = catwm-djmasde;
    };

  };

}
