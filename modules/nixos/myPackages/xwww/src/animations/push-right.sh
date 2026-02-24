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
ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/old_scaled.$FORMAT" &
ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new_scaled.$FORMAT" &
wait
for i in $(seq 1 $FRAMES); do
    if [ $FRAMES -eq 1 ]; then
        offset_new=0
        offset_old=0
    else
        offset_new=$(echo "scale=0; -1920 * ($i - 1) / ($FRAMES - 1)" | bc)
        offset_old=$(echo "scale=0; 1920 * ($i - 1) / ($FRAMES - 1)" | bc)
    fi
    new_x=$(echo "scale=0; -1920 + 1920 * ($i - 1) / ($FRAMES - 1)" | bc)
    old_x=$(echo "scale=0; 1920 * ($i - 1) / ($FRAMES - 1)" | bc)
    ffmpeg "${ACCEL[@]}" -y -i "$CACHE/old_scaled.$FORMAT" -i "$CACHE/new_scaled.$FORMAT" \
        -filter_complex "
            [0:v]setpts=PTS[old];
            [1:v]setpts=PTS[new];
            [old]pad=3840:1080:0:0[old_pad];
            [new]pad=3840:1080:1920:0[new_pad];
            [old_pad][new_pad]overlay=shortest=1:x='$new_x':y=0[combined];
            [combined]crop=1920:1080:0:0
        " -frames:v 1 "$CACHE/new$i.$FORMAT" &
done
wait
set_walls
