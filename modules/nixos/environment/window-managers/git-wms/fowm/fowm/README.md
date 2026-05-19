FOWM is a stacking and reparenting window manager for the X Window System.

It was made because most small or light weight window managers are tiling
window managers.  Either that or they are limited in how they can be
configured.

It only does focus follows mouse.  This is done because I was annoyed with
window managers that would not always focus the window under the mouse.

It does not do any colormap management.  But then it has been a long time since
I've used a 256 color display and needed colomap management.

It only has minimal support for the EWMH.  This is by design.

It has been written in a C like C++ and is intened to be linked without the
standard C++ library.

The directory "config" contains an example configuration.  This needs to be
copied to "$HOME/.fowm".
