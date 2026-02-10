#!/bin/bash

source "$ROOT/utils/common.sh";
source "$ROOT/utils/layout.sh";
source "$ROOT/utils/config.sh";

node_filter=$FLAGS;


equalize() {
  local stack_node=$(bspc query -N '@/2/1' -n);
  for parent in $(bspc query -N '@/2/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/2/2' -n);
  for parent in $(bspc query -N '@/2/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/1/1' -n);
  for parent in $(bspc query -N '@/1/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/1/2' -n);
  for parent in $(bspc query -N '@/1/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done
  auto_balance '@/2/1'
  auto_balance '@/2/2'
  auto_balance '@/1/1'
  auto_balance '@/1/2'


  local first_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local third_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local fourth_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_size=$((  first_size + second_size + third_size + fourth_size ))
  local want=$(( total_size / 4 ))
  bspc node $(bspc query -N '@/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z top 0 $((fourth_size - want));
  bspc node $(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - first_size));
  bspc node $(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - second_size));
 #bspc node $(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter| head -n 1) -z right 0 $((third_size - want));
}

calculate() {
# bootstrap: make sure @/1 and @/2 both have two windows (if possible)
mapfile -t a < <(bspc query -N '@/1' -n .descendant_of.window.$node_filter)
mapfile -t b < <(bspc query -N '@/2' -n .descendant_of.window.$node_filter)

na=${#a[@]}
nb=${#b[@]}

# first ensure @/1
while (( na < 2 && nb > 0 )); do
    bspc node "${b[-1]}" -n '@/1'
    unset 'b[-1]'
    ((na++, nb--))
done

# then ensure @/2
while (( nb < 2 && na > 0 )); do
    bspc node "${a[-1]}" -n '@/2'
    unset 'a[-1]'
    ((nb++, na--))
done

# four stacks
A1='@/1/1'   # highest priority
A2='@/1/2'
B1='@/2/1'
B2='@/2/2'   # lowest priority

mapfile -t a1 < <(bspc query -N "$A1" -n .descendant_of.window.$node_filter)
mapfile -t a2 < <(bspc query -N "$A2" -n .descendant_of.window.$node_filter)
mapfile -t b1 < <(bspc query -N "$B1" -n .descendant_of.window.$node_filter)
mapfile -t b2 < <(bspc query -N "$B2" -n .descendant_of.window.$node_filter)

n1=${#a1[@]}
n2=${#a2[@]}
n3=${#b1[@]}
n4=${#b2[@]}

t=$(( n1 + n2 + n3 + n4 ))
base=$(( t / 4 ))
rem=$(( t % 4 ))

# priority order for extras: A1 → A2 → B1 → B2
t1=$(( base + (rem >= 1) ))
t2=$(( base + (rem >= 2) ))
t3=$(( base + (rem >= 3) ))
t4=$(( base ))

move() {
    local -n src=$1
    local dst=$2
    bspc node "${src[-1]}" -n "$dst"
    unset 'src[-1]'
}

while :; do
    moved=0

    # fill A1
    (( n1 < t1 && n4 > t4 )) && { move b2 "$A1"; ((n4--, n1++, moved=1)); }
    (( n1 < t1 && n3 > t3 )) && { move b1 "$A1"; ((n3--, n1++, moved=1)); }
    (( n1 < t1 && n2 > t2 )) && { move a2 "$A1"; ((n2--, n1++, moved=1)); }

    # fill A2
    (( n2 < t2 && n4 > t4 )) && { move b2 "$A2"; ((n4--, n2++, moved=1)); }
    (( n2 < t2 && n3 > t3 )) && { move b1 "$A2"; ((n3--, n2++, moved=1)); }
    (( n2 < t2 && n1 > t1 )) && { move a1 "$A2"; ((n1--, n2++, moved=1)); }

    # fill B1
    (( n3 < t3 && n4 > t4 )) && { move b2 "$B1"; ((n4--, n3++, moved=1)); }
    (( n3 < t3 && n1 > t1 )) && { move a1 "$B1"; ((n1--, n3++, moved=1)); }
    (( n3 < t3 && n2 > t2 )) && { move a2 "$B1"; ((n2--, n3++, moved=1)); }

    # fill B2 (last)
    (( n4 < t4 && n1 > t1 )) && { move a1 "$B2"; ((n1--, n4++, moved=1)); }
    (( n4 < t4 && n2 > t2 )) && { move a2 "$B2"; ((n2--, n4++, moved=1)); }
    (( n4 < t4 && n3 > t3 )) && { move b1 "$B2"; ((n3--, n4++, moved=1)); }

    (( moved )) || break
done
}

execute_layout() {
window_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l)
  if (( window_count < 4 )); then
    for parent in $(bspc query -N '@/' -n .descendant_of.$node_filter); do
      rotate $parent horizontal -90
    done
    rotate '@/' horizontal 90;
    auto_balance '@/';
  else
    calculate
    rotate '@/' horizontal 90
    rotate '@/1' horizontal 90
    rotate '@/2' horizontal 90
    rotate '@/1/1' vertical 90
    rotate '@/1/2' vertical 90
    rotate '@/2/1' vertical 90
    rotate '@/2/2' vertical 90
    calculate
    equalize
    equalize
  fi
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;

