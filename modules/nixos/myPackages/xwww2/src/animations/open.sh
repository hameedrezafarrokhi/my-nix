#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

setup
for i in $(seq 1 $FRAMES); do
    offset=$(echo "($i-1) * 960 / ($FRAMES-1)" | bc)
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
        [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p[new];
        [old]crop=960:1080:0:0[left];
        [old]crop=960:1080:960:0[right];
        [new]null[bg];
        [bg][left]overlay=x=-${offset}:y=0[bg_left];
        [bg_left][right]overlay=x=960+${offset}:y=0[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png"
    if [ $? -ne 0 ] || [ ! -s "$CACHE/new$i.png" ]; then
        echo "Error generating frame $i. Aborting."
        exit 1
    fi
done
wait
set_walls
