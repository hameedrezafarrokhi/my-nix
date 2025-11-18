#!/bin/bash
# Center-master layout for already spawned windows in bspwm

# Get all windows on the current desktop
windows=($(bspc query -N -n .window -d focused))
[ ${#windows[@]} -eq 0 ] && exit

master=${windows[0]}
stack=("${windows[@]:1}")

# Tile all windows
for w in "${windows[@]}"; do
    bspc node "$w" -t tiled
done

# Step 1: Split master horizontally to create left/right containers
bspc node "$master" -p west   # left
bspc node "$master" -p east   # right

# Step 2: Identify columns
cols=($(bspc query -N -n .leaf -d focused))
left=${cols[0]}
center=${cols[1]}
right=${cols[2]}

# Step 3: Move master to center
bspc node "$master" -n "$center"

# Step 4: Move remaining windows into left/right alternately
i=0
for w in "${stack[@]}"; do
    if (( i % 2 == 0 )); then
        bspc node "$w" -n "$left"
    else
        bspc node "$w" -n "$right"
    fi
    ((i++))
done

# Step 5: Stack left/right vertically
bspc node "$left" -s south
bspc node "$right" -s south

# Step 6: Resize for approximate 20/60/20
bspc node "$left" -z right 0.25
bspc node "$right" -z left 0.25

# Step 7: Focus master
bspc node "$center" -f
