#!/usr/bin/env bash

setup
for i in $(seq 1 $FRAMES); do
    if [ $FRAMES -eq 1 ]; then
        offset=$(( R_X / 2 ))
    else
        H_X=$(( R_X / 2 ))
        offset=$(( (i-1) * H_X / (FRAMES-1) ))
    fi
    L=$offset
    R=$((R_X - offset))
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y,format=yuv420p[old];
        [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y,format=yuv420p[new];
        nullsrc=size="$R_X"x"$R_Y",
               geq=lum='if(lt(X,${L}) + gt(X,${R}), 255, 0)',
               format=gray[mask];
        [old][new][mask]maskedmerge[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT"

    if [ $? -ne 0 ] || [ ! -s "$CACHE/new$i.$FORMAT" ]; then
        echo "Error generating frame $i. Aborting."
        exit 1
    fi
done
wait
set_walls
