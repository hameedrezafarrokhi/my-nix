#!/usr/bin/env bash

# import the lib.
source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

master_size=$WIDE_RATIO;
node_filter=$FLAGS;

# List[args] -> ()
execute_layout() {
  while [[ ! "$#" == 0 ]]; do
    case "$1" in
      --master-size) master_size="$2"; shift; ;;
      *) echo "$x" ;;
    esac;
    shift;
  done;

  local mast_count=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter | wc -l);   #WARNING ADDED NEW SECTION
  if [ $mast_count -eq 0 ]; then
    bspc node $(bspc query -N '@/' -n last.descendant_of.window.$node_filter | head -n 1) -n '@/1';
  fi                                                                                       #END OF NEW SECTION

  # ensure the count of the master child is 1, or make it so
  local nodes=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter)
  local win_count=$(echo "$nodes" | wc -l)
  local desired=3

  if [ $win_count -lt $desired ]; then
    for wid in $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n $((desired - win_count))); do
      bspc node "$wid" -n '@/1'
    done
  elif [ $win_count -gt $desired ]; then
    local excess=$(echo "$nodes" | tail -n +$((desired + 1)))
    for wid in $excess; do
      bspc node "$wid" -n '@/2'
    done
  fi

  rotate '@/' horizontal 90
  rotate '@/2' vertical 90
 #rotate '@/1' vertical 90

  local stack_node=$(bspc query -N '@/2' -n);
  for parent in $(bspc query -N '@/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done
  local master_stack_node=$(bspc query -N '@/1' -n);
  for parent in $(bspc query -N '@/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  auto_balance '@/2';
  auto_balance '@/1';

  local mon_height=$(jget height "$(bspc query -T -m)");
  local want=$(echo "$master_size * $mon_height" | bc | sed 's/\..*//');
  local have=$(jget height "$(bspc query -T -n $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | head -n 1))");  #WARNING CHANGED

  bspc node $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | head -n 1) --resize bottom 0 $((want - have));  #WARNING CHANGED
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
