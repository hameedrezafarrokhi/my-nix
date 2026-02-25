#!/usr/bin/env bash

setup
for i in $(seq 1 $FRAMES); do
    new_w=$(( i * R_X / FRAMES ))
    old_w=$(( R_X - new_w ))
    if [ $new_w -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    elif [ $old_w -eq 0 ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    else
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
            [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
            [old]crop=${old_w}:$R_Y:${new_w}:0[old_crop];
            [old_crop]pad=$R_X:$R_Y:0:0:color=black[old_shifted];
            [new]crop=${new_w}:$R_Y:0:0[new_crop];
            [old_shifted][new_crop]overlay=${old_w}:0:shortest=1[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    fi
done
wait
set_walls
