#!/bin/sh
DIR="$HOME/Pictures/themed-wallpapers"
CACHE="$HOME/.cache/last_wallpaper"
mkdir -p "$(dirname "$CACHE")"

FILES=("$DIR"/*.{jpg,jpeg,png,webp,gif})
COUNT=${#FILES[@]}
[ $COUNT -eq 0 ] && echo "No wallpapers!" && exit 1

CUR=$(cat "$CACHE" 2>/dev/null)
INDEX=0
for i in "${!FILES[@]}"; do [ "${FILES[i]}" = "$CUR" ] && INDEX=$i; done

case "$1" in
  next) INDEX=$(( (INDEX + 1) % COUNT )) ;;
  prev) INDEX=$(( (INDEX - 1 + COUNT) % COUNT )) ;;
esac

feh --bg-fill "${FILES[INDEX]}"
echo "${FILES[INDEX]}" > "$CACHE"
