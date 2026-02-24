#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

setup
for i in $(seq 1 $FRAMES); do
    if [ $FRAMES -eq 1 ]; then
        offset=960
    else
        offset=$(( (i-1) * 960 / (FRAMES-1) ))
    fi
    L=$offset
    R=$((1920 - offset))
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p[old];
        [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p[new];
        nullsrc=size=1920x1080,
               geq=lum='if(lt(X,${L}) + gt(X,${R}), 255, 0)',
               format=gray[mask];
        [old][new][mask]maskedmerge[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png"

    if [ $? -ne 0 ] || [ ! -s "$CACHE/new$i.png" ]; then
        echo "Error generating frame $i. Aborting."
        exit 1
    fi
done
wait
set_walls
