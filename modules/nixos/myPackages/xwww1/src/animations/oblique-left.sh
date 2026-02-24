#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

MIN_XY=-1080    # at (0,1080) bottom‑left
MAX_XY=1920     # at (1920,0) top‑right

setup
for i in $(seq 1 $FRAMES); do
    T=$(echo "scale=2; $MAX_XY - ($i-1) * ($MAX_XY - $MIN_XY) / ($FRAMES - 1)" | bc | cut -d. -f1)
    ffmpeg -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
        [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
        nullsrc=size=1920x1080,geq=lum='if(gte(X-Y, ${T}), 255, 0)'[mask];
        [old][new][mask]maskedmerge[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png" &
done
wait
set_walls
