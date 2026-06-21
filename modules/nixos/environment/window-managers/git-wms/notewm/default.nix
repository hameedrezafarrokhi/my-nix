{ config, pkgs, lib, ... }:

with lib;

let

  cfg = config.services.xserver.windowManager.notewm;
  notewm = pkgs.callPackage ./notewm.nix {
    conf = ''
/*
 * file: notewm.h
 * --------------
 * NoteWM is a simple floating reparenting window manager
 * This header file contains all function prototypes and
 * data structures used in this project.
 *
 * Author: Mason Armand
 * Date Created: Jun 1, 2023
 * Last Modified: Jun 8, 2023
 */
#ifndef NOTEWM_H
#define NOTEWM_H

#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/Xutil.h>
#include <X11/cursorfont.h>
#include <X11/keysymdef.h>
#include <X11/keysym.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <string.h>
#include "ini.h"
/* ---------- Macros ---------- */
#define NUM_WORKSPACES 9

/* sizing */
#define BORDER_WIDTH 2
#define TITLE_HEIGHT 16
#define BUTTON_SIZE 8
#define PADDING 4
#define TITLE_STRING_X 10
#define TITLE_STRING_Y (TITLE_HEIGHT / 2) + 2

/* cursed atom macros, should probably change this later */
#define _NET_WM_WINDOW_TYPE (XInternAtom(display, "_NET_WM_WINDOW_TYPE", false))
#define _NET_WM_WINDOW_TYPE_NORMAL (XInternAtom(display, "_NET_WM_WINDOW_TYPE_NORMAL", false))
#define _NET_WM_WINDOW_TYPE_DOCK (XInternAtom(display, "_NET_WM_WINDOW_TYPE_DOCK", false))
#define _NET_WM_WINDOW_TYPE_TOOLBAR (XInternAtom(display, "_NET_WM_WINDOW_TYPE_TOOLBAR", false))
#define _NET_WM_WINDOW_TYPE_UTILITY (XInternAtom(display, "_NET_WM_WINDOW_TYPE_UTILITY", false))
#define _NET_WM_WINDOW_TYPE_MENU (XInternAtom(display, "_NET_WM_WINDOW_TYPE_MENU", false))
#define _NET_WM_WINDOW_TYPE_DIALOG (XInternAtom(display, "_NET_WM_WINDOW_TYPE_DIALOG", false))
#define _NET_WM_WINDOW_TYPE_DROPDOWN_MENU (XInternAtom(display, "_NET_WM_WINDOW_TYPE_DROPDOWN_MENU", false))
#define _NET_WM_WINDOW_TYPE_POPUP_MENU (XInternAtom(display, "_NET_WM_WINDOW_TYPE_POPUP_MENU", false))
#define _NET_WM_WINDOW_TYPE_TOOLTIP (XInternAtom(display, "_NET_WM_WINDOW_TYPE_TOOLTIP", false))
#define _NET_WM_WINDOW_TYPE_NOTIFICATION (XInternAtom(display, "_NET_WM_WINDOW_TYPE_NOTIFICATION", false))
#define _NET_WM_WINDOW_TYPE_COMBO (XInternAtom(display, "_NET_WM_WINDOW_TYPE_COMBO", false))
#define _NET_WM_WINDOW_TYPE_DND (XInternAtom(display, "_NET_WM_WINDOW_TYPE_DND", false))
#define _NET_WM_WINDOW_TYPE_DESKTOP (XInternAtom(display, "_NET_WM_WINDOW_TYPE_DESKTOP", false))
/* state atoms */
#define _NET_WM_STATE (XInternAtom(display, "_NET_WM_STATE", false))
#define _NET_WM_STATE_MODAL (XInternAtom(display, "_NET_WM_STATE_MODAL", false))
#define _NET_WM_STATE_HIDDEN (XInternAtom(display, "_NET_WM_STATE_MODAL", false))
#define _NET_WM_STATE_ABOVE (XInternAtom(display, "_NET_WM_STATE_MODAL", false))
#define _NET_WM_STATE_FULLSCREEN (XInternAtom(display, "_NET_WM_STATE_FULLSCREEN", false))
/* other atoms */
#define WM_PROTOCOLS (XInternAtom(display, "WM_PROTOCOLS", false))
#define WM_DELETE_WINDOW (XInternAtom(display, "WM_DELETE_WINDOW", false))
#define _NET_CLOSE_WINDOW (XInternAtom(display, "_NET_CLOSE_WINDOW", false))


/* ---------- NoteWM Data Structures ---------- */

typedef struct NoteWM_Frame NoteWM_Frame;

typedef void (*ButtonClickFunc)(Display* display, Window root, NoteWM_Frame* frame, NoteWM_Frame** list);

typedef struct {
        unsigned long title_bar_color;
        unsigned long border_color;
        unsigned long fg_color;
        unsigned long bg_color;
        unsigned long close_color;
        unsigned long expand_color;
        unsigned long split_color;
        unsigned long button_border_color;
} NoteWM_Config;

typedef struct {
        unsigned int current_workspace;
        unsigned int num_client_windows;
        Window* client_windows;
        NoteWM_Config conf;
} NoteWM_GlobalState;

typedef struct {
        Window window;
        ButtonClickFunc on_click;
} NoteWM_Button;

typedef struct {
        NoteWM_Button* buttons;
        unsigned int count;
        unsigned int capacity;
} NoteWM_ButtonList;

struct NoteWM_Frame {
        Window frame;
        Window title_bar;
        Window title_string_window;
        NoteWM_ButtonList* button_list;
        Window child_window;
        GC gc;
        unsigned short workspace_id;
        int x, y, w, h;
        bool is_fullscreen;
        bool ignore_configure_events;

        struct NoteWM_Frame* next;
};

typedef struct {
        XWindowAttributes attrs;
        XButtonEvent event;
} NoteWM_WindowResizeInfo;

typedef struct {
    KeySym key_sym;
    unsigned int modifiers;
} NoteWM_KeyBinding;

typedef struct {
    unsigned int button;
    unsigned int modifiers;
} NoteWM_MouseBinding;

/* ---------- globals ----------*/
extern NoteWM_GlobalState global_state;
extern XFontStruct* global_font;
extern unsigned int global_total_bar_height;
extern Cursor global_cursor_default;
extern Cursor global_cursor_grab;
extern Cursor global_cursor_resize;
extern Cursor global_cursor_plus;


/* ---------- Function Prototypes --------- */

/* frame.c functions */
void add_frame(NoteWM_Frame* frame, NoteWM_Frame** list);
void remove_frame(Display* display, NoteWM_Frame* frame, NoteWM_Frame** list);
void free_frame(Display* display, NoteWM_Frame* frame);
NoteWM_Frame* find_frame_by_component(Window component, NoteWM_Frame* list);
bool is_button(Window window, NoteWM_Frame* frame);
NoteWM_Frame* create_frame(Display* display, Window window, Window root);
void create_title_bar(Display* display, NoteWM_Frame* frame);
void resize_frame(Display* display, NoteWM_Frame* frame, int width, int height, bool is_event);
void move_resize_frame(Display* display, NoteWM_Frame* frame, int x, int y, int width, int height);
void update_frame_text(Display* display, NoteWM_Frame* frame);
void set_frame_fullscreen(Display* display, NoteWM_Frame* frame, bool fullscreen);
void create_button(Display* display, NoteWM_Frame* frame, unsigned long color, unsigned long mask, ButtonClickFunc event_function);
NoteWM_ButtonList* init_button_list(unsigned int initial_capacity);
void append_button(NoteWM_ButtonList* button_list, NoteWM_Button button);
void free_button_list(NoteWM_ButtonList* button_list);

/* events.c functions */
void handle_close_button(Display* display, Window root, NoteWM_Frame* frame, NoteWM_Frame** list);
void handle_expand_button(Display* display, Window root, NoteWM_Frame* frame, NoteWM_Frame** list);
void handle_split_left_button(Display* display, Window root, NoteWM_Frame* frame, NoteWM_Frame** list);
void handle_split_right_button(Display* display, Window root, NoteWM_Frame* frame, NoteWM_Frame** list);

void handle_key_press(Display* display, Window root, XKeyEvent* e, NoteWM_Frame* list);
void handle_button_press(Display* display, Window root, XButtonEvent* e, NoteWM_Frame** list);
void handle_motion_notify(Display* display, XButtonEvent* e, NoteWM_WindowResizeInfo r_info, NoteWM_Frame* list);
void handle_unmap_notify(Display* display, Window root, XUnmapEvent* e, NoteWM_Frame** list);
void handle_destroy_notify(Display* display, Window root, XDestroyWindowEvent* e, NoteWM_Frame** list);
void handle_map_request(Display* display, Window root, XMapRequestEvent* e, NoteWM_Frame** list);
void handle_configure_request(Display* display, XConfigureRequestEvent* e, NoteWM_Frame* list);
void handle_resize_request(Display* display, XResizeRequestEvent* e, NoteWM_Frame* list);
void handle_property_notify(Display* display, XPropertyEvent* e, NoteWM_Frame* list);
void handle_client_message(Display* display, Window root, XClientMessageEvent* e, NoteWM_Frame** list);
void handle_reparent_notify(Display* display, Window root, XReparentEvent* e, NoteWM_Frame** list);
void handle_enter_notify(Display* display, Window root, XCrossingEvent* e, NoteWM_Frame* list);
void send_configure_notify(Display* display, NoteWM_Frame* frame);

/* window_manager.c functions */
void update_net_client_list(Display* display, Window root);
void add_client_window(Display* display, Window root, Window window);
void remove_client_window(Display* display, Window root, Window window);
void free_client_window_list(void);
void set_ewhm_desktop_properties(Display* display, Window root);
void set_net_wm_desktop(Display* display, Window window, int workspace_id);
void set_net_supported(Display* display, Window root);
void switch_to_workspace(Display* display, Window root, unsigned short new_workspace, NoteWM_Frame* list);
void focus_window(Display* display, Window window, NoteWM_Frame* list);
void map_window(Display* display, Window root, Window window, NoteWM_Frame** list);
void get_display_dimensions(Display* display, int* width, int* height);
void update_window_type(Display* display, Window window);
Atom get_atom(Display* display, Window window, const char* atom_name);
void grab_change_cursor(Display* display, Window window, Cursor cursor);
void adopt_existing_windows(Display* display, Window root, NoteWM_Frame** list);
void launch_program(const char* program);
void grab_keys(Display* display, Window root, NoteWM_KeyBinding* keybindings);
void grab_buttons(Display* display, Window root, NoteWM_MouseBinding* mousebindings);
int get_window_name(Display* display, Window window, char* text, unsigned int size);
void close_frame(Display* display, Window root, NoteWM_Frame* frame, NoteWM_Frame** list);
void map_noframe_window(Display* display, Window window);
int xerror_handler(Display *display, XErrorEvent *error);
bool is_valid_window(Display* display, Window window);

/* config.c functions */
int conf_handler(void* user, const char* section, const char* name, const char* value);
#endif
    '';

    conf2 = ''
/*
 * file: main.c
 * ------------
 * This is the entry point for the NoteWM window manager. For more information on NoteWM, see README.md
 *
 * Author: Mason Armand
 * Date Created: May 31, 2023
 * Last Modified: Jun 8, 2023
 */
#include "notewm.h"

NoteWM_GlobalState global_state = { 0 };
Cursor global_cursor_default;
Cursor global_cursor_resize;
Cursor global_cursor_grab;
Cursor global_cursor_plus;
XFontStruct* global_font;

int main(void)
{
        Display* display;
        Window root;
        XEvent e;
        bool running = true;

        /* GrabKeys */
        NoteWM_KeyBinding keybindings[] = {
                { XK_d, Mod4Mask },
                { XK_Return, Mod4Mask },
                { XK_q, Mod4Mask },
                { XK_E, Mod4Mask | ShiftMask},
                /* for switching workspaces */
                { XK_1, Mod4Mask },
                { XK_2, Mod4Mask },
                { XK_3, Mod4Mask },
                { XK_4, Mod4Mask },
                { XK_5, Mod4Mask },
                { XK_6, Mod4Mask },
                { XK_7, Mod4Mask },
                { XK_8, Mod4Mask },
                { XK_9, Mod4Mask },
                { NoSymbol, 0 } /* end of list */
        };
        /* GrabButtons */
        NoteWM_MouseBinding mousebindings[] = {
                { Button1, Mod4Mask },
                { Button2, Mod4Mask },
                { Button3, Mod4Mask },
                { 0, 0 } /* end of list */
        };

        NoteWM_Frame* client_list = NULL;
        NoteWM_WindowResizeInfo r_info = { 0 };

        /* default colors */
        global_state.conf.title_bar_color = 0xeaffff;
        global_state.conf.button_border_color = 0x000000;
        global_state.conf.border_color = 0x55aaaa;
        global_state.conf.fg_color = 0x000000;
        global_state.conf.bg_color = 0xffffea;
        global_state.conf.close_color = 0xffaaaa;
        global_state.conf.expand_color = 0xeeee9e;
        global_state.conf.split_color = 0x88cc88;

        if (ini_parse("/home/mace/.config/notewm/config.ini", conf_handler, &global_state.conf) < 0) {
                fprintf(stderr, "Failed to load config.ini, using default settings.\n");
        }

        XSetErrorHandler(xerror_handler);

        if (!(display = XOpenDisplay(NULL)))
                fprintf(stderr, "Failed to open display.\n");

        root = DefaultRootWindow(display);

        XSelectInput(
                display, root,
                SubstructureRedirectMask |
                SubstructureNotifyMask |
                PropertyChangeMask |
                ButtonPressMask |
                ButtonReleaseMask |
                PointerMotionMask
        );

        /*XSynchronize(display, true);*/
        global_state.current_workspace = 0;

        /*global_font = XLoadQueryFont(display, "-misc-fixed-bold-r-normal--13-120-75-75-C-70-iso10646-1");*/
        global_font = XLoadQueryFont(display, "fixed");
        if (!global_font) {
                fprintf(stderr, "Failed to load font\n");
                return 1;
        }

        /* define cursors */
        global_cursor_default = XCreateFontCursor(display, XC_left_ptr);
        global_cursor_grab = XCreateFontCursor(display, XC_fleur);
        global_cursor_resize = XCreateFontCursor(display, XC_sizing);
        global_cursor_plus = XCreateFontCursor(display, XC_plus);
        XDefineCursor(display, root, global_cursor_default);

        grab_keys(display, root, keybindings);
        grab_buttons(display, root, mousebindings);

        adopt_existing_windows(display, root, &client_list);
        set_net_supported(display, root);
        set_ewhm_desktop_properties(display, root);
        XFlush(display);
        XMapRaised(display, root);

        while (running) {
                NoteWM_Frame* frame;
                XKeyEvent k;

                XNextEvent(display, &e);

                switch (e.type) {
                case MapRequest:
                        handle_map_request(display, root, &e.xmaprequest, &client_list);
                        break;
                case UnmapNotify:
                        handle_unmap_notify(display, root, &e.xunmap, &client_list);
                        break;
                case DestroyNotify:
                        handle_destroy_notify(display, root, &e.xdestroywindow, &client_list);
                        XSetInputFocus(display, root, RevertToPointerRoot, CurrentTime);
                        XSync(display, false);
                        break;
                case ConfigureRequest:
                        handle_configure_request(display, &e.xconfigurerequest, client_list);
                        break;
                case PropertyNotify:
                        handle_property_notify(display, &e.xproperty, client_list);
                        break;
                case ClientMessage:
                        handle_client_message(display, root, &e.xclient, &client_list);
                        break;
                case ReparentNotify:
                        handle_reparent_notify(display, root, &e.xreparent, &client_list);
                        break;
                case ResizeRequest:
                        handle_resize_request(display, &e.xresizerequest, client_list);
                        break;
                case ButtonPress:
                        handle_button_press(display, root, &e.xbutton, &client_list);
                        r_info.event = e.xbutton;
                        if (e.xbutton.subwindow != None)
                                XGetWindowAttributes(display, e.xbutton.subwindow, &r_info.attrs);
                        break;
                case ButtonRelease:
                        XUngrabPointer(display, CurrentTime);
                        r_info.event.subwindow = None;
                        break;
                case MotionNotify:
                        handle_motion_notify(display, &e.xbutton, r_info, client_list);
                        break;
                case EnterNotify:
                        handle_enter_notify(display, root, &e.xcrossing, client_list);
                        break;
                case KeyPress:
                        k = e.xkey;
                        handle_key_press(display, root, &e.xkey, client_list);

                        if ((k.state & Mod4Mask) && (k.state & ShiftMask) && k.keycode == XKeysymToKeycode(display, XK_E))
                                running = false;

                        if ((k.state & Mod4Mask) && k.keycode == XKeysymToKeycode(display, XK_d)) {
                                system("dmenu_run -fn 'Droid Sans Mono-12' -nb black -sb '#ffffff' -l 5");
                        }
                        if ((k.state & Mod4Mask) && k.keycode == XKeysymToKeycode(display, XK_Return)) {
                                launch_program("xfce4-terminal");
                        }
                        break;
                case Expose:
                        if (e.xexpose.count == 0) {
                                frame = find_frame_by_component(e.xexpose.window, client_list);
                                if (frame) {
                                        update_frame_text(display, frame);
                                }
                        }
                        break;
                }
        }
        free_client_window_list();
        XFreeFont(display, global_font);
        XFreeCursor(display, global_cursor_default);
        XFreeCursor(display, global_cursor_resize);
        XFreeCursor(display, global_cursor_grab);
        XFreeCursor(display, global_cursor_plus);
        XCloseDisplay(display);

        return 0;
}
    '';


  };

in

{

  options = {
    services.xserver.windowManager.notewm = {
      enable = mkEnableOption "notewm";
      extraSessionCommands = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Shell commands executed just before notewm is started.
        '';
      };
      package = mkPackageOption pkgs "notewm" {
        example = '' '';
      };
    };
  };

  config = lib.mkIf (builtins.elem "notewm" config.my.window-managers) {

    services.xserver.windowManager.session = singleton {
      name = "notewm";
      start = ''
        export _JAVA_AWT_WM_NONREPARENTING=1
        xsetroot -cursor_name left_ptr &
        ${cfg.extraSessionCommands}
        ${notewm}/bin/notewm &
        waitPID=$!
      '';
    };

    environment.systemPackages = [ cfg.package ];

    services.xserver.windowManager.notewm = {
      enable = true;
      extraSessionCommands = '' '';
      package = notewm;
    };

  };

}
