#!/usr/bin/env bash

import the lib.

source "$ROOT/utils/common.sh"
source "$ROOT/utils/layout.sh"
source "$ROOT/utils/config.sh"

left_size=$LEFT_RATIO
right_size=$RIGHT_RATIO

node_filter="!hidden"

List[args] -> ()

execute_layout() {
while [[ ! "$#" == 0 ]]; do
case "$1" in
--left-size) left_size="$2"; shift; ;;
--right-size) right_size="$2"; shift; ;;
*) echo "$x" ;;
esac
shift
done

ensure the count of the master child is 1, or make it so

local nodes=$(bspc query -N '@/2' -n .descendant_of.window.$node_filter)
local win_count=$(echo "$nodes" | wc -l)

if [ $win_count -ne 1 ]; then
local new_node=$(bspc query -N '@/2' -n last.descendant_of.window.$node_filter | head -n 1)

[ -z "$new_node" ] && new_node=$(bspc query -N '@/1' -n last.descendant_of.window.$node_filter | head -n 1)
[ -z "$new_node" ] && new_node=$(bspc query -N '@/3' -n last.descendant_of.window.$node_filter | head -n 1)

local root=$(echo "$nodes" | head -n 1)

# move everything except root out of center (into 1 and 3)
i=1
for wid in $(echo "$nodes" | grep -v $root); do
  if [ $((i % 2)) -eq 1 ]; then
    bspc node "$wid" -n '@/1'        # odd → left
  else
    bspc node "$wid" -n '@/3'        # even → right
  fi
  i=$((i+1))
done

bspc node "$root" -n '@/2'

fi

rotate '@/' vertical 90
rotate '@/1' horizontal 90
rotate '@/3' horizontal 90

local stack_node_left=$(bspc query -N '@/1' -n)
for parent in $(bspc query -N '@/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node_left); do
rotate $parent horizontal 90
done

local stack_node_right=$(bspc query -N '@/3' -n)
for parent in $(bspc query -N '@/3' -n .descendant_of.!window.$node_filter | grep -v $stack_node_right); do
rotate $parent horizontal 90
done

auto_balance '@/1'
auto_balance '@/3'

local mon_width=$(jget width "$(bspc query -T -m)")

local want_left=$(( $left_size * $mon_width ))
local have_left=$(jget width "$(bspc query -T -n '@/1')")

local want_right=$(( $right_size * $mon_width ))
local have_right=$(jget width "$(bspc query -T -n '@/3')")

bspc node '@/1' --resize right $((want_left - have_left)) 0
bspc node '@/3' --resize left  $((have_right - want_right)) 0
}

cmd=$1
shift
case "$cmd" in
run) execute_layout "$@" ;;
esac
