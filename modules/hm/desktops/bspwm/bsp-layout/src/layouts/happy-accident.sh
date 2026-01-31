#!/usr/bin/env bash

# import the lib.
source "$ROOT/utils/common.sh"
source "$ROOT/utils/layout.sh"
source "$ROOT/utils/config.sh"

LEFT_RATIO=0.9
RIGHT_RATIO=0.9

left_size=$LEFT_RATIO
right_size=$RIGHT_RATIO
node_filter="!hidden"

# List[args] -> ()
execute_layout() {
    while [[ ! "$#" == 0 ]]; do
        case "$1" in
            --left-size) left_size="$2"; shift ;;
            --right-size) right_size="$2"; shift ;;
            *) echo "$x" ;;
        esac
        shift
    done

    # ensure the count of the master child is 1, or make it so
    local nodes=$(bspc query -N '@/2' -n .descendant_of.window.$node_filter)
    local win_count=$(echo "$nodes" | wc -l)

    if [ $win_count -ne 1 ]; then
        local new_node=$(bspc query -N '@/2' -n last.descendant_of.window.$node_filter | head -n 1)
        [ -z "$new_node" ] && new_node=$(bspc query -N '@/1' -n last.descendant_of.window.$node_filter | head -n 1)
        local root=$(echo "$nodes" | head -n 1)

        # assign the master (center)
        bspc node "$root" -n '@/2'

        # collect all windows for stacks
        local all_windows=($(bspc query -N -n .window.$node_filter -d))
        local stack_windows=()
        for wid in "${all_windows[@]}"; do
            [ "$wid" != "$root" ] && stack_windows+=("$wid")
        done

        # ensure @/1 (left stack) exists
        if [ -n "${stack_windows[0]}" ] && [ -z "$(bspc query -N '@/1' -n 2>/dev/null)" ]; then
            bspc node "${stack_windows[0]}" -n '@/1'
        fi

        # ensure @/3 (right stack) exists if at least 2 windows
        if [ ${#stack_windows[@]} -ge 2 ] && [ -z "$(bspc query -N '@/3' -n 2>/dev/null)" ]; then
            bspc node "${stack_windows[1]}" -n '@/3'
        fi

        # assign remaining windows (3rd+ in stack_windows) alternately to left/right
        local idx=1
        for i in $(seq 2 $((${#stack_windows[@]} - 1))); do
            wid="${stack_windows[$i]}"
            if [ $((idx % 2)) -eq 1 ]; then
                bspc node "$wid" -n '@/1'  # left stack
            else
                bspc node "$wid" -n '@/3'  # right stack
            fi
            idx=$((idx+1))
        done
    fi

    # CHANGED: Horizontal layout for root
    rotate '@/1' vertical 90  # Root splits HORIZONTALLY

   #rotate '@/2' horizontal 90

    # Keep master vertical (or horizontal based on preference)
   #rotate '@/3' horizontal 90   # Master splits VERTICALLY

    # Stack arrangement - keep them vertical
    local stack_node_left=$(bspc query -N '@/1' -n)
    for parent in $(bspc query -N '@/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node_left); do
        rotate $parent vertical 90  # Left stack vertical
    done

    local stack_node_right=$(bspc query -N '@/3' -n)
    for parent in $(bspc query -N '@/3' -n .descendant_of.!window.$node_filter | grep -v $stack_node_right); do
        rotate $parent vertical 90  # Right stack vertical
    done

    auto_balance '@/1'
    auto_balance '@/3'

    # CHANGED: Use horizontal resize instead of vertical
    local mon_width=$(jget width "$(bspc query -T -m)")

    local have_left=$(jget width "$(bspc query -T -n '@/1')")
    local have_right=$(jget width "$(bspc query -T -n '@/3')")

    # Resize horizontally to create center master with side stacks
    bspc node '@/1' --resize right $((left_size * mon_width - have_left)) 0
    bspc node '@/3' --resize left  $((have_right - right_size * mon_width)) 0
}

cmd=$1
shift
case "$cmd" in
    run) execute_layout "$@" ;;
esac
