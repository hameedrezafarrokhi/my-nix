#!/usr/bin/env python3
from os import system
from Xlib.display import Display
from Xlib import X, XK

dpy = Display()
num = dpy.get_display_name()

# Mod+F1 Raises window under pointer
dpy.screen().root.grab_key(dpy.keysym_to_keycode(XK.string_to_keysym("F1")), 
		X.Mod1Mask, 1, X.GrabModeAsync, X.GrabModeAsync)

# Mod+F2 Starts new Xterm
dpy.screen().root.grab_key(dpy.keysym_to_keycode(XK.string_to_keysym("F2")), 
		X.Mod1Mask, 1, X.GrabModeAsync, X.GrabModeAsync)

# Mod+F3 Opens App launcher script (menu.sh)
dpy.screen().root.grab_key(dpy.keysym_to_keycode(XK.string_to_keysym("F3")), 
		X.Mod1Mask, 1, X.GrabModeAsync, X.GrabModeAsync)

# Mod+Mouse1+Drag Moves window
dpy.screen().root.grab_button(1, X.Mod1Mask, 1, 
		X.ButtonPressMask|X.ButtonReleaseMask|X.PointerMotionMask, 
		X.GrabModeAsync, X.GrabModeAsync, X.NONE, X.NONE)

# Mod+Mouse2+Drag resizes window
dpy.screen().root.grab_button(3, X.Mod1Mask, 1, 
		X.ButtonPressMask|X.ButtonReleaseMask|X.PointerMotionMask, 
		X.GrabModeAsync, X.GrabModeAsync, X.NONE, X.NONE)

start = None

while 1:
	ev = dpy.next_event()
	
	if ev.type == X.KeyPress and ev.child != X.NONE and ev.detail == 67:
		ev.child.configure(stack_mode = X.Above)
	
	elif ev.type == X.ButtonPress and ev.child != X.NONE:
		attr = ev.child.get_geometry()
		start = ev
	
	elif ev.type == X.MotionNotify and start:
		xdiff = ev.root_x - start.root_x
		ydiff = ev.root_y - start.root_y
		start.child.configure(
			x = attr.x + (start.detail == 1 and xdiff or 0),
			y = attr.y + (start.detail == 1 and ydiff or 0),
			width = max(1, attr.width + (start.detail == 3 and xdiff or 0)),
			height = max(1, attr.height + (start.detail == 3 and ydiff or 0)))
	
	elif ev.type == X.KeyPress and ev.detail == 68:
		system("xterm -display "+str(num)+" &")
	
	elif ev.type == X.KeyPress and ev.detail == 69:
		system("./menu.sh "+str(num)+" &")
	
	elif ev.type == X.ButtonRelease:
		start = None
