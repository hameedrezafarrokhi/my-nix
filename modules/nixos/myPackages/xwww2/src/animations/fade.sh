#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

setup
IMAGES=$(( (FRAMES - 2) / 2 - 1 ))
for i in $(seq 1 $IMAGES); do
    if [[ $i -lt $IMAGES ]]; then
        alpha=$(echo "scale=2; 0.05 + ($i - 1) * (0.75 / ($IMAGES - 1))" | bc)
        scale="iw/5"
    else
        alpha=0.90
        scale="iw/2"
    fi
    ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -vf "scale=$scale:-1,format=rgba,colorchannelmixer=aa=$alpha" "$CACHE/fade/new$i.png"
done
wait 2>/dev/null
set_fade

