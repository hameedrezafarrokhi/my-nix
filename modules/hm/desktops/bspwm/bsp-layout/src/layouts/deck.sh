#!/bin/bash

# import the lib.
source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

master_size=$DECK_RATIO;


execute_layout() {

  wcount=$(bspc query -N -n .window.!floating -d focused | wc -l)
  vcount=$(bspc query -N -n .window.!hidden.!floating -d focused | wc -l)
  mcount=$(bspc query -N '@/1' -n .descendant_of.window.!floating | wc -l )
  scount=$(bspc query -N '@/2' -n .descendant_of.window.!floating | wc -l )

  if [ "$wcount" -lt 3 ]; then
    for widd in $(bspc query -N '@/' -n .descendant_of.window.!floating); do
      bspc node "$widd" -g hidden=off
    done
  fi

  if [ "$wcount" -gt 2 ]; then
   #snode=$(bspc query -N '@/2' -n .descendant_of.window.!hidden.!floating | head -n +1)

    if [ "$vcount" -eq 0 ]; then
      for widdd in $(bspc query -N '@/' -n .descendant_of.window.!floating | head -n 2); do
        bspc node "$widdd" -g hidden=off
      done
    fi
    if [ "$vcount" -eq 1 ]; then
      bspc node $(bspc query -N '@/' -n .descendant_of.window.!floating | head -n 1) -g hidden=off
    fi
    vmcount=$(bspc query -N '@/1' -n .descendant_of.window.!floating.!hidden | wc -l )
    if [ "$vmcount" -eq 0 ]; then
     #new_master=$(bspc query -N '@/' -n .descendant_of.window.!floating | head -n 2
      mnode=$(bspc query -N '@/' -n .descendant_of.window.!floating.!hidden | head -n 1)
      bspc node $mnode -n '@/1'
    fi
    for wid in $(bspc query -N '@/1' -n .descendant_of.window.!floating | tail -n +2); do
      bspc node "$wid" -n '@/2'
    done
    for h in $(bspc query -N '@/2' -n .descendant_of.window.!hidden.!floating | tail -n +2); do
      bspc node "$h" -g hidden=on
    done
    vncount=$(bspc query -N '@/2' -n .descendant_of.window.!floating.!hidden | wc -l )
    if [ "$vncount" -eq 0 ]; then
      bspc node $(bspc query -N '@/2' -n .descendant_of.window.!floating | head -n 1) -g hidden=off
    fi
  fi

  rotate '@/' vertical 90;
  rotate '@/2' horizontal 90;
  local stack_node=$(bspc query -N '@/2' -n);
  for parent in $(bspc query -N '@/2' -n .descendant_of.!window.!floating | grep -v $stack_node); do
    rotate $parent horizontal 90;
  done
  auto_balance '@/2';
  local mon_width=$(jget width "$(bspc query -T -m)");
  local want=$(echo "$master_size * $mon_width" | bc | sed 's/\..*//');
  local have=$(jget width "$(bspc query -T -n $(bspc query -N '@/1' -n .descendant_of.window.!floating.!hidden | head -n 1))");

  bspc node $(bspc query -N '@/1' -n .descendant_of.window.!floating.!hidden  | head -n 1) --resize right $((want - have)) 0;

}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;
