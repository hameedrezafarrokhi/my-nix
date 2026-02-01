# str -> str
jget() {
    # TODO.
    key=$1;
    shift;
    var=${*#*\"$key\":};
    var=${var%%[,\}]*};
    echo "$var";
}

# () -> ()
check_dependencies () {
  for dep in bc bspc man; do
    !(which $dep >/dev/null 2>&1) && echo "[Missing dependency] bsp-layout needs $dep installed" && exit 1;
  done;
}

node_is_floating () {            #WARNING ADDED FUNCTIONS
  bspc query -T -n "$1.floating" >/dev/null 2>&1
}
node_is_hidden () {
  bspc query -T -n "$1" | grep -q '"hidden":true'
}
