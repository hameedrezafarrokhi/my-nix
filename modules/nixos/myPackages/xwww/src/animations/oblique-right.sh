#!/usr/bin/env bash

MIN_T=0          # at (0,0)
MAX_T=3000       # at (1920,1080)

setup
for i in $(seq 1 $FRAMES); do
    T=$(echo "scale=2; $MIN_T + ($i-1) * ($MAX_T - $MIN_T) / ($FRAMES - 1)" | bc | cut -d. -f1)
    if [ $i -eq 1 ] && [ $T -eq $MIN_T ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    elif [ $i -eq $FRAMES ] && [ $T -ge $MAX_T ]; then
        ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -filter_complex "[0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    else
        ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
            [0:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[old];
            [1:v]scale=$R_X:$R_Y:force_original_aspect_ratio=increase,crop=$R_X:$R_Y[new];
            nullsrc=size="$R_X"x"$R_Y",geq=lum='if(lte(X+Y, ${T}), 255, 0)'[mask];
            [old][new][mask]maskedmerge[out]
        " -map "[out]" -frames:v 1 "$CACHE/new$i.$FORMAT" &
    fi
done
wait
set_walls
