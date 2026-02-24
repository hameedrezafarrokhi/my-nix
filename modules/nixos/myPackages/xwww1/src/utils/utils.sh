#!/usr/bin/env bash

setup() {
  mkdir -p "$HOME/.cache/xwww/$ANIMATION"
  if [[ -f "$HOME/.fehbg" ]]; then
    CUR_WALL=$(grep -o "'.*'" "$HOME/.fehbg" | head -1 | tr -d "'")
  else
    CUR_WALL=$(cat "$HOME/.cache/xwww/current")
  fi
  CACHE="$HOME/.cache/xwww/$ANIMATION"
}

set_walls() {
  for i in $(seq 1 $FRAMES); do
      hsetroot -cover "$CACHE/new$i.png"
      sleep $SPEED
  done
  feh --bg-fill "$NEW_WALL"
  rm -f "$CACHE/new*.png"
  echo "$1" >> "$HOME/.cache/xwww/current"
}

set_fade() {
  if [[ -f "$CACHE/old2.png" ]]; then
      for i in $(seq $IMAGES -1 1); do
          hsetroot -cover "$CACHE/old$i.png" && sleep $SPEED
      done
  fi
  for i in $(seq 1 $IMAGES); do
      hsetroot -cover "$CACHE/new$i.png" && sleep $SPEED
  done
  feh --bg-fill "$1"
  rm -f "$CACHE"/old*.png
  for frame in "$CACHE"/new*.png; do mv "$frame" "${frame/new/old}"; done
}
