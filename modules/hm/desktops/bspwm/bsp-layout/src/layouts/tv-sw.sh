#!/bin/bash

source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

node_filter=$FLAGS;

master_ratio=$HDCENTER_RATIO;
#master_ratio=0.5
master_size=$(awk "BEGIN {print $master_ratio * 100}")


equalize() {
  window_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l)

  rotate '@/' vertical 90
  rotate '@/2' horizontal 90
  local right_stack_node=$(bspc query -N '@/2' -n)
  for parent in $(bspc query -N '@/2' -n .descendant_of.$node_filter | grep -v $right_stack_node); do
    rotate $parent horizontal 90
  done

  rotate '@/1/1' horizontal 90
  local left_stack_node=$(bspc query -N '@/1/1' -n)
  for parent in $(bspc query -N '@/1/1' -n .descendant_of.$node_filter | grep -v $left_stack_node); do
    rotate $parent horizontal 90
  done

  auto_balance '@/2'
  auto_balance '@/1/1'

  local mon_width=$(jget width "$(bspc query -T -m)")
  local total_stack_size=$(( 100 - master_size ))
  local stack_size=$(( total_stack_size / 2 ))
  local want=$(( stack_size * mon_width / 100 ))
  local have_right=$(jget width "$(bspc query -T -n $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local have_left=$(jget width "$(bspc query -T -n $(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter | head -n 1))")

  if (( window_count > 2 )); then
      bspc node $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n 1) -z left $((have_right - want)) 0;
      bspc node $(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter| head -n 1) -z right $((want - have_left)) 0;
  else
     auto_balance '@/'
  fi
}

calculate() {
  local mast_count=$(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter | wc -l);   #WARNING ADDED NEW SECTION
  local first_stack_count=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter | wc -l);
  local total_win_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l);
  if [ $total_win_count -gt 2 ]; then
    if [ $first_stack_count -eq 0 ]; then
      bspc node $(bspc query -N '@/' -n last.descendant_of.window.$node_filter | head -n 1) -n '@/1';
    fi
    if [ $mast_count -eq 0 ]; then
      bspc node $(bspc query -N '@/' -n last.descendant_of.window.$node_filter | tail -n 1) -n '@/1/2';
    fi                                                                                       #END OF NEW SECTION
  fi

  [ -z $(bspc query -N -n @/1/2) ] && bspc node $(bspc query -N -n .local.window.$node_filter | tail -n 1) -n @/1
  if (( $(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter | wc -l) > 1 )); then
    for node in $(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter | tail -n +2); do
      bspc node $node -n @/1/1
    done
  fi

  local A='@/2'
  local B='@/1/1'
  mapfile -t a < <(bspc query -N "$A" -n .descendant_of.window.$node_filter)
  mapfile -t b < <(bspc query -N "$B" -n .descendant_of.window.$node_filter)
  local na=${#a[@]}
  local nb=${#b[@]}
  local t=$((na + nb))
  local ta=$((t / 2))
  local tb=$(( (t + 1) / 2 ))   # B gets extra if odd
  while (( na > ta )); do
      bspc node "${a[-1]}" -n "$B"
      unset 'a[-1]'
      ((na--, nb++))
  done
  while (( nb > tb )); do
      bspc node "${b[-1]}" -n "$A"
      unset 'b[-1]'
      ((nb--, na++))
  done

}

execute_layout() {
  while [[ ! "$#" == 0 ]]; do
    case "$1" in
      --master-size) master_size="$2"; shift; ;;
      *) echo "$x" ;;
    esac;
    shift;
  done;
  calculate
  rotate '@/' vertical 90
  rotate '@/1' vertical -90
  rotate '@/1/1' horizontal 90
  calculate
  equalize

  rotate '@/1' horizontal 90
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;

