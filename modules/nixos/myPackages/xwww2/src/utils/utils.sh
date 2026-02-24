#!/usr/bin/env bash

setup() {
  mkdir -p "$HOME/.cache/xwww/$ANIMATION"
  mkdir -p "$HOME/.cache/xwww/$ANIMATION/fade"
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
  rm -f "$CACHE"/new*.png
  rm -f "$HOME/.cache/xwww/current"
  echo "$NEW_WALL" >> "$HOME/.cache/xwww/current"
}

set_fade() {
  if [[ -f "$CACHE/fade/old2.png" ]]; then
      for i in $(seq $IMAGES -1 1); do
          hsetroot -cover "$CACHE/fade/old$i.png" && sleep $SPEED
      done
  fi
  for i in $(seq 1 $IMAGES); do
      hsetroot -cover "$CACHE/fade/new$i.png" && sleep $SPEED
  done
  feh --bg-fill "$1"
  rm -f "$CACHE/fade"/old*.png
  for frame in "$CACHE/fade"/new*.png; do mv "$frame" "${frame/new/old}"; done
}
