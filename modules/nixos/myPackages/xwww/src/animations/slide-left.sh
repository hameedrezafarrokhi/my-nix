#!/usr/bin/env bash

setup
for i in $(seq 1 $FRAMES); do
    new_w=$(echo "scale=2; $i * $R_X / $FRAMES" | bc | cut -d. -f1)
    old_w=$((R_X - new_w))
    if [ $new_w -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    elif [ $old_w -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    else
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
            [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
            [old]crop=${old_w}:$R_Y:0:0[left];
            [new]crop=${new_w}:$R_Y:${old_w}:0[right];
            [left][right]hstack=inputs=2[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    fi
done
wait
set_walls
