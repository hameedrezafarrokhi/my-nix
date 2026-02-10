#!/bin/bash

source "$ROOT/utils/config.sh";

node_filter=$FLAGS;

execute_layout() {
window_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l)
  if (( window_count < 5 )); then
    bash "$ROOT/layouts/row2.sh" run $*;
  elif (( window_count > 4 && window_count < 10 )); then
    bash "$ROOT/layouts/row3.sh" run $*;
  elif (( window_count > 9 && window_count < 17 )); then
    bash "$ROOT/layouts/row4.sh" run $*;
  elif (( window_count > 16 && window_count < 26 )); then
    bash "$ROOT/layouts/row5.sh" run $*;
  elif (( window_count > 25 )); then
    bash "$ROOT/layouts/row6.sh" run $*;
  fi
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
