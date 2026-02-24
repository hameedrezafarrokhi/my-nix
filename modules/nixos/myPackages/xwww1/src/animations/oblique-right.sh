#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

MIN_T=0          # at (0,0)
MAX_T=3000       # at (1920,1080)

setup
for i in $(seq 1 $FRAMES); do
    T=$(echo "scale=2; $MIN_T + ($i-1) * ($MAX_T - $MIN_T) / ($FRAMES - 1)" | bc | cut -d. -f1)
    if [ $i -eq 1 ] && [ $T -eq $MIN_T ]; then
        ffmpeg -y -i "$CUR_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.png" &
    elif [ $i -eq $FRAMES ] && [ $T -ge $MAX_T ]; then
        ffmpeg -y -i "$NEW_WALL" -filter_complex "[0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080" -frames:v 1 "$CACHE/new$i.png" &
    else
        ffmpeg -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
            [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
            nullsrc=size=1920x1080,geq=lum='if(lte(X+Y, ${T}), 255, 0)'[mask];
            [old][new][mask]maskedmerge[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.png" &
    fi
done
wait
set_walls
