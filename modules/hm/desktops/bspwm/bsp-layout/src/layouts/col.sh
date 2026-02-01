#!/bin/bash

source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

node_filter=$FLAGS;

window_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l)

execute_layout() {
  if (( window_count <= 2 )); then
    auto_balance '@/';
  else
    for parent in $(bspc query -N '@/' -n .descendant_of.$node_filter); do
      rotate $parent vertical -90
    done
  fi
  rotate '@/' vertical 90;
  auto_balance '@/';
}
cmd=$1; shift;
case "$cmd" in
  run) execute_layout;;
  *) ;;
esac;
