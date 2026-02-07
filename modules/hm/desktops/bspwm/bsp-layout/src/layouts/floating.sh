#!/usr/bin/env bash

# import the lib.
source "$ROOT/utils/layout.sh";


# () -> ()
execute_layout() {
  for node in $(bspc query -N -n .local.window.!sticky.!marked.$node_filter); do
    bspc node $node -t ~floating;
  done;
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
