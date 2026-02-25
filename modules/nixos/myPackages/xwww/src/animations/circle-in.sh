#!/usr/bin/env bash

CX=$(( R_X / 2 ))  # Center of screen
CY=$(( R_Y / 2 ))

setup
MAX_R=$(echo "scale=2; sqrt(($CX)^2 + ($CY)^2)" | bc | cut -d. -f1)
for i in $(seq 1 $FRAMES); do
    R=$(echo "scale=2; $MAX_R * ($FRAMES - $i) / ($FRAMES - 1)" | bc | cut -d. -f1)
    R2=$(( R * R ))
    ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -i "$CUR_WALL" -filter_complex "
        [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
        [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
        nullsrc=size="$R_X"x"$R_Y",geq=lum='if(lte((X-${CX})*(X-${CX}) + (Y-${CY})*(Y-${CY}), ${R2}), 255, 0)'[mask];
        [new][old][mask]maskedmerge[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
done
wait
set_walls
