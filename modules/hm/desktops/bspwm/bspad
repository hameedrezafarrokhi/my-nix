#!/bin/sh

usage() {
    printf "usage: bspad COMMAND                                \n" 
    printf "                                                    \n"
    printf "  hide      sends focused node to the pad           \n"
    printf "  toggle    show/hide the last marked node          \n"
    printf "  cycle     cycles through pad's node               \n"
    printf "  unmark    remove the focused node from pad        \n"
    printf "  help      shows this message                      \n"
    printf "                                                    \n"
    printf "Licensed under The Unlicense <https://unlicense.org>\n"
}

getid() {
    bspc query -N -n "${1:-}.window"
}

nextid() {
    { getid "${marked}.!hidden"; getid .hidden; } |
        sort | 
        awk -v marked="${1}" '
            NR == 1     { sp=0; line=$0 }
            $0 ~ marked { sp=1; next    }
            sp == 1     { line=$0; exit }
            END         { print line    }
        ' 
}

hide() {
    id=$(getid focused) || exit
    bspc node "${id}" --flag hidden=on --state floating
    # If the marked node isn't visible, marking this one
    getid .marked.!hidden | {
        read -r mid
        [ -z "${mid:+x}" ] || exit

        getid .marked | xargs -I@ bspc node @ --flag marked=off
        bspc node "${id}" --flag marked=on
    }
}

toggle() {
    marked="$(getid .marked)" || exit
    getid "${marked}.local.!hidden" && flag="on" || flag="off"
    bspc node "${marked}" --flag hidden="${flag}" --to-desktop focused --focus
}

cycle() {
    exec >/dev/null
    # if no node is hidden, no need to process data
    getid .hidden || exit
    # get marked node id
    marked="$(getid .marked || getid .hidden | head -1)"
    # find next node & display it
    new=$(nextid "${marked}")
    # display new marked node
    bspc node "${new}" --to-desktop focused --flag marked=on --flag hidden=off --focus
    # hide previously marked node, only if it's different from the new one
    [ "${new}" != "${marked}" ] && bspc node "${marked}" --flag hidden=on --flag marked=off
}

unmark() {
    marked="$(getid .marked.focused)" || exit
    bspc node "${marked}" --flag marked=off --flag hidden=off
    new="$(nextid "${marked}")"
    [ "${new}" != "${marked}" ] && bspc node "${new}" --flag marked=on
}

case "$1" in 
    hide|toggle|cycle|unmark) $1 ;;
    help|*) usage && exit 1 ;;
esac
