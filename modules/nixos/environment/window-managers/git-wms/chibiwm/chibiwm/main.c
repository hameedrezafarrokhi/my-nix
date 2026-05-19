/* This code has parts of code from:
 * https://github.com/lslvr/1wm 
 * https://git.suckless.org/dwm
 * https://github.com/mackstann/tinywm		
 * https://jichu4n.com/posts/how-x-window-managers-work-and-how-to-write-one-part-i/
 * Thanks to everyone
*/

#include <X11/Xlib.h>
#include <X11/Xft/Xft.h>
#include <X11/Xatom.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#include "config.h"

#define max(a, b) 		((a) > (b) ? (a) : (b))
#define stk(s)			XKeysymToKeycode(d, XStringToKeysym(s))
#define on(ev, x)		if (e.type == ev) { x; } 
#define keys(k, mod, _)	XGrabKey(d, stk(k), MODMASK | mod, r, 1, 1, 1);
#define map(k, mod, x)	if (e.xkey.keycode == stk(k) && (e.xkey.state & ~Mod2Mask) == (MODMASK | mod)) { x; }

typedef enum {
	tiling = 0,
	floating = 1,
	fullscreen = 2
} Layout;

typedef struct {
    int x, y, w, h;
} WinGeom;

bool running = true;
Window ws[WORKSPACES][256];
int ws_count[WORKSPACES] = {0};
int current_ws = 0;
Display *d;
XWindowAttributes attr;
XButtonEvent start;
XEvent e;
Window r;
Window focused = None;
Window bar;
Pixmap bar_buf;
GC gc;
XftFont *font;
Layout ws_layout[WORKSPACES] = {0};
WinGeom ws_geom[WORKSPACES][256];
int unmapping = 0;
float tiling_master_size[WORKSPACES] = {0};

int xerror(Display *d, XErrorEvent *e);
void configurerequest(XEvent *e);
void buttonpress(XEvent *e);
void motionnotify(XEvent *e);
void propertynotify(XEvent *e);
void maprequest(XEvent *e);
void unmapnotify(XEvent *e);

void layout_floating(void);
void layout_fullscreen(void);
void layout_tiling(void);
void apply_layout(void);
void toggle_layout(Layout mode);

void tiling_change_master_size(float size);

void create_bar(void);
void draw_bar(void);
void setfocus(Window w);
void switch_ws(Display *d, int new_ws);
void move_to_ws(Display *d, Window win, int new_ws);

int main(void)
{
	d = XOpenDisplay(0); 
	r = DefaultRootWindow(d); 
	XSelectInput(d, r, SubstructureRedirectMask | SubstructureNotifyMask | EnterWindowMask | PropertyChangeMask);
	TBL(keys);
	XGrabButton(d, 1, MODMASK, r, 0, ButtonPressMask | ButtonReleaseMask | PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None);
	XGrabButton(d, 3, MODMASK, r, 0, ButtonPressMask | ButtonReleaseMask | PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None);
	XGrabButton(d, 1, 0, r, 0, ButtonPressMask, GrabModeSync, GrabModeSync, None, None);
	XSetErrorHandler(xerror); 
	create_bar();
	draw_bar();

	while (running && !XNextEvent (d, &e)) {
		on(ConfigureRequest,	configurerequest(&e))
		on(ButtonPress,			buttonpress(&e))
		on(EnterNotify,			setfocus(e.xcrossing.window))
		on(MotionNotify,		motionnotify(&e))
		on(PropertyNotify,		propertynotify(&e))
        on(MapRequest,			maprequest(&e))
		on(UnmapNotify,			unmapnotify(&e))
		on(ButtonRelease,		start.subwindow = None)
		on(KeyPress,			TBL(map))
    }
	return 0;
}

void configurerequest(XEvent *e) {
	apply_layout();
}

void buttonpress(XEvent *e) {
	XButtonPressedEvent *ev = &e->xbutton;
	if (ev->subwindow != None && ws_layout[current_ws] == floating) {
		setfocus(ev->subwindow);
		XRaiseWindow(d, ev->subwindow);
		if (ev->subwindow != None && ev->state & MODMASK) { 
			XSetInputFocus(d, ev->subwindow, RevertToParent, CurrentTime);
			XGetWindowAttributes(d, ev->subwindow, &attr);
			if (!attr.override_redirect) 
				start = *ev;
		}
	}
	XAllowEvents(d, ReplayPointer, CurrentTime);
}

void motionnotify(XEvent *e) {
	XButtonPressedEvent *ev = &e->xbutton;
	if (start.subwindow != None && ws_layout[current_ws] == floating) {
		int xdiff = ev->x_root - start.x_root;
		int ydiff = ev->y_root - start.y_root;
		XMoveResizeWindow(d, start.subwindow,
			attr.x + (start.button==1 ? xdiff : 0),
			attr.y + (start.button==1 ? ydiff : 0),
			max(1, attr.width + (start.button==3 ? xdiff : 0)),
			max(1, attr.height + (start.button==3 ? ydiff : 0)));
	}
}

void propertynotify(XEvent *e) {
	XPropertyEvent *ev = &e->xproperty;
	if ((ev->window == r) && (ev->atom == XA_WM_NAME))
		draw_bar();
}

void maprequest(XEvent *e) {
	XMapRequestEvent *ev = &e->xmaprequest;
	XGetWindowAttributes(d, ev->window, &attr);
	if (!attr.override_redirect) {
		bool found = false;
		for (int w = 0; w < WORKSPACES; w++)
			for (int i = 0; i < ws_count[w]; i++)
				if (ws[w][i] == ev->window) found = true;
		if (!found) {
			ws[current_ws][ws_count[current_ws]] = ev->window;
			ws_geom[current_ws][ws_count[current_ws]] = (WinGeom){attr.x, BAR_SIZE, attr.width, attr.height};
			ws_count[current_ws]++;
		}
		XSelectInput(d, ev->window, EnterWindowMask);
		XSetWindowBorderWidth(d, ev->window, BORDER_SIZE);
		XSetWindowBorder(d, ev->window, BORDER_INACTIVE_COLOR);
	}
	XMapWindow(d, ev->window);
	apply_layout();
	setfocus(ev->window);
}

void unmapnotify(XEvent *e) {
	if (unmapping > 0) {
		unmapping--;
		return;
	}
	XUnmapEvent *ev = &e->xunmap;
	for (int w = 0; w < WORKSPACES; w++) {
		for (int i = 0; i < ws_count[w]; i++) {
			if (ws[w][i] == ev->window) {
				ws_count[w]--;
				ws[w][i] = ws[w][ws_count[w]];
				ws_geom[w][i] = ws_geom[w][ws_count[w]];
				break;
			}
		}
	}
	apply_layout();
}

void layout_floating(void) {
	for (int i = 0; i < ws_count[current_ws]; i++) { 
		Window w = ws[current_ws][i];
		XMoveResizeWindow(d, w, ws_geom[current_ws][i].x, ws_geom[current_ws][i].y, ws_geom[current_ws][i].w, ws_geom[current_ws][i].h);
		XSetWindowBorderWidth(d, ws[current_ws][i], BORDER_SIZE);
		ws_geom[current_ws][i].w = 0;
	}

}

void layout_fullscreen(void) {
	for (int i = 0; i < ws_count[current_ws]; i++) { 
		Window w = ws[current_ws][i];
		if (ws_geom[current_ws][i].w == 0) {
			XGetWindowAttributes(d, w, &attr);
			ws_geom[current_ws][i] = (WinGeom){attr.x, attr.y, attr.width, attr.height};
		}
		XMoveResizeWindow(d, w, 0, 0, DisplayWidth(d, 0), DisplayHeight(d, 0));
		XSetWindowBorderWidth(d, w, 0);
	}
}

void layout_tiling(void) {		// master/stack
	int n = ws_count[current_ws];
	if (n == 0) return;

	int sw = DisplayWidth(d, 0);
	int sh = DisplayHeight(d, 0) - BAR_SIZE;

	if (n == 1) {
		XMoveResizeWindow(d, ws[current_ws][0], 0, BAR_SIZE, sw - BORDER_SIZE * 2, sh - BORDER_SIZE * 2);
		XSetWindowBorderWidth(d, ws[current_ws][0], BORDER_SIZE);
		return;
	}

	if (tiling_master_size[current_ws] == 0) tiling_master_size[current_ws] = 0.5;
	int master_w = sw * tiling_master_size[current_ws]; 
	XMoveResizeWindow(d, ws[current_ws][0], 0, BAR_SIZE, master_w - BORDER_SIZE * 2, sh - BORDER_SIZE * 2);
	XSetWindowBorderWidth(d, ws[current_ws][0], BORDER_SIZE);

	int stack_n = n - 1;
	int stack_h = sh / stack_n;
	for (int i = 0; i < stack_n; i++) {
		XMoveResizeWindow(d, ws[current_ws][i + 1], master_w, BAR_SIZE + i * stack_h, sw - master_w - BORDER_SIZE * 2, stack_h - BORDER_SIZE * 2);
		XSetWindowBorderWidth(d, ws[current_ws][i + 1], BORDER_SIZE);
	}
}

void apply_layout(void) {
	switch(ws_layout[current_ws]) {
		case tiling:
			layout_tiling();
			break;
		case floating:
			layout_floating();
			break;
		case fullscreen:
			layout_fullscreen();
			break;
		default:
			layout_tiling();
			break;
	}
	draw_bar();
}

void toggle_layout(Layout mode) {
	if (mode == ws_layout[current_ws]) return;
	ws_layout[current_ws] = mode;
	apply_layout();
}

int xerror(Display *d, XErrorEvent *e) {
	return 0; 
}

void create_bar(void) {
	bar = XCreateSimpleWindow(d, r, 0, 0, DisplayWidth(d, 0), BAR_SIZE, 0, 0, BAR_BACKGROUND_COLOR);

	XSetWindowAttributes wa;
	wa.override_redirect = True;

	XChangeWindowAttributes(d, bar, CWOverrideRedirect, &wa);
	XSelectInput(d, bar, ExposureMask);
	XMapWindow(d, bar);
	XSetWindowBorderWidth(d, bar, 0);

	bar_buf = XCreatePixmap(d, r, DisplayWidth(d, 0), BAR_SIZE, DefaultDepth(d, 0));
	gc = XCreateGC(d, bar, 0, NULL);
	font = XftFontOpenName(d, DefaultScreen(d), BAR_FONT);
}

void draw_bar(void) {
	XSetForeground(d, gc, BAR_BACKGROUND_COLOR);
	XFillRectangle(d, bar_buf, gc, 0, 0, DisplayWidth(d, 0), BAR_SIZE);

	XftDraw *xdraw = XftDrawCreate(d, bar_buf, DefaultVisual(d, 0), DefaultColormap(d, 0));

	XftColor col;
	for (int i = 0; i < WORKSPACES; i++) {
		XftColorAllocName(d, DefaultVisual(d, 0), DefaultColormap(d, 0),
			i == current_ws ? BAR_ACTIVE_WS_COLOR : BAR_INACTIVE_WS_COLOR, &col);
		char label[2];
		snprintf(label, sizeof(label), "%d", i + 1);
		XftDrawStringUtf8(xdraw, &col, font, 8 + i * (BAR_FONT_SIZE * 2), (BAR_SIZE / 2) + (BAR_FONT_SIZE / 2), (FcChar8*)label, 1);
		XftColorFree(d, DefaultVisual(d, 0), DefaultColormap(d, 0), &col);
	}
	const char *mode_label;
	switch (ws_layout[current_ws]) {
		case fullscreen:	mode_label = "[F]"; break;
		case floating:		mode_label = "[~]"; break;
		case tiling:		mode_label = "[T]"; break;
		default:			mode_label = "[?]"; break;
	}
	int ws_end = 8 + WORKSPACES * (BAR_FONT_SIZE * 2);
	XftColorAllocName(d, DefaultVisual(d, 0), DefaultColormap(d, 0), BAR_LAYOUT_COLOR, &col);
	XftDrawStringUtf8(xdraw, &col, font, ws_end, (BAR_SIZE / 2) + (BAR_FONT_SIZE / 2), (FcChar8*)mode_label, strlen(mode_label));
	XftColorFree(d, DefaultVisual(d, 0), DefaultColormap(d, 0), &col);

	char status[64] = {0};
	XTextProperty name;
	if (XGetWMName(d, r, &name) && name.value)
		snprintf(status, sizeof(status), "%s", name.value);
	if (!status[0])
		strcpy(status, "chibiWM");

	XGlyphInfo ext;
	XftTextExtentsUtf8(d, font, (FcChar8*)status, strlen(status), &ext);
	int x = DisplayWidth(d, 0) - ext.width - 8;
	XftColorAllocName(d, DefaultVisual(d, 0), DefaultColormap(d, 0), BAR_STATUS_COLOR, &col);
	XftDrawStringUtf8(xdraw, &col, font, x, (BAR_SIZE / 2) + (BAR_FONT_SIZE / 2), (FcChar8*)status, strlen(status));
	XftColorFree(d, DefaultVisual(d, 0), DefaultColormap(d, 0), &col);

	XftDrawDestroy(xdraw);
	XCopyArea(d, bar_buf, bar, gc, 0, 0, DisplayWidth(d, 0), BAR_SIZE, 0, 0);
	XFlush(d);
}

void setfocus(Window w) {
	if (w == None || w == r) return;
	if (focused != None && focused != w)
		XSetWindowBorder(d, focused, BORDER_INACTIVE_COLOR);
	focused = w;
	XSetInputFocus(d, focused, RevertToParent, CurrentTime);
	XSetWindowBorder(d, focused, BORDER_ACTIVE_COLOR);
}

void switch_ws(Display *d, int new_ws) {
	if (new_ws == current_ws) return;
	unmapping = ws_count[current_ws];
	for (int i = 0; i < ws_count[current_ws]; i++)
		XUnmapWindow(d, ws[current_ws][i]);
	focused = None;
	current_ws = new_ws;
	for (int i = 0; i < ws_count[current_ws]; i++)
		XMapWindow(d, ws[current_ws][i]);
	draw_bar();
	apply_layout();
}

void move_to_ws(Display *d, Window win, int new_ws) {
	if (new_ws == current_ws || win == None) return;
	for (int i = 0; i < ws_count[current_ws]; i++) {
		if (ws[current_ws][i] == win) {
			ws_geom[new_ws][ws_count[new_ws]] = ws_geom[current_ws][i];
			ws[current_ws][i] = ws[current_ws][--ws_count[current_ws]];
			ws_geom[current_ws][i] = ws_geom[current_ws][ws_count[current_ws]];
			break;
		}
	}
	ws[new_ws][ws_count[new_ws]++] = win;
	unmapping++;
	XUnmapWindow(d, win);
	apply_layout();
}

void tiling_change_master_size(float size) {
	if (tiling_master_size[current_ws] == 0) {
		tiling_master_size[current_ws] = 0.5;
	}
	if ((tiling_master_size[current_ws]+size) < 1.0 && (tiling_master_size[current_ws]+size) > 0.1) {
		tiling_master_size[current_ws]+=size;
		apply_layout();
	}
}
