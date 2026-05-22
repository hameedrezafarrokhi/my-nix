{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.monsterwm;
  monsterwm = pkgs.callPackage ./monsterwm.nix {
    patches = [
    # Master Branch Patches
      ./patches-master/centerwindow.patch
      ./patches-master/fibonacci.patch
      ./patches-master/initlayouts.patch
      ./patches-master/monocleborders.patch
      ./patches-master/rectangle.patch
      ./patches-master/showhide.patch
      ./patches-master/warpcursor.patch
     #./patches-master/windowtitles.patch    # FAILS
     #./patches-master/nmaster.patch         # FAILS
     #./patches-master/uselessgaps.patch     # FAILS

    # Xinerama Master Branch Patches                  # All Fails
    ##./patches-xinerama-master/centerwindow.patch
    ##./patches-xinerama-master/fibonacci.patch
    ##./patches-xinerama-master/initlayouts.patch
    ##./patches-xinerama-master/monocleborders.patch
    ##./patches-xinerama-master/rectangle.patch
    ##./patches-xinerama-master/showhide.patch
    ##./patches-xinerama-master/warpcursor.patch
    ##./patches-xinerama-master/windowtitles.patch    # FAILS
    ##./patches-xinerama-master/nmaster.patch         # FAILS
    ##./patches-xinerama-master/uselessgaps.patch     # FAILS

    ];

    # Config from patched monsterwm (get it from the store path)
    conf = ''
      /* see LICENSE for copyright and license */

      #ifndef CONFIG_H
      #define CONFIG_H

      /** modifiers **/
      #define MOD1            Mod1Mask    /* ALT key */
      #define MOD4            Mod4Mask    /* Super/Windows key */
      #define CONTROL         ControlMask /* Control key */
      #define SHIFT           ShiftMask   /* Shift key */

      /** generic settings **/
      #define MASTER_SIZE     0.52
      #define SHOW_PANEL      True      /* show panel by default on exec */
      #define TOP_PANEL       True      /* False means panel is on bottom */
      #define PANEL_HEIGHT    18        /* 0 for no space for panel, thus no panel */
      #define DEFAULT_MODE    TILE      /* initial layout/mode: TILE MONOCLE BSTACK GRID FLOAT */
      #define ATTACH_ASIDE    True      /* False means new window is master */
      #define FOLLOW_WINDOW   False     /* follow the window when moved to a different desktop */
      #define FOLLOW_MOUSE    False     /* focus the window the mouse just entered */
      #define CLICK_TO_FOCUS  True      /* focus an unfocused window when clicked  */
      #define FOCUS_BUTTON    Button3   /* mouse button to be used along with CLICK_TO_FOCUS */
      #define BORDER_WIDTH    2         /* window border width */
      #define FOCUS           "#ff950e" /* focused window border color    */
      #define UNFOCUS         "#444444" /* unfocused window border color  */
      #define MINWSZ          50        /* minimum window size in pixels  */
      #define DEFAULT_DESKTOP 0         /* the desktop to focus initially */
      #define DESKTOPS        5         /* number of desktops - edit DESKTOPCHANGE keys to suit */

      /**
       * layouts for each desktops
       */
      static const int initlayouts[] = { TILE, BSTACK, GRID, MONOCLE, FLOAT, };

      /**
       * open applications to specified desktop with specified mode.
       * if desktop is negative, then current is assumed
       */
      static const AppRule rules[] = { \
          /*  class     desktop  follow  float */
          { "MPlayer",     3,    True,   False },
          { "Gimp",        0,    False,  True  },
      };

      /* helper for spawning shell commands */
      #define SHCMD(cmd) {.com = (const char*[]){"/bin/sh", "-c", cmd, NULL}}

      /**
       * custom commands
       * must always end with ', NULL };'
       */
      static const char *termcmd[] = { "xterm",     NULL };
      static const char *menucmd[] = { "dmenu_run", NULL };

      #define DESKTOPCHANGE(K,N) \
          {  MOD1,             K,              change_desktop, {.i = N}}, \
          {  MOD1|ShiftMask,   K,              client_to_desktop, {.i = N}},

      /**
       * keyboard shortcuts
       */
      static Key keys[] = {
          /* modifier          key            function           argument */
          {  MOD1,             XK_b,          togglepanel,       {NULL}},
          {  MOD4,             XK_s,          showhide,          {NULL}},
          {  MOD1,             XK_BackSpace,  focusurgent,       {NULL}},
          {  MOD1|SHIFT,       XK_c,          killclient,        {NULL}},
          {  MOD4,             XK_c,          centerwindow,      {NULL}},
          {  MOD1,             XK_j,          next_win,          {NULL}},
          {  MOD1,             XK_k,          prev_win,          {NULL}},
          {  MOD1,             XK_h,          resize_master,     {.i = -10}}, /* decrease size in px */
          {  MOD1,             XK_l,          resize_master,     {.i = +10}}, /* increase size in px */
          {  MOD1,             XK_o,          resize_stack,      {.i = -10}}, /* shrink   size in px */
          {  MOD1,             XK_p,          resize_stack,      {.i = +10}}, /* grow     size in px */
          {  MOD1|CONTROL,     XK_h,          rotate,            {.i = -1}},
          {  MOD1|CONTROL,     XK_l,          rotate,            {.i = +1}},
          {  MOD1|SHIFT,       XK_h,          rotate_filled,     {.i = -1}},
          {  MOD1|SHIFT,       XK_l,          rotate_filled,     {.i = +1}},
          {  MOD1,             XK_Tab,        last_desktop,      {NULL}},
          {  MOD1,             XK_Return,     swap_master,       {NULL}},
          {  MOD1|SHIFT,       XK_j,          move_down,         {NULL}},
          {  MOD1|SHIFT,       XK_k,          move_up,           {NULL}},
          {  MOD1|SHIFT,       XK_t,          switch_mode,       {.i = TILE}},
          {  MOD1|SHIFT,       XK_m,          switch_mode,       {.i = MONOCLE}},
          {  MOD1|SHIFT,       XK_b,          switch_mode,       {.i = BSTACK}},
          {  MOD1|SHIFT,       XK_g,          switch_mode,       {.i = GRID}},
          {  MOD1|SHIFT,       XK_f,          switch_mode,       {.i = FLOAT}},
          {  MOD1|SHIFT,       XK_i,          switch_mode,       {.i = FIBONACCI}},
          {  MOD1|CONTROL,     XK_r,          quit,              {.i = 0}}, /* quit with exit value 0 */
          {  MOD1|CONTROL,     XK_q,          quit,              {.i = 1}}, /* quit with exit value 1 */
          {  MOD1|SHIFT,       XK_Return,     spawn,             {.com = termcmd}},
          {  MOD4,             XK_v,          spawn,             {.com = menucmd}},
          {  MOD4,             XK_j,          moveresize,        {.v = (int []){   0,  25,   0,   0 }}}, /* move down  */
          {  MOD4,             XK_k,          moveresize,        {.v = (int []){   0, -25,   0,   0 }}}, /* move up    */
          {  MOD4,             XK_l,          moveresize,        {.v = (int []){  25,   0,   0,   0 }}}, /* move right */
          {  MOD4,             XK_h,          moveresize,        {.v = (int []){ -25,   0,   0,   0 }}}, /* move left  */
          {  MOD4|SHIFT,       XK_j,          moveresize,        {.v = (int []){   0,   0,   0,  25 }}}, /* height grow   */
          {  MOD4|SHIFT,       XK_k,          moveresize,        {.v = (int []){   0,   0,   0, -25 }}}, /* height shrink */
          {  MOD4|SHIFT,       XK_l,          moveresize,        {.v = (int []){   0,   0,  25,   0 }}}, /* width grow    */
          {  MOD4|SHIFT,       XK_h,          moveresize,        {.v = (int []){   0,   0, -25,   0 }}}, /* width shrink  */
             DESKTOPCHANGE(    XK_F1,                             0)
             DESKTOPCHANGE(    XK_F2,                             1)
             DESKTOPCHANGE(    XK_F3,                             2)
             DESKTOPCHANGE(    XK_F4,                             3)
             DESKTOPCHANGE(    XK_F5,                             4)
      };

      /**
       * mouse shortcuts
       */
      static Button buttons[] = {
          {  MOD1,    Button1,     mousemotion,   {.i = MOVE}},
          {  MOD1,    Button3,     mousemotion,   {.i = RESIZE}},
          {  MOD4,    Button3,     spawn,         {.com = menucmd}},
      };
      #endif

      /* vim: set expandtab ts=4 sts=4 sw=4 : */

    '';
  };

  mopag = pkgs.callPackage ./mopag.nix {
    conf = ''
/**
 * Matus Telgarsky <chisel@gmail.com>
 * gcc -o mopag -std=c99 -pedantic -Wall -Wextra -Os mopag.c -lX11
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <assert.h>
#include <sys/select.h>
#include <X11/Xlib.h>

#define HEIGHT      8
#define FATTICK_W   8
#define TOP         True        /* show on top or bottom of the screen */
#define GAP         (3)         /* space above when on top. space below when on bottom */
#define BG          "#5f5f5f"
#define FG          "#77bee0"
#define URFG        "#ff8278"
#define URBG        "#c5000b"
#define WINFG       "#dddddd"
#define WINBG       "#5f5f5f"

typedef struct {
    unsigned int nwins;
    unsigned int mode;
    unsigned int urgent;
} DeskInfo;

enum { BORED, ERROR, RERENDER };

static void cleanup();
static int parse();
static void render();
static void setup();

static long fg, bg, urfg, urbg, winfg, winbg;
static unsigned int currdesk, ndesks = 0;
static int screen, scrwidth;
static Display *dis;
static Window root, w;
static Pixmap pm;
static GC gc;
static DeskInfo *di = NULL;

void setup()
{
    assert((dis = XOpenDisplay(NULL)));
    screen = DefaultScreen(dis);
    root = RootWindow(dis, screen);
    scrwidth  = DisplayWidth(dis, screen);

    long *col_vars[] = { &fg, &bg, &urfg, &urbg, &winfg, &winbg, NULL };
    const char *col_strs[] = { FG, BG, URFG, URBG, WINFG, WINBG, NULL };
    XColor c;
    for (unsigned int i = 0; col_vars[i]; ++i) {
        assert(XAllocNamedColor(dis, DefaultColormap(dis, screen), col_strs[i], &c, &c));
        *col_vars[i] = c.pixel;
    }

    XSetWindowAttributes wa = { .background_pixel = bg, .override_redirect = 1, .event_mask = ExposureMask, };
    w = XCreateWindow(dis, root, 0,
            (TOP) ? GAP : DisplayHeight(dis, screen) - HEIGHT - GAP,
            scrwidth, HEIGHT, 1, CopyFromParent, InputOutput, CopyFromParent,
            CWBackPixel | CWOverrideRedirect | CWEventMask, &wa);
    XMapWindow(dis, w);
    XSetWindowBorderWidth(dis, w, 0);

    XGCValues gcv = { .graphics_exposures = 0, }; /* otherwise get NoExpose on XCopyArea */
    gc = XCreateGC(dis, root, GCGraphicsExposures, &gcv);
    pm = XCreatePixmap(dis, w, scrwidth, HEIGHT, DefaultDepth(dis,screen));
}

int parse()
{
    static DeskInfo *di_temp;
    static unsigned int cur_desk_temp;

    char buf2[2048];
    ssize_t ret = read(STDIN_FILENO, buf2, sizeof(buf2));
    assert(buf2[ret - 1] == '\n');
    assert(ret > 2); /* XXX I had this fail once! (after 1 week of use?) */
    unsigned int pos2 = ret - 2;
    while (pos2 > 0 && buf2[pos2] != '\n') pos2 -= 1;
    printf("pos2 %u\n", pos2);
    char *buf = buf2 + pos2;

    int rerender = 0;

    if (!di) {
        char *s;
        assert(s = strrchr(buf, ' '));
        ndesks = atoi(s) + 1;
        assert((di = malloc(ndesks * sizeof(DeskInfo))));
        assert((di_temp = malloc(ndesks * sizeof(DeskInfo))));
        rerender = 1;
    }

    char *pos = buf;
    for (unsigned int i = 0; i < ndesks; ++i)
    {
        unsigned int is_cur, d;
        int offset;
        int res = sscanf(pos, "%u:%u:%u:%u:%u%n", &d, &di_temp[i].nwins,
                &di_temp[i].mode, &is_cur, &di_temp[i].urgent, &offset);
        printf("[%u, %u:%u:%u:%u:%u] ", res, d, di_temp[i].nwins,
                di_temp[i].mode, is_cur, di_temp[i].urgent);
        if (res < 5 || d != i) { /* %n doesn't count */
            fprintf(stderr, "Ignoring malformed input.\n");
            return ERROR;
        }

        if (is_cur)
            cur_desk_temp = i;

        if (!rerender &&
                (di_temp[i].nwins != di[i].nwins
                 || di_temp[i].mode != di[i].mode
                 || di_temp[i].urgent != di[i].urgent
                 || (is_cur != (currdesk == i)) ) )
            rerender = 1;
        printf("(re %u) ", rerender);

        pos += offset; /* okay if goes off end */
    }

    if (rerender) {
        currdesk = cur_desk_temp;
        DeskInfo *t = di;
        di = di_temp;
        di_temp = t;
        return RERENDER;
    } else return BORED;
}

void render()
{
    XSetForeground(dis, gc, bg);
    XFillRectangle(dis, pm, gc, 0, 0, scrwidth, HEIGHT);

    for (unsigned int i = 0; i < ndesks; ++i)
    {
        unsigned int start = i * scrwidth/ ndesks;
        unsigned int end = (i + 1) * scrwidth / ndesks;
        unsigned int width = end - start;

        if (i == currdesk || di[i].urgent) {
            XSetForeground(dis, gc, di[i].urgent ? ((i == currdesk) ? urfg : urbg) : fg);
            XFillRectangle(dis, pm, gc, start, 0, width, HEIGHT);
        }


        printf("[%u, %u] ", i, di[i].nwins);
        if (di[i].nwins) {
            //XSetForeground(dis, gc, (i == currdesk) ? bg : fg);

            unsigned int tick_width = width / di[i].nwins / 4;
            tick_width = (tick_width > FATTICK_W) ? FATTICK_W : tick_width;
            unsigned int nticks = di[i].nwins;
            if (!tick_width) {
                tick_width = 1;
                nticks = width / 4;
            }

            for (unsigned int j = 0; j < nticks; ++j) {
                XSetForeground(dis, gc, winbg);
                XFillRectangle(dis, pm, gc, start + tick_width * (2 * j + 1), 0,
                        tick_width,HEIGHT);
                if (tick_width > 2 && HEIGHT > 2) {
                    XSetForeground(dis, gc, winfg);
                    XFillRectangle(dis, pm, gc, start + tick_width * (2 * j + 1) +1, 1,
                            tick_width - 2, HEIGHT - 2);
                }
            }
        } else {
            /* XXX this debugging check shows the status indicator bug is in monster, not with me */
            //XSetForeground(dis, gc, winbg);
            //XFillRectangle(dis, pm, gc, start+FATTICK_W*5, 0, FATTICK_W * 5, HEIGHT);
        }
    }
    printf("\n");
}

void cleanup()
{
    //di not free()'d for solidarity with di_temp
    XFreeGC(dis, gc);
    XFreePixmap(dis, pm);
    XDestroyWindow(dis, w);
    XCloseDisplay(dis);
}

int main()
{
    setup();

    int xfd = ConnectionNumber(dis);
    int nfds = 1 + ((xfd > STDIN_FILENO) ? xfd : STDIN_FILENO);
    while (1) {
        int redraw = 0;
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(xfd, &fds);
        FD_SET(STDIN_FILENO, &fds);
        select(nfds, &fds, NULL, NULL, NULL);

        if (FD_ISSET(STDIN_FILENO, &fds)) {
            if (parse() == RERENDER) {
                render();
                redraw = 1;
            }
        }

        if (FD_ISSET(xfd, &fds)) {
            /* XXX I still (2012-02-28) can drop some exposes
             * test: start xscreensaver, leave it, BAM, mopag not redrawn
             */
            XEvent xev;
            while (XPending(dis)) {
                XNextEvent(dis, &xev);
                printf("EXPOSE\n");
                if (xev.type == Expose)
                    redraw = 1;
                else
                    fprintf(stderr, "weird event of type %u\n", xev.type);
            }
        }

        if (redraw)
            XCopyArea(dis, pm, w, gc, 0, 0, scrwidth, HEIGHT, 0, 0);

        XSync(dis, False);
    }

    cleanup();
}

    '';
  };

  bar = pkgs.callPackage ./bar.nix {
    conf = ''
/* The height of the bar (in pixels) */
#define BAR_HEIGHT  18
/* The width of the bar. Set to -1 to fit screen */
#define BAR_WIDTH   -1
/* Offset from the left. Set to 0 to have no effect */
#define BAR_OFFSET 0
/* Choose between an underline or an overline */
#define BAR_UNDERLINE 1
/* The thickness of the underline (in pixels). Set to 0 to disable. */
#define BAR_UNDERLINE_HEIGHT 2
/* Default bar position, overwritten by '-b' switch */
#define BAR_BOTTOM 0
/* The fonts used for the bar, comma separated. Only the first 2 will be used. */
#define BAR_FONT       "-*-terminus-medium-r-normal-*-12-*-*-*-c-*-*-1","fixed"
/* Color palette */
#define COLOR0  0x1A1A1A /* background */
#define COLOR1  0xA9A9A9 /* foreground */
#define COLOR2  0x303030
#define COLOR3  0xF92672
#define COLOR4  0xA6E22E
#define COLOR5  0xFD971F
#define COLOR6  0x66D9EF
#define COLOR7  0x9E6FFE
#define COLOR8  0xAF875F
#define COLOR9  0xCCCCC6

    '';
  };

in

{

  options = {
    services.xserver.windowManager.monsterwm = {
      enable = mkEnableOption "monsterwm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before monsterwm is started.
        '';
      };
      package = mkPackageOption pkgs "monsterwm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "monsterwm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "monsterwm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${monsterwm}/bin/monsterwm | ${mopag}/bin/mopag &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package mopag bar ];

    services.xserver.windowManager.monsterwm = {
      enable = true;
      extraSessionCommands = '' '';
      package = monsterwm;
    };

  };

}
