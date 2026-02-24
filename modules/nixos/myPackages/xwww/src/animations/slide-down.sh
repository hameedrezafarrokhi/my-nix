#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

setup
for i in $(seq 1 $FRAMES); do
    new_h=$(echo "scale=2; $i * 1080 / $FRAMES" | bc | cut -d. -f1)
    old_h=$((1080 - new_h))
    if [ $new_h -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.png" &
    elif [ $old_h -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.png" &
    else
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
            [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
            [new]crop=1920:${new_h}:0:0[top];
            [old]crop=1920:${old_h}:0:${new_h}[bottom];
            [top][bottom]vstack=inputs=2[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.png" &
    fi
done
wait
set_walls
