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

  local stack_node=$(bspc query -N '@/2/2/1' -n);
  for parent in $(bspc query -N '@/2/2/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/2/2/2' -n);
  for parent in $(bspc query -N '@/2/2/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/1/1' -n);
  for parent in $(bspc query -N '@/1/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/1/2/1' -n);
  for parent in $(bspc query -N '@/1/2/1' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  local stack_node=$(bspc query -N '@/1/2/2' -n);
  for parent in $(bspc query -N '@/1/2/2' -n .descendant_of.!window.$node_filter | grep -v $stack_node); do
    rotate $parent vertical 90;
  done

  auto_balance '@/2/1'
  auto_balance '@/2/2'
  auto_balance '@/1/1'
  auto_balance '@/1/2/1'
  auto_balance '@/1/2/2'


  local first_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local second_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/2/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local third_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/1/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local fourth_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local fifth_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2/1' -n .descendant_of.window.$node_filter | head -n 1))")
  local sixth_size=$(jget height "$(bspc query -T -n $(bspc query -N '@/2/2/2' -n .descendant_of.window.$node_filter | head -n 1))")
  local total_size=$((  first_size + second_size + third_size + fourth_size + fifth_size + sixth_size ))
  local want=$(( total_size / 6 ))


  bspc node $(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - first_size))
  bspc node $(bspc query -N '@/1/2/1' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - second_size))
  bspc node $(bspc query -N '@/1/2/2' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - third_size))
  bspc node $(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter| head -n 1) -z bottom 0 $((want - fourth_size))

 #bspc node $(bspc query -N '@/2/2/2' -n .descendant_of.window.$node_filter | head -n 1) -z top 0 $((sixth_size - want))
  bspc node $(bspc query -N '@/2/2/1' -n .descendant_of.window.$node_filter | head -n 1) -z bottom 0 $((want - fifth_size))
 #
 #

 #

}

calculate() {
# bootstrap: ensure splits exist for 6 stacks
# tree needed:
# @/1 -> (@/1/1 , @/1/2)
# @/1/2 -> (@/1/2/1 , @/1/2/2)
# @/2 -> (@/2/1 , @/2/2)
# @/2/2 -> (@/2/2/1 , @/2/2/2)

mapfile -t a < <(bspc query -N '@/1' -n .descendant_of.window.$node_filter)
mapfile -t b < <(bspc query -N '@/2' -n .descendant_of.window.$node_filter)
na=${#a[@]}
nb=${#b[@]}

# ensure @/1 has 3
while (( na < 3 && nb > 0 )); do
    bspc node "${b[-1]}" -n '@/1'
    unset 'b[-1]'
    ((na++, nb--))
done

# ensure @/2 has 3
while (( nb < 3 && na > 0 )); do
    bspc node "${a[-1]}" -n '@/2'
    unset 'a[-1]'
    ((nb++, na--))
done

# ensure @/1/2 has 2
mapfile -t a11 < <(bspc query -N '@/1/1' -n .descendant_of.window.$node_filter)
mapfile -t a12 < <(bspc query -N '@/1/2' -n .descendant_of.window.$node_filter)
n11=${#a11[@]}
n12=${#a12[@]}

while (( n12 < 2 && n11 > 0 )); do
    bspc node "${a11[-1]}" -n '@/1/2'
    unset 'a11[-1]'
    ((n12++, n11--))
done

# ensure @/2/2 has 2
mapfile -t b21 < <(bspc query -N '@/2/1' -n .descendant_of.window.$node_filter)
mapfile -t b22 < <(bspc query -N '@/2/2' -n .descendant_of.window.$node_filter)
n21=${#b21[@]}
n22=${#b22[@]}

while (( n22 < 2 && n21 > 0 )); do
    bspc node "${b21[-1]}" -n '@/2/2'
    unset 'b21[-1]'
    ((n22++, n21--))
done

# six stacks — priority for extras:
S1='@/1/1'
S2='@/1/2/1'
S3='@/1/2/2'
S4='@/2/1'
S5='@/2/2/1'
S6='@/2/2/2'

mapfile -t s1 < <(bspc query -N "$S1" -n .descendant_of.window.$node_filter)
mapfile -t s2 < <(bspc query -N "$S2" -n .descendant_of.window.$node_filter)
mapfile -t s3 < <(bspc query -N "$S3" -n .descendant_of.window.$node_filter)
mapfile -t s4 < <(bspc query -N "$S4" -n .descendant_of.window.$node_filter)
mapfile -t s5 < <(bspc query -N "$S5" -n .descendant_of.window.$node_filter)
mapfile -t s6 < <(bspc query -N "$S6" -n .descendant_of.window.$node_filter)

n1=${#s1[@]}
n2=${#s2[@]}
n3=${#s3[@]}
n4=${#s4[@]}
n5=${#s5[@]}
n6=${#s6[@]}

t=$(( n1+n2+n3+n4+n5+n6 ))
base=$(( t / 6 ))
rem=$(( t % 6 ))

# extras priority: S1 → S2 → S3 → S4 → S5 → S6
t1=$(( base + (rem >= 1) ))
t2=$(( base + (rem >= 2) ))
t3=$(( base + (rem >= 3) ))
t4=$(( base + (rem >= 4) ))
t5=$(( base + (rem >= 5) ))
t6=$(( base ))

move() {
    local -n src=$1
    local dst=$2
    bspc node "${src[-1]}" -n "$dst"
    unset 'src[-1]'
}

while :; do
    moved=0

    (( n1 < t1 && n6 > t6 )) && { move s6 "$S1"; ((n6--, n1++, moved=1)); }
    (( n1 < t1 && n5 > t5 )) && { move s5 "$S1"; ((n5--, n1++, moved=1)); }
    (( n1 < t1 && n4 > t4 )) && { move s4 "$S1"; ((n4--, n1++, moved=1)); }
    (( n1 < t1 && n3 > t3 )) && { move s3 "$S1"; ((n3--, n1++, moved=1)); }
    (( n1 < t1 && n2 > t2 )) && { move s2 "$S1"; ((n2--, n1++, moved=1)); }

    (( n2 < t2 && n6 > t6 )) && { move s6 "$S2"; ((n6--, n2++, moved=1)); }
    (( n2 < t2 && n5 > t5 )) && { move s5 "$S2"; ((n5--, n2++, moved=1)); }
    (( n2 < t2 && n4 > t4 )) && { move s4 "$S2"; ((n4--, n2++, moved=1)); }
    (( n2 < t2 && n3 > t3 )) && { move s3 "$S2"; ((n3--, n2++, moved=1)); }
    (( n2 < t2 && n1 > t1 )) && { move s1 "$S2"; ((n1--, n2++, moved=1)); }

    (( n3 < t3 && n6 > t6 )) && { move s6 "$S3"; ((n6--, n3++, moved=1)); }
    (( n3 < t3 && n5 > t5 )) && { move s5 "$S3"; ((n5--, n3++, moved=1)); }
    (( n3 < t3 && n4 > t4 )) && { move s4 "$S3"; ((n4--, n3++, moved=1)); }
    (( n3 < t3 && n1 > t1 )) && { move s1 "$S3"; ((n1--, n3++, moved=1)); }
    (( n3 < t3 && n2 > t2 )) && { move s2 "$S3"; ((n2--, n3++, moved=1)); }

    (( n4 < t4 && n6 > t6 )) && { move s6 "$S4"; ((n6--, n4++, moved=1)); }
    (( n4 < t4 && n5 > t5 )) && { move s5 "$S4"; ((n5--, n4++, moved=1)); }
    (( n4 < t4 && n1 > t1 )) && { move s1 "$S4"; ((n1--, n4++, moved=1)); }
    (( n4 < t4 && n2 > t2 )) && { move s2 "$S4"; ((n2--, n4++, moved=1)); }
    (( n4 < t4 && n3 > t3 )) && { move s3 "$S4"; ((n3--, n4++, moved=1)); }

    (( n5 < t5 && n6 > t6 )) && { move s6 "$S5"; ((n6--, n5++, moved=1)); }
    (( n5 < t5 && n1 > t1 )) && { move s1 "$S5"; ((n1--, n5++, moved=1)); }
    (( n5 < t5 && n2 > t2 )) && { move s2 "$S5"; ((n2--, n5++, moved=1)); }
    (( n5 < t5 && n3 > t3 )) && { move s3 "$S5"; ((n3--, n5++, moved=1)); }
    (( n5 < t5 && n4 > t4 )) && { move s4 "$S5"; ((n4--, n5++, moved=1)); }

    (( n6 < t6 && n1 > t1 )) && { move s1 "$S6"; ((n1--, n6++, moved=1)); }
    (( n6 < t6 && n2 > t2 )) && { move s2 "$S6"; ((n2--, n6++, moved=1)); }
    (( n6 < t6 && n3 > t3 )) && { move s3 "$S6"; ((n3--, n6++, moved=1)); }
    (( n6 < t6 && n4 > t4 )) && { move s4 "$S6"; ((n4--, n6++, moved=1)); }
    (( n6 < t6 && n5 > t5 )) && { move s5 "$S6"; ((n5--, n6++, moved=1)); }

    (( moved )) || break
done
}

execute_layout() {
window_count=$(bspc query -N -n .window.$node_filter -d focused | wc -l)
  if (( window_count < 6 )); then
    for parent in $(bspc query -N '@/' -n .descendant_of.$node_filter); do
      rotate $parent horizontal -90
    done
    rotate '@/' horizontal 90;
    auto_balance '@/';
  else
    calculate
    rotate '@/' horizontal 90
    rotate '@/1' horizontal 90
    rotate '@/1/2' horizontal 90
    rotate '@/2' horizontal 90
    rotate '@/2/2' horizontal 90
    rotate '@/1/1' vertical 90
    rotate '@/1/2/1' vertical 90
    rotate '@/1/2/2' vertical 90
    rotate '@/2/1' vertical 90
    rotate '@/2/2/1' vertical 90
    rotate '@/2/2/2' vertical 90
    calculate
    equalize
    equalize
    equalize
    equalize
    equalize
   #equalize
  fi
}

cmd=$1; shift;
case "$cmd" in
  run) execute_layout "$@" ;;
  *) ;;
esac;

