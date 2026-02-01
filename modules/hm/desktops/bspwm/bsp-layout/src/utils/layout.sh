# import the lib.
source "$ROOT/utils/common.sh";
source "$ROOT/utils/config.sh";

node_filter=$FLAGS;

# (node, want, angle) -> ()
rotate() {
  # Amend the split type so we are arranged correctly.
  node=$1;
  want=$2;
  have=$(jget splitType "$(bspc query -T -n "$node")");
  have=${have:1:${#have}-2};
  angle=$3;

  if [[ "$have" != "$want" ]]; then
    bspc node "$node" -R "$angle";
  fi
}

# node -> ()
auto_balance() {
  # Balance the tree rooted at some node automatically.
  bspc node "$1" -B -n .descendant_of.window.$node_filter;    #WARNING CHANGED
}
