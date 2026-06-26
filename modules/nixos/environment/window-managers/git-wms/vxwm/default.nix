{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.vxwm;
  vxwm = pkgs.callPackage ./vxwm.nix {
    conf = ''
#pragma once

/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 3;        /* border pixel of windows */
static const unsigned int snap      = 0;       /* snap pixel */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "monospace:size=10" };
static const char dmenufont[]       = "monospace:size=10";
#define COORDINATES_STYLE "[x%d y%d]" /* The style of coordinates displayed in bar, do not remove %d. */

static MAYBE_CONST char normbgcolor[]           = "#222222";
static MAYBE_CONST char normbordercolor[]       = "#444444";
static MAYBE_CONST char normfgcolor[]           = "#bbbbbb";
static MAYBE_CONST char selfgcolor[]            = "#eeeeee";
static MAYBE_CONST char selbordercolor[]        = "#005577";
static MAYBE_CONST char selbgcolor[]            = "#005577";
static MAYBE_CONST char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

#define CENTER_NEW_FLOATING_WINDOWS 1 // so, basically, it does what it says. (make 0 to turn off)
#define NEW_FLOATING_WINDOWS_APPEAR_UNDER_CURSOR 0 // so, basically, it does what it says. (make 0 to turn off)

#if GAPS
static const unsigned int gappx = 5;
#endif

#if BAR_HEIGHT
static const int user_bh = 0;
#endif

#if BAR_PADDING
static const int top_vertpad = 0;          /* top vertical padding of bar */
static const int bottom_vertpad = 0;       /* bottom vertical padding of bar */
static const int left_sidepad = 0;         /* left horizontal padding of bar */
static const int right_sidepad = 0;        /* right horizontal padding of bar */
#endif

#define BAR_ALWAYS_ON_TOP 1 /* Makes internal bar on top of other windows. */

#if EXTERNAL_BARS
#define EXTERNAL_BARS_ALWAYS_ON_TOP 1 /* Makes external bars on top of other windows. */
#endif

#if INFINITE_TAGS
#define PINNED_WINDOWS_ALWAYS_ON_TOP 1 /* Makes pinned windows on top of other windows */
#endif

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9" };

#if OCCUPIED_TAGS_DECORATION
static const char *occupiedtags[] = { "1+", "2+", "3+", "4+", "5+", "6+", "7+", "8+", "9+" };
#endif

#if INFINITE_TAGS
#define MOVE_CANVAS_STEP 120 /* Defines how many pixel will be jumped when using movecanvas function */
#endif

#if INFINITE_TAGS && IT_SHOW_COORDINATES_IN_BAR
#define COORDINATES_DIVISOR 10 /* Defines by what number coordinates on the bar will be divided, can be used for making numbers smaller which makes navigation easier */
#endif

#if MOVE_RESIZE_WITH_KEYBOARD
#define MOVE_WITH_KEYBOARD_STEP 50 /* Defines by how many pixels windows will be resized with keyboard */
#define RESIZE_WITH_KEYBOARD_STEP 50 /* Defines by how many pixels windows will be resized with keyboard */
#endif

#if AUTOSTART
/* vxwm will execute this on startup (can be skipped with -ignoreautostart vxwm flag). */

static const char *const autostart[] = {
	"st",
	NULL /* must end with NULL */
};
#endif

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Gimp",     NULL,       NULL,       0,            1,           -1 },
	{ "Firefox",  NULL,       NULL,       1 << 8,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
#if LOCK_MOVE_RESIZE_REFRESH_RATE
static const int refreshrate = 360;  /* refresh rate (per second) for client move/resize, set it to your monitor refresh rate or double of that*/
#endif //LOCK_MOVE_RESIZE_REFRESH_RATE
static const Layout layouts[] = {
	/* symbol     arrange function */
  { "><>",      NULL },    /* no layout function means floating behavior */
	{ "[]=",      tile },    /* first entry is default */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define ALTERNATE_MODKEY Mod1Mask

#define SCROLL_UP Button4
#define SCROLL_DOWN Button5

#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ Mod1Mask,                     KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbordercolor, "-sf", selfgcolor, NULL };

static const char *termcmd[]  = { "st", NULL };

#if ZOOM
static const char *zoomin[] = { "vcompmgr", "-Z", "+0.15", NULL }; // zoom in
static const char *zoomout[] = { "vcompmgr", "-Z", "-0.15", NULL }; // zoom out
static const char *zoomreset[] = { "vcompmgr", "-Z", "1", NULL }; // set zoom to 1
#endif

static const Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_p,      spawn,          {.v = dmenucmd } },
  { MODKEY|ShiftMask,             XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
	{ MODKEY,                       XK_i,      incnmaster,     {.i = +1 } },
	{ MODKEY,                       XK_d,      incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_h,      setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_l,      setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, swapmaster,     {0} },
	{ MODKEY,                       XK_0,      view,           {0} },
	{ MODKEY|ShiftMask,             XK_c,      killclient,     {0} },
	{ MODKEY,                       XK_t,      setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} }, //default toggle floating bind.
	{ MODKEY,                       XK_Tab,    view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, tagmon,         {.i = +1 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} },
#if XRDB
  { MODKEY,                       XK_F5,     xrdb,           {.v = NULL } },
#endif
#if FULLSCREEN
  { MODKEY|ShiftMask,             XK_f,      togglefullscr,  {0} },
#endif
#if ENHANCED_TOGGLE_FLOATING
  { MODKEY,                       XK_q,      enhancedtogglefloating, {0} }, //enhanced toggle floating bind.
#endif
#if GAPS
  { MODKEY,                       XK_minus,  setgaps,        {.i = -1 } },
  { MODKEY,                       XK_equal,  setgaps,        {.i = +1 } },
  { MODKEY|ShiftMask,             XK_equal,  setgaps,        {.i = 0  } },
#endif
#if MOVE_RESIZE_WITH_KEYBOARD
  { MODKEY,					              XK_Down,	moveresize,		{.v = (int []){ 0, MOVE_WITH_KEYBOARD_STEP, 0, 0 }}}, // Move window to down
  { MODKEY,					              XK_Up,		moveresize,		{.v = (int []){ 0, -MOVE_WITH_KEYBOARD_STEP, 0, 0 }}}, // Move window to up
  { MODKEY,					              XK_Right,	moveresize,		{.v = (int []){ MOVE_WITH_KEYBOARD_STEP, 0, 0, 0 }}}, // Move window to right
  { MODKEY,					              XK_Left,	moveresize,		{.v = (int []){ -MOVE_WITH_KEYBOARD_STEP, 0, 0, 0 }}}, // Move window to left
  { MODKEY|ControlMask,			      XK_Down,	moveresize,		{.v = (int []){ 0, 0, 0, RESIZE_WITH_KEYBOARD_STEP }}}, // Resize window
  { MODKEY|ControlMask,			      XK_Up,		moveresize,		{.v = (int []){ 0, 0, 0, -RESIZE_WITH_KEYBOARD_STEP }}}, // Resize window
  { MODKEY|ControlMask,			      XK_Right,	moveresize,		{.v = (int []){ 0, 0, RESIZE_WITH_KEYBOARD_STEP, 0 }}}, // Resize window
  { MODKEY|ControlMask,			      XK_Left,	moveresize,		{.v = (int []){ 0, 0, -RESIZE_WITH_KEYBOARD_STEP, 0 }}}, // Resize window
#endif
#if INFINITE_TAGS
  { MODKEY,                       XK_r,      homecanvas,       {0} }, // Return to x:0, y:0 position
  { MODKEY|ShiftMask,             XK_Left,   movecanvas,       {.i = 0} }, // Move your position to left
  { MODKEY|ShiftMask,             XK_Right,  movecanvas,       {.i = 1} }, // Move your position to right
  { MODKEY|ShiftMask,             XK_Up,     movecanvas,       {.i = 2} }, // Move your position up
  { MODKEY|ShiftMask,             XK_Down,   movecanvas,       {.i = 3} }, // Move your position down
  { MODKEY|ShiftMask,             XK_d,      centerwindow,     {0} },
  { MODKEY|ControlMask,           XK_z,      pinwindow,        {0} },
#endif
#if DIRECTIONAL_FOCUS
	{ ALTERNATE_MODKEY,             XK_Left,   focusdir,       {.i = 0 } }, // left
	{ ALTERNATE_MODKEY,             XK_Right,  focusdir,       {.i = 1 } }, // right
	{ ALTERNATE_MODKEY,             XK_Up,     focusdir,       {.i = 2 } }, // up
	{ ALTERNATE_MODKEY,             XK_Down,   focusdir,       {.i = 3 } }, // down
#endif
#if ZOOM
 { ALTERNATE_MODKEY,              XK_r,      spawn,          {.v = zoomreset } },
 { MODKEY,                        XK_equal,  spawn,          {.v = zoomin } },
 { MODKEY,                        XK_minus,  spawn,          {.v = zoomout } },
#endif
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
#if INFINITE_TAGS
  { ClkRootWin,           MODKEY|ShiftMask,         Button1,        movecanvasmouse,     {.f = 1.5 } },
  { ClkClientWin,         MODKEY|ShiftMask,         Button1,        movecanvasmouse,     {.f = 1.5 } },
  { ClkRootWin,           0,                        Button1,        movecanvasmouse,     {.f = 1.5 } },
  /* .f = 1 is moving multiplier, for example if set to 0.5, canvas will move 2 times slower, if set to 2, canvas will move 2 times faster.
     If you want inverted canvas move then set the value to a negative value. */
#endif
#if ZOOM
  { ClkRootWin,           MODKEY,         SCROLL_UP,      spawn,          {.v = zoomin } },
  { ClkRootWin,           MODKEY,         SCROLL_DOWN,    spawn,          {.v = zoomout } },

  { ClkClientWin,         MODKEY,         SCROLL_UP,      spawn,          {.v = zoomin } },
  { ClkClientWin,         MODKEY,         SCROLL_DOWN,    spawn,          {.v = zoomout } },
#endif
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        swapmaster,     {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};


    '';

    modules = ''
#pragma once

/* vxwm compile-time options */

/* KILLER FEATURES */
#define INFINITE_TAGS 1
/*
Most tiling window managers (like the default dwm) treat your screen like a slide-projector. You click a button, and the current "slide" is swapped for another. If an window is off-screen, it doesn't exist.

With infinite tags enabled, vxwm treats your screen like a magnifying glass over a giant wooden desk.

1. The Canvas is Infinite
Your windows aren't "on" tags. They are placed on a massive, invisible surface. Your monitor is just a small window through which you look at that surface.

2. Move the View, Not Just the Windows
Instead of managing "layers" or "hidden states," you manage position.

Want more space? Slide the view over.
Can't find a window? Switch your focus to it, and the world slides until that window is right under your nose.
Lost? Hit the "homecanvas" keybind to snap your view back to the start.
Even though this sounds complex, it is actually pretty lightweight, and is very easy to use.

 */
#define IT_SHOW_COORDINATES_IN_BAR 1 // Shows your coordinates in the bar, pretty impossible to use infinite tags without this.
#define ZOOM 1 // Zoom integration, requires vcompmgr installed and running.


/* Move/Resize */
#define BETTER_RESIZE 1 // Enables 8 sided window resize.
#define BR_CHANGE_CURSOR 1 // When resizing windows while having BETTER_RESIZE set to 1, the cursor will change depending on from which side you are resizing.
#define LOCK_MOVE_RESIZE_REFRESH_RATE 1 // Recommended to use on every pc, because cpu (software) rendered apps like ST will lag when resizing even if you have a good pc.
#define USE_RESIZECLIENT_FUNC 0 // Use resizeclient function instead of resize function which ignores window's resize hints, not recommended.
#define RESIZING_WINDOWS_IN_ALL_LAYOUTS_FLOATS_THEM 1 // yeah.
#define MOVE_RESIZE_WITH_KEYBOARD 1 // Allows to move and resize windows with keyboard.



/* Kind of eye candy */
#define GAPS 1 // Gaps support.
#define XRDB 1 // Xrdb support.



/* Tagging */
#define TAG_TO_TAG 1 // If you switch to tag where you already are, it'll switch to previous tag.
#define SLOWER_TAGS_ANIMATION 0 // This slows down tags animation speed, which results in smoother tags animations (requires picom to see any difference).
#define WINDOWMAP 1
/* This makes the windows get mapped or unmapped in X11. This results in certain
   behaviour being enabled, some examples are: fix issues with some applications
   losing input forever after a tag change or when you use a compositor like picom,
   your windows will fade in and out when you switch dwm tags. */

#define PDWM_LIKE_TAGS_ANIMATION 0
/* This makes function showhide be like in pdwm, if using a compositor like picom,
   this results in an alternative tags animation. */



/* Bar */
/* Internal */
#define ALT_CENTER_OF_BAR_COLOR 1 // changes center of bar color to a dark color.
#define BAR_HEIGHT 1 // Support for changing bar height.
#define BAR_PADDING 1 // Support for changing the bar padding.
#define OCCUPIED_TAGS_DECORATION 0 // This provides the ability to use an alternative text for tags which contain at least one window aka occupied tags.

/* External */
#define EXTERNAL_BARS 1 // Support for external bars, essencial if you want to use external bars.
#define EWMH_TAGS 1 // Support for EWMH tags, recommended if you want to use external bars with less pain



/* Warp to client */
#define WARP_TO_CLIENT 0 // Includes the warp to client function needed for all options below.
#define WARP_TO_CENTER_OF_NEW_WINDOW 0 // Warps the cursor to center of the new window.
#define WARP_TO_CENTER_OF_PREVIOUS_WINDOW 0 // Warps cursor to center of the previous window after closing a window.
#define WARP_TO_CENTER_OF_SWAPMASTERED_WINDOW 0 // Warps cursor to center of the window that was swapped using swapmaster function.
#define WARP_TO_CENTER_OF_WINDOW_AFFECTED_BY_INCNMASTER 0 // Warps the cursor to center of the window that gets affected in use of incnmaster.
#define WARP_TO_CENTER_OF_WINDOW_AFFECTED_BY_ENHANCED_TOGGLE_FLOATING 0 // Warps cursor to center of the window that was affected by using enhancedtogglefloating function.
#define WARP_TO_CENTER_OF_WINDOW_AFFECTED_BY_FOCUSSTACK 0 // Warps cursor to center of the window that was focused by using focusstack function.
#define WARP_TO_CENTER_OF_WINDOW_MOVED_BY_KEYBOARD 0 // Warps cursor to center of the window that is moved by moveresize function.



/* Misc */
#define AUTOSTART 0 // Support for vxwm being able to start apps defined in config.h in startup.
#define FULLSCREEN 1 // Support for toggling fullscreen.
#define MOVE_IN_TILED 1 // Support for moving windows in tiled mode.
#define DIRECTIONAL_FOCUS 1 // yeah.
#define DIRECTIONAL_MOVE 1
/* Makes moving windows in tiled layout possible with keyboard and it is directional,
   bind for move is in #if MOVE_RESIZE_WITH_KEYBOARD section which makes it depending on
   MOVE_RESIZE_WITH_KEYBOARD at the first sight but, it doesn't. You can bind the movedir
   function manually which makes it independent like this:
#if DIRECTIONAL_MOVE
  { MODKEY|ALTERNATE_MODKEY, XK_Left,  movedir, {.i = 0} }, // Left
  { MODKEY|ALTERNATE_MODKEY, XK_Right, movedir, {.i = 1} }, // Right
  { MODKEY|ALTERNATE_MODKEY, XK_Up,    movedir, {.i = 2} }, // Up
  { MODKEY|ALTERNATE_MODKEY, XK_Down,  movedir, {.i = 3} }, // Down
#endif
*/



/* Floating */
/* Recomended to use with ALWAYS_CENTER_NEW_FLOATING_WINDOWS set to 1. */

#define FLOATING_LAYOUT_FLOATS_WINDOWS 1
/* By default, in floating layout, windows appear to be floating, but, for dwm,
   they are not. Because of this, when switching to tiled layout after floating
   layout, windows will be tiled, enable this if you don't want that behaviour. */

#define ENHANCED_TOGGLE_FLOATING 1
/* Support for enhanced toggle floating, when toggling floating window will
   resize to its natural size, and in floating layout, window will be tiled.
   REQUIRES "FLOATING_LAYOUT_FLOATS_WINDOWS" SET TO 1 TO WORK PROPERLY. */

#define RESTORE_SIZE_AND_POS_ETF 1 // Restore previous size and position of window when toggling floating



/* Dependency list */
/* INFINITE_TAGS requires WINDOWMAP, please set WINDOWMAP to 1, if not, it will be automatically enabled.
 * ENHANCED_TOGGLE_FLOATING requires FLOATING_LAYOUT_FLOATS_WINDOWS, please set FLOATING_LAYOUT_FLOATS_WINDOWS to 1, if not, it will be automatically enabled.  */


    '';
  };

in

{

  options = {
    services.xserver.windowManager.vxwm = {
      enable = mkEnableOption "vxwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before vxwm is started.
        '';
      };
      package = mkPackageOption pkgs "vxwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "vxwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "vxwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${vxwm}/bin/vxwm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.vxwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = vxwm;
    };

  };

}
