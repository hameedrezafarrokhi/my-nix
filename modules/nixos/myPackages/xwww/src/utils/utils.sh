#!/usr/bin/env bash

setup() {
  rm -f "$HOME/.cache/xwww/animation"
  mkdir -p "$HOME/.cache/xwww/$ANIMATION"
  if [[ -f "$HOME/.cache/xwww/current" ]]; then
    CUR_WALL=$(cat "$HOME/.cache/xwww/current")
  else
    if [[ -f "$HOME/.fehbg" ]]; then
      CUR_WALL=$(grep -o "'.*'" "$HOME/.fehbg" | head -1 | tr -d "'")
    fi
  fi
  CACHE="$HOME/.cache/xwww/$ANIMATION"
}

set_walls() {
  for i in $(seq 1 $FRAMES); do
      $TRANSITION_CMD "$CACHE/new$i.$FORMAT"
      sleep $SPEED
  done
  wait
  $FINAL_CMD "$NEW_WALL"
  rm -f "$CACHE"/new*
  rm -f "$HOME/.cache/xwww/current"
  echo "$NEW_WALL" >> "$HOME/.cache/xwww/current"
  echo "$ANIMATION" >> "$HOME/.cache/xwww/animation"
}

set_fade() {
  if [[ -f "$CACHE/fade/old"* ]]; then
      for i in $(seq $IMAGES -1 1); do
          $TRANSITION_CMD "$CACHE/fade/old$i.$FORMAT" && sleep $SPEED
      done
  fi
  for i in $(seq 1 $IMAGES); do
      $TRANSITION_CMD "$CACHE/fade/new$i.$FORMAT" && sleep $SPEED
  done
  wait
  $FINAL_CMD "$NEW_WALL"
  rm -f "$CACHE/fade"/old*
  for frame in "$CACHE/fade"/new*; do mv "$frame" "${frame/new/old}"; done
  rm -f "$HOME/.cache/xwww/current-fade"
  rm -f "$HOME/.cache/xwww/current"
  echo "$NEW_WALL" >> "$HOME/.cache/xwww/current"
  echo "$NEW_WALL" >> "$HOME/.cache/xwww/current-fade"
  echo "$ANIMATION" >> "$HOME/.cache/xwww/animation"
}
