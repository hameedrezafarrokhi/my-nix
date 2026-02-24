#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

PI=$(echo "scale=10; 4*a(1)" | bc -l)

setup
for i in $(seq 1 $FRAMES); do
    progress=$(echo "scale=4; ($i-1) / ($FRAMES-1)" | bc)
    angle_old=$(echo "$progress * 2 * $PI" | bc -l)
    angle_new=$(echo "$progress * 2 * $PI" | bc -l)
    scale_old=$(echo "if ($progress > 0.999) 0.01 else 1 - $progress" | bc -l)
    scale_new=$(echo "if ($progress < 0.001) 0.01 else $progress" | bc -l)
    angle_old_f=$(printf "%.6f" "$angle_old")
    angle_new_f=$(printf "%.6f" "$angle_new")
    scale_old_f=$(printf "%.6f" "$scale_old")
    scale_new_f=$(printf "%.6f" "$scale_new")
    ffmpeg -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        color=c=black:s=1920x1080[bg];
        [0:v]scale=iw*${scale_old_f}:ih*${scale_old_f},
              rotate=${angle_old_f}:fillcolor=black[oldv];
        [1:v]scale=iw*${scale_new_f}:ih*${scale_new_f},
              rotate=${angle_new_f}:fillcolor=black[newv];
        [bg][oldv]overlay=x=(main_w-overlay_w)/2:y=(main_h-overlay_h)/2[tmp];
        [tmp][newv]overlay=x=(main_w-overlay_w)/2:y=(main_h-overlay_h)/2[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png"

    if [ $? -ne 0 ] || [ ! -s "$CACHE/new$i.png" ]; then
        echo "Error generating frame $i. Aborting."
        exit 1
    fi
done
wait
set_walls
