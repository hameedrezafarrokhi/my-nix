#!/usr/bin/env bash

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"
NEW_WALL="$1"
FRAMES="$2"
SPEED="$3"

MAX_AMP=50          # maximum wave amplitude (pixels)
WAVELEN=200         # wavelength (pixels)
PI=$(echo "scale=10; 4*a(1)" | bc -l)   # π for sine calculation

setup
for i in $(seq 1 $FRAMES); do
    f=$(echo "scale=4; ($i-1) / ($FRAMES-1)" | bc)
    amp_old=$(( (i-1) * MAX_AMP / (FRAMES-1) ))
    amp_new=$(( MAX_AMP - amp_old ))
    ffmpeg -y -i "$CUR_WALL" -i "$NEW_WALL" -filter_complex "
        [0:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p[old];
        [1:v]scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p[new];
        [old]geq=lum='p(X+${amp_old}*sin(2*${PI}*Y/${WAVELEN}),Y)':
                  cb='p(X+${amp_old}*sin(2*${PI}*Y/${WAVELEN}),Y)':
                  cr='p(X+${amp_old}*sin(2*${PI}*Y/${WAVELEN}),Y)'[old_wavy];
        [new]geq=lum='p(X+${amp_new}*sin(2*${PI}*Y/${WAVELEN}),Y)':
                  cb='p(X+${amp_new}*sin(2*${PI}*Y/${WAVELEN}),Y)':
                  cr='p(X+${amp_new}*sin(2*${PI}*Y/${WAVELEN}),Y)'[new_wavy];
        [old_wavy][new_wavy]blend=all_expr='A*(1-${f})+B*${f}'[out]
    " -map "[out]" -frames:v 1 "$CACHE/new$i.png"
    if [ $? -ne 0 ] || [ ! -s "$CACHE/new$i.png" ]; then
        echo "Error generating frame $i. Aborting."
        exit 1
    fi
done
wait
set_walls
