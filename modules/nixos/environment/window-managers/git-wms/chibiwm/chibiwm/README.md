# Chibi WM: A small window manager in C 
Small X11 Window Manager

![Screenshot preview](screenshot.png)

## Files
`config.def.h` - default config, if no config.h provided, auto-generates config.h by just copying config.def.h

`config.h` - config so you can change some settings without changing source code

`main.c` - source code of chibi wm 

`Makefile` - literraly just Makefile 

This code has parts of code from:
 * https://github.com/lslvr/1wm 
 * https://git.suckless.org/dwm
 * https://github.com/mackstann/tinywm
 * https://jichu4n.com/posts/how-x-window-managers-work-and-how-to-write-one-part-i/

Thanks to everyone

## Compilation
You need only X11lib, X11ft, freetype and any c compiler

Build: `make`

Clean: `make clean`

Install: `make install`
