xrandr --output eDP-1 --mode 1366x768 --rate 60 &
systemctl --user import-environment DISPLAY &
feh --bg-fill ~/.config/catwm/wall.jpg &
picom -b &
xset s on &
xset s 180 &
xss-lock slock &
