#!/usr/bin/env bash

source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

node_filter=$FLAGS;

# List[args] -> ()
execute_layout() {
  local target='first';

  for node in $(bspc query -N -n .local.window.$node_filter | sort); do
    bspc node $node -n "$(bspc query -N -n @/${target})";
    [[ "$target" == 'first' ]] && target='second' || target='first';
  done;

  rotate '@/' horizontal 90;
  rotate '@/2' vertical 90;
  rotate '@/1' vertical 90;

  local stack_node=$(bspc query -N '@/2' -n);
  for parent in $(bspc query -N '@/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/1' -n);
  for parent in $(bspc query -N '@/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local first_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_size=$((  first_size + second_size ))
  local want=$(( total_size / 2 ))
  bspc node $(bspc query -N '@/1' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - first_size));


  auto_balance '@/1';
  auto_balance '@/2';

}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
