#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

CX=960  # Center of screen
CY=540

setup
MAX_R=$(echo "scale=2; sqrt(($CX)^2 + ($CY)^2)" | bc | cut -d. -f1)
for i in $(seq 1 $FRAMES); do
    R=$(echo "scale=2; ($i-1) * $MAX_R / ($FRAMES - 1)" | bc | cut -d. -f1)
    R2=$(( R * R ))
    ffmpeg -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[old];
        [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080[new];
        nullsrc=size=1920x1080,geq=lum='if(lte((X-${CX})*(X-${CX}) + (Y-${CY})*(Y-${CY}), ${R2}), 255, 0)'[mask];
        [old][new][mask]maskedmerge[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png" &
done
wait
set_walls
