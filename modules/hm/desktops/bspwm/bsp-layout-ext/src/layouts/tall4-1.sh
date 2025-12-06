#!/usr/bin/env bash

source "$ROOT/utils/common.sh"
source "$ROOT/utils/layout.sh"
source "$ROOT/utils/config.sh"

master_size=$TALL_RATIO
node_filter="!hidden"

execute_layout() {
while [[ ! "$#" == 0 ]]; do
case "$1" in
--master-size) master_size="$2"; shift; ;;
*) echo "$x" ;;
esac
shift
done

# ensure the count of the master child is 4
local nodes=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter)
local win_count=$(echo "$nodes" | wc -l)
local desired=4

if [ $win_count -ne $desired ]; then
    local new_node=$(bspc query -N '@/1' -n last.descendant_of.window.$node_filter | head -n 1)

    [ -z "$new_node" ] && new_node=$(bspc query -N '@/2' -n last.descendant_of.window.$node_filter | head -n 1)

    local root=$(echo -e "$nodes" | head -n 1)

    # move everything into the other side that is not our root
    for wid in $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | grep -v $root); do
      bspc node "$wid" -n '@/2'
    done

    bspc node "$root" -n '@/1'

    # if we still don't have enough, pull from stack until desired
    nodes=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter)
    win_count=$(echo "$nodes" | wc -l)
    if [ $win_count -lt $desired ]; then
        for wid in $(bspc query -N '@/2' -n .descendant_of.window.$node_filter | head -n $((desired - win_count))); do
            bspc node "$wid" -n '@/1'
        done
    fi

    # if we have too many, move extras to stack
    nodes=$(bspc query -N '@/1' -n .descendant_of.window.$node_filter)
    win_count=$(echo "$nodes" | wc -l)
    if [ $win_count -gt $desired ]; then
        local excess=$(echo "$nodes" | tail -n +$((desired + 1)))
        for wid in $excess; do
            bspc node "$wid" -n '@/2'
        done
    fi
fi

rotate '@/' vertical 90
rotate '@/2' horizontal 90

# make master split like the stack (horizontal)
rotate '@/1' horizontal 90

local stack_node=$(bspc query -N '@/2' -n)
for parent in $(bspc query -N '@/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
rotate $parent horizontal 90
done

auto_balance '@/2'
auto_balance '@/1'

local mon_width=$(jget width "$(bspc query -T -m)")

local want=$(( master_size * mon_width ))
local have=$(jget width "$(bspc query -T -n '@/1')")

bspc node '@/1' --resize right $((want - have)) 0
}

cmd=$1
shift
case "$cmd" in
run) execute_layout "$@" ;;
esac
