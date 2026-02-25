#!/usr/bin/env bash

MIN_XY=-$R_X    # at (0,1080) bottom‑left
MAX_XY=$R_Y     # at (1920,0) top‑right

setup
for i in $(seq 1 $FRAMES); do
    T=$(echo "scale=2; $MAX_XY - ($i-1) * ($MAX_XY - $MIN_XY) / ($FRAMES - 1)" | bc | cut -d. -f1)
    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
        [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
        nullsrc=size="$R_X"x"$R_Y",geq=lum='if(gte(X-Y, ${T}), 255, 0)'[mask];
        [old][new][mask]maskedmerge[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
done
wait
set_walls
