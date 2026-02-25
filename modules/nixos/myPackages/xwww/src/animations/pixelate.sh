#!/usr/bin/env bash

MAX_BLOCK=$PIXELATE_SIZE   # maximum pixel block size

setup
for i in $(seq 1 $FRAMES); do
    f=$(echo "scale=4; ($i-1) / ($FRAMES-1)" | bc)
    block_old=$(echo "$f * ($MAX_BLOCK-1) + 1" | bc | awk '{printf "%.0f", $1}')
    block_new=$((MAX_BLOCK + 1 - block_old))
    w2_old=$((R_X / block_old))
    h2_old=$((R_Y / block_old))
    [ $w2_old -lt 1 ] && w2_old=1
    [ $h2_old -lt 1 ] && h2_old=1
    w2_new=$((R_X / block_new))
    h2_new=$((R_Y / block_new))
    [ $w2_new -lt 1 ] && w2_new=1
    [ $h2_new -lt 1 ] && h2_new=1
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
        [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
        [old]scale=${w2_old}:${h2_old}:flags=neighbor,scale=$R_X:$R_Y:flags=neighbor[old_pix];
        [new]scale=${w2_new}:${h2_new}:flags=neighbor,scale=$R_X:$R_Y:flags=neighbor[new_pix];
        [old_pix][new_pix]blend=all_expr='A*(1-${f})+B*${f}'[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
done
wait
set_walls
