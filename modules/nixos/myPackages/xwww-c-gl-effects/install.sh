#!/bin/sh
# xwww installer. Read this before piping it into a shell on your system.
set -e

command -v pkg-config >/dev/null 2>&1 || { echo "pkg-config not found, please install it"; exit 1; }
command -v make >/dev/null 2>&1 || { echo "make not found, please install build tools"; exit 1; }

MISSING=""
pkg-config --exists x11    || MISSING="$MISSING libx11-dev"
pkg-config --exists imlib2 || MISSING="$MISSING libimlib2-dev"
if [ -n "$MISSING" ]; then
    echo "Missing dependencies:$MISSING"
    echo "On Debian/Ubuntu:  sudo apt install libx11-dev libimlib2-dev libxext-dev libxinerama-dev"
    echo "On Arch:           sudo pacman -S libx11 imlib2 libxext libxinerama"
    echo "On Fedora:         sudo dnf install libX11-devel imlib2-devel libXext-devel libXinerama-devel"
    exit 1
fi

make
sudo make install

mkdir -p "$HOME/.config/xwww"
if [ ! -f "$HOME/.config/xwww/xwwwrc" ]; then
    cp config/xwwwrc.example "$HOME/.config/xwww/xwwwrc"
    echo "Wrote default config to $HOME/.config/xwww/xwwwrc"
fi

echo "Installed. Try: xwww --list"
