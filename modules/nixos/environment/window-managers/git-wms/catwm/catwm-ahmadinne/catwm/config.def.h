 /* config.h for catwm-0.0.5.c
 *
 *  ( o   o )  Made by cat...
 *  (  =^=  )
 *  (        )            ... for cat!
 *  (         )
 *  (          ))))))________________ Cute And Tiny Window Manager
 *  ______________________________________________________________________________
 *
 */

#ifndef CONFIG_H
#define CONFIG_H

#define MOD1            Mod1Mask
#define MASTER_SIZE     0.5
#define PANEL_HEIGHT    20
#define BORDER_WIDTH    2
#define ATTACH_ASIDE    0 /* 0=TRUE, 1=New window is master */
#define DEFAULT_MODE    2 /* 0 = Horizontal, 1 = Fullscreen, 2 = Vertical */
#define SMART_BORDER	1 /* 0=TRUE, 1=FALSE */
#define WINDOW_GAPS		10

// Colors
#define FOCUS           "#1f1f28"
#define UNFOCUS         "#f2ecbc"
#define FULLSCREEN		"#c84053"

const char* dmenucmd[] = {"rofi","-show","drun",NULL};
const char* urxvtcmd[] = {"alacritty",NULL};
const char* lockcmd[]  = {"xlock",NULL};
const char* next[]     = {"ncmpcpp","next",NULL};
const char* prev[]     = {"ncmpcpp","prev",NULL};
const char* toggle[]   = {"ncmpcpp","toggle",NULL };
const char* voldown[]  = {"amixer","set","PCM","5%-",NULL};
const char* volup[]    = {"amixer","set","PCM","5%+",NULL};
const char* brsrcmd[]  = {"google-chrome-beta",NULL};
const char* filecmd[]  = {"pcmanfm",NULL};
const char* hintcmd[]  = {"hints",NULL};
const char* clipcmd[]  = {"clipmenu",NULL};

// for reboot and shutdown
const char* rebootcmd[]     = {"sudo","reboot",NULL};
const char* shutdowncmd[]   = {"sudo","shutdown","-h","now",NULL};

// Avoid multiple paste
#define DESKTOPCHANGE(K,N) \
    {  MOD1,             K,                          change_desktop, {.i = N}}, \
    {  MOD1|ShiftMask,   K,                          client_to_desktop, {.i = N}},
// Shortcuts
static struct key keys[] = {
    // MOD               KEY                         FUNCTION        ARGS
    {  MOD1,             XK_h,                       increase,       {NULL}},
    {  MOD1,             XK_l,                       decrease,       {NULL}},
    {  MOD1,   		 XK_q,                       kill_client,    {NULL}},
    {  MOD1,             XK_j,                       next_win,       {NULL}},
    {  MOD1,             XK_k,                       prev_win,       {NULL}},
    {  MOD1,             XK_c,                       spawn,          {.com = lockcmd}},
    {  MOD1,             XK_Right,                   spawn,          {.com = next}},
    {  MOD1,             XK_Left,                    spawn,          {.com = prev}},
    {  MOD1,             XK_Down,                    spawn,          {.com = toggle}},
    {  MOD1,             XK_F1,                      spawn,          {.com = voldown}},
    {  MOD1,             XK_F2,                      spawn,          {.com = volup}},
    {  MOD1,             XK_a,                       spawn,          {.com = dmenucmd}},
    {  MOD1,             XK_b,                       spawn,          {.com = brsrcmd}},
    {  MOD1,             XK_e,                       spawn,          {.com = filecmd}},
    {  MOD1,   		 XK_t,                       spawn,          {.com = urxvtcmd}},
    {  MOD1,		 XK_v,			     spawn,	     {.com = clipcmd}},
    {  MOD1,		 XK_semicolon,		     spawn,	     {.com = hintcmd}},
// Others
    {  MOD1|ShiftMask,   XK_j,                       move_up,        {NULL}},
    {  MOD1|ShiftMask,   XK_k,                       move_down,      {NULL}},
    {  MOD1,   		 XK_Return,                  focus_master,   {NULL}},
    {  MOD1|ShiftMask,   XK_Return,                  swap_master,    {NULL}},
    {  MOD1,   		 XK_f,                       toggle_fullscreen,{NULL}},
    {  MOD1|ShiftMask,   XK_v,                       switch_vertical,{NULL}},
    {  MOD1|ShiftMask,   XK_h,                       switch_horizontal,{NULL}},
    {  MOD1|ShiftMask,   XK_Delete,                  catkill,        {NULL}},
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
