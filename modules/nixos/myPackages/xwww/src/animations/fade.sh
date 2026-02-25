#!/usr/bin/env bash

CURRENT=$(cat "$HOME/.cache/xwww/current")
CURRENT_FADE=$(cat "$HOME/.cache/xwww/current-fade")
setup
IMAGES=$(( (FRAMES - 2) / 2 - 1 ))

if [[ "$CURRENT" != "$CURRENT_FADE"  ]]; then
  rm -f "$CACHE/fade"/old*
  #for i in $(seq 1 $IMAGES); do
  #    if [[ $i -lt $IMAGES ]]; then
  #        alpha=$(echo "scale=2; 0.05 + ($i - 1) * (0.75 / ($IMAGES - 1))" | bc)
  #        scale="iw/5"
  #    else
  #        alpha=0.90
  #        scale="iw/2"
  #    fi
  #    ffmpeg "${ACCEL[@]}" -y -i "$CUR_WALL" -vf "scale=$scale:-1,format=rgba,colorchannelmixer=aa=$alpha" "$CACHE/fade/old$i.$FORMAT"
  #    #for frame in "$CACHE/fade"/new*; do mv "$frame" "${frame/new/old}"; done
  #done
fi
wait
for i in $(seq 1 $IMAGES); do
    if [[ $i -lt $IMAGES ]]; then
        alpha=$(echo "scale=2; 0.05 + ($i - 1) * (0.75 / ($IMAGES - 1))" | bc)
        scale="iw/5"
    else
        alpha=0.90
        scale="iw/2"
    fi
    ffmpeg "${ACCEL[@]}" -y -i "$NEW_WALL" -vf "scale=$scale:-1,format=rgba,colorchannelmixer=aa=$alpha" "$CACHE/fade/new$i.$FORMAT"
done
wait 2>/dev/null
set_fade

