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
  rotate '@/' horizontal 90
  rotate '@/2' vertical 90
  rotate '@/1/1' vertical 90
  local right_stack_node=$(bspc query -N '@/1/1' -n)
  for parent in $(bspc query -N '@/1/1' -n .descendant_of.$node_filter | grep -v $right_stack_node); do
  rotate $parent vertical 90
  done

  rotate '@/1/2' vertical 90
  local left_stack_node=$(bspc query -N '@/1/2' -n)
  for parent in $(bspc query -N '@/1/2' -n .descendant_of.$node_filter | grep -v $left_stack_node); do
  rotate $parent vertical 90
  done

  auto_balance '@/1/1'
  auto_balance '@/1/2'

  local mon_height=$(jget height "$(bspc query -T -m)")
  local want_master=$(( master_size * mon_height / 100 ))
  local have=$(jget height "$(bspc query -T -n $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local mast_diff=$((want_master - have))

  if (( mast_diff > 0 )); then
    if (( window_count > 2 )); then
        bspc node $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n 1) -z top 0 $((have - want_master));
    else
       auto_balance '@/'
    fi
  else
    bspc node $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n 1) -z top 0 $((have - want_master));
  fi
  local left_stack=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/1' -n .descendant_of.window.!hidden.!floating | head -n 1))")
  local right_stack=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/2' -n .descendant_of.window.!hidden.!floating | head -n 1))")
  local total_stack=$(( right_stack + left_stack ))
  local half_stack=$(( total_stack / 2 ))
  if (( right_stack > left_stack )); then
    local diff_right=$(( right_stack - left_stack ))
    local diff_needed=$(( diff_right / 2 ))
      bspc node $(bspc query -N '@/1/2' -n .descendant_of.window.!hidden.!floating | head -n 1) --resize top 0 $diff_needed
  else
    local diff_left=$(( left_stack - right_stack ))
    local diff_needed=$(( diff_left / 2 ))
    bspc node $(bspc query -N '@/1/1' -n .descendant_of.window.!hidden.!floating | head -n 1) --resize bottom 0 -$diff_needed
  fi
}

calculate() {
  local mast_count=$(bspc query -N '@/2' -n .descendant_of.window.$node_filter | wc -l);   #WARNING ADDED NEW SECTION
  local first_stack_count=$(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter | wc -l);
  local second_stack_count=$(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter | wc -l);
  local total_win_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l);
  if [ $total_win_count -gt 2 ]; then
    if [ $mast_count -eq 0 ]; then
      bspc node $(bspc query -N '@/' -n last.descendant_of.window.$node_filter | head -n 1) -n '@/2';
    fi
    if [ $secon_stack_count -eq 0 ]; then
      bspc node $(bspc query -N '@/' -n last.descendant_of.window.$node_filter | tail -n 1) -n '@/1';
    fi
    if [ $secon_stack_count -eq 0 ]; then
      bspc node $(bspc query -N '@/1' -n last.descendant_of.window.$node_filter | tail -n 1) -n '@/1/2';
    fi
  fi                                                                                   #END OF NEW SECTION

  [ -z $(bspc query -N -n @/2) ] && bspc node $(bspc query -N -n .local.window.$node_filter | tail -n 1) -n @/2
  if (( $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | wc -l) > 2 )); then
    for node in $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | tail -n +2); do
      bspc node $node -n @/1
    done
  fi
  if [ $total_win_count -gt 3 ]; then
    local new_mast_count=$(bspc query -N '@/2' -n .descendant_of.window.$node_filter | wc -l);
    if (( new_mast_count < 2 )); then
      bspc node $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | tail -n 1) -n @/2
    fi
  fi

  local A='@/1/1'
  local B='@/1/2'
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

  rotate '@/' horizontal 90
  rotate '@/1' horizontal -90
  rotate '@/1/2' vertical 90

  calculate

  equalize
 #equalize
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
