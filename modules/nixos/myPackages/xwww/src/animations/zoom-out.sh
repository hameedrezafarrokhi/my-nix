#!/usr/bin/env bash

setup
for i in $(seq 1 $FRAMES); do
    new_h=$(( i * R_Y / FRAMES ))
    old_h=$(( R_Y - new_h ))
    if [ $new_h -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    elif [ $old_h -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    else
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
            [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
            [old]crop=$R_X:${old_h}:0:0[old_top];
            [new]crop=$R_X:${new_h}:0:0[new_top];
            [new_top]pad=$R_X:$R_Y:0:0:color=black[new_padded];
            [old_top][new_padded]overlay=0:${old_h}:shortest=1[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    fi
done
wait
set_walls
