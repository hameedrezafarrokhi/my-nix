#!/usr/bin/env bash

setup
for i in $(seq 1 $FRAMES); do
    H_X=$(( R_X / 2 ))
    offset=$(echo "($i-1) * $H_X / ($FRAMES-1)" | bc)
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
        [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y,format=yuv420p[new];
        [old]crop=$H_X:$R_Y:0:0[left];
        [old]crop=$H_X:$R_Y:$H_X:0[right];
        [new]null[bg];
        [bg][left]overlay=x=-${offset}:y=0[bg_left];
        [bg_left][right]overlay=x=$H_X+${offset}:y=0[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT"
    if [ $? -ne 0 ] || [ ! -s "$CACHE/new$i.$FORMAT" ]; then
        echo "Error generating frame $i. Aborting."
        exit 1
    fi
done
wait
set_walls
