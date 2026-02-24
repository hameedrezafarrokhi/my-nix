#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"
ANIMATION="$4"
FORMAT="$5"
RND="$6"

setup
for i in $(seq 1 $FRAMES); do
    new_h=$(( i * 1080 / FRAMES ))
    old_h=$(( 1080 - new_h ))
    if [ $new_h -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    elif [ $old_h -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    else
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
            [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
            [old]crop=1920:${old_h}:0:0[old_top];
            [new]crop=1920:${new_h}:0:0[new_top];
            [new_top]pad=1920:1080:0:0:color=black[new_padded];
            [old_top][new_padded]overlay=0:${old_h}:shortest=1[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    fi
done
wait
set_walls
