#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

setup
for i in $(seq 1 $FRAMES); do
    new_w=$(echo "scale=2; $i * 1920 / $FRAMES" | bc | cut -d. -f1)
    old_w=$((1920 - new_w))
    if [ $new_w -eq 0 ]; then
        ffmpeg -y -i "$CUR_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.png" &
    elif [ $old_w -eq 0 ]; then
        ffmpeg -y -i "$NEW_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.png" &
    else
        ffmpeg -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
            [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
            [new]crop=${new_w}:1080:0:0[left];
            [old]crop=${old_w}:1080:${new_w}:0[right];
            [left][right]hstack=inputs=2[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.png" &
    fi
done
wait
set_walls
