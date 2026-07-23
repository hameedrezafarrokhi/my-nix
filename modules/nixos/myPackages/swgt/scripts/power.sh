#!/bin/bash

FONT="BigBlueTermPlus Nerd Font Mono:weight=Regular:size=11:antialias=true:hinting=true"
DMENU_OPTS=(-l 6 -g 1 -h 32 -fn "$FONT" -shb "#9c98d5" -shf "#585b70" -nhb "#14141d" -nhf "#585b70")

choices="  Shutdown\n  Reboot\n  Suspend\n  Lock\n  Logout"
choice=$(echo -e "$choices" | dmenu "${DMENU_OPTS[@]}" -i -p "pmenu:")

case "$choice" in
    *Shutdown*) systemctl poweroff ;;
    *Reboot*) systemctl reboot ;;
    *Suspend*) systemctl suspend ;;
    *Lock*) slock ;;
    *Logout*) pkill -KILL -u "$USER" ;;
esac
