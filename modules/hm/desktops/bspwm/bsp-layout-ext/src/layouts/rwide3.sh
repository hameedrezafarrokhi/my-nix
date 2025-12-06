#!/usr/bin/env bash

source "$ROOT/utils/common.sh"
source "$ROOT/utils/layout.sh"
source "$ROOT/utils/config.sh"

master_size=$TALL_RATIO
node_filter="!hidden"

execute_layout() {
while [[ ! "$#" == 0 ]]; do
    case "$1" in
        --master-size) master_size="$2"; shift ;;
        *) echo "$x" ;;
    esac
    shift
done

local nodes=$(bspc query -N '@/2' -n .descendant_of.window.$node_filter)
local win_count=$(echo "$nodes" | wc -l)
local desired=3

if [ $win_count -lt $desired ]; then
    for wid in $(bspc query -N '@/1' -n .descendant_of.window.$node_filter | head -n $((desired - win_count))); do
        bspc node "$wid" -n '@/2'
    done
elif [ $win_count -gt $desired ]; then
    local excess=$(echo "$nodes" | tail -n +$((desired + 1)))
    for wid in $excess; do
        bspc node "$wid" -n '@/1'
    done
fi

rotate '@/' horizontal 90
rotate '@/1' vertical 90
#rotate '@/1' vertical 90

for parent in $(bspc query -N '@/1' -n .descendant_of.!window.$node_filter | grep -v $(bspc query -N '@/1' -n)); do
    rotate $parent vertical 90
done
for parent in $(bspc query -N '@/2' -n .descendant_of.!window.$node_filter | grep -v $(bspc query -N '@/2' -n)); do
    rotate $parent vertical 90
done

auto_balance '@/2'
auto_balance '@/1'

local mon_width=$(jget width "$(bspc query -T -m)")
local want=$(( master_size * mon_width ))
local have=$(jget width "$(bspc query -T -n '@/2')")

bspc node '@/2' --resize right $((want - have)) 0
}

cmd=$1
shift
case "$cmd" in
    run) execute_layout "$@" ;;
esac
