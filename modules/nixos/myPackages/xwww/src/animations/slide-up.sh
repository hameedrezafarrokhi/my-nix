#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

setup
for i in $(seq 1 $FRAMES); do
    crop_pos=$(echo "1080 - $i * (1080 / $FRAMES)" | bc | cut -d. -f1)
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
        [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
        [old]crop=1920:${crop_pos}:0:$((1080 - crop_pos))[top];
        [new]crop=1920:$((1080 - crop_pos)):0:0[bottom];
        [top][bottom]vstack=inputs=2[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png" &
done
wait
set_walls


