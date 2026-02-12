#!/bin/bash

# import the lib.
source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

master_size=$DWINDLE_RATIO;
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
  local nodes=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter);
  local win_count=$(echo "$nodes" | wc -l);

  if [ $win_count -ne 1 ]; then
    local new_node=$(bspc query -N '@/1' -n last.descendant_of.window.$node_filter | head -n 1);

    if [ -z "$new_node" ]; then
      new_node=$(bspc query -N '@/2' -n last.descendant_of.window.$node_filter | head -n 1);
    fi

    local root=$(echo -e "$nodes" | head -n 1);

    # move everything into 2 that is not our new_node
    for wid in $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | grep -v $root); do
      bspc node "$wid" -n '@/2';
    done

    bspc node "$root" -n '@/1';
  fi

  rotate '@/' vertical 90;
  rotate '@/2' horizontal 90;


normalize_stack() {
  local node="$1"

  local first="${node}/1"
  local second="${node}/2"

  # check if first exists
  bspc query -N "$first" -n .descendant_of.window.$node_filter >/dev/null 2>&1 || return

  # move extra windows from first to second
  mapfile -t wins < <(bspc query -N "${first}" -n .descendant_of.window.$node_filter  2>/dev/null)
  if ((${#wins[@]} > 1)); then
    for ((i=1; i<${#wins[@]}; i++)); do
      bspc node "${wins[i]}" -n "$second"
    done
  fi

  # recursively normalize deeper stack
  bspc query -N "$second" -n .descendant_of.window.$node_filter  >/dev/null 2>&1 && normalize_stack "$second"
}

# start at root stack node
normalize_stack "@/2"
normalize_stack "@/2"
normalize_stack "@/2"
normalize_stack "@/2"



  local stack_node=$(bspc query -N '@/2' -n);
  local dir=vertical
  for parent in $(bspc query -N '@/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate "$parent" "$dir" 90;
    if [ "$dir" = vertical ]; then
      dir=horizontal
    else
      dir=vertical
    fi
  done

  local mon_width=$(jget width "$(bspc query -T -m)");
  local want=$(echo "$master_size * $mon_width" | bc | sed 's/\..*//');
  local have=$(jget width "$(bspc query -T -n $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | head -n 1))");  #WARNING CHANGED

  bspc node $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | head -n 1) --resize right $((want - have)) 0;  #WARNING CHANGED


  local first_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_1_size=$(( first_size + second_size ))
  local want1=$(( total_1_size / 2 ))
  bspc node $(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter | head -n 1) -z bottom 0 $((want1 - first_size ));

  local first_a_size=$(jget width "$(bspc query -T -n $(bspc query -N '@/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_a_size=$(jget width "$(bspc query -T -n $(bspc query -N '@/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_1_a_size=$(( first_a_size + second_a_size ))
  local want1_a=$(( total_1_a_size / 2 ))
  bspc node $(bspc query -N '@/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z right $(( want1_a - first_a_size )) 0;

  local first_2_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_2_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_2_size=$(( first_2_size + second_2_size ))
  local want2=$(( total_2_size / 2 ))
  bspc node $(bspc query -N '@/2/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z bottom 0 $(( want2 - first_2_size ));



  local first_2_a_size=$(jget width "$(bspc query -T -n $(bspc query -N '@/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_2_a_size=$(jget width "$(bspc query -T -n $(bspc query -N '@/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_2_a_size=$(( first_2_a_size + second_2_a_size ))
  local want2_a=$(( total_2_a_size / 2 ))
  bspc node $(bspc query -N '@/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z right $(( want2_a - first_2_a_size )) 0;

  local first_3_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_3_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_3_size=$(( first_3_size + second_3_size ))
  local want3=$(( total_3_size / 2 ))
  bspc node $(bspc query -N '@/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z bottom 0 $(( want3 - first_3_size ));

  local first_3_a_size=$(jget width "$(bspc query -T -n $(bspc query -N '@/2/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_3_a_size=$(jget width "$(bspc query -T -n $(bspc query -N '@/2/2/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_3_a_size=$(( first_3_a_size + second_3_a_size ))
  local want3_a=$(( total_3_a_size / 2 ))
  bspc node $(bspc query -N '@/2/2/2/2/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z right $(( want3_a - first_3_a_size )) 0;


 #local last_stack_node=$(bspc query -N '@/2/2/2/2/2/2/2' -n);
 #for lastparent in $(bspc query -N '@/2/2/2/2/2/2/2' -n .descendant_of.!window.$node_filter | grep -v $last_stack_node); do
 #  rotate "$lastparent" horizontal 90;
 #done
  auto_balance '@/2/2/2/2/2/2/2';


}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;

