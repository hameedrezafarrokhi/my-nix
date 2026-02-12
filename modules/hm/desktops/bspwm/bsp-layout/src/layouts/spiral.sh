#!/bin/bash

# import the lib.
source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

master_size=$DWINDLE_RATIO;
node_filter=$FLAGS;


# List[args] -> ()
execute_layout() {
  bash "$ROOT/layouts/dwindle.sh" run $*;

  window_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l)
  if (( window_count > 4 )); then
    bspc node @/2/2 -R -180
  fi
  if (( window_count > 6 )); then
    bspc node @/2/2/1/1 -R -180
  fi

}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;

