#!/bin/bash

SCRIPT_FILE="/home/hoks/code/swgt/scripts/productivity.sh"
STATE_MARKER="#__WORK_STATE__"

notify() {
    dunstify "Productivity Timer" "$1"
}

get_today() {
    date +"%Y-%m-%d"
}

get_today_minutes() {
    local today=$(get_today)
    awk -v marker="$STATE_MARKER" -v today="$today" '
        $0 ~ marker {
            split($0, a, " ")
            if (a[2] == today) print a[3]
        }
    ' "$SCRIPT_FILE"
}

set_today_minutes() {
    local today=$(get_today)
    local minutes="$1"
    local tmpfile=$(mktemp)
    local found=0
    awk -v marker="$STATE_MARKER" -v today="$today" -v minutes="$minutes" '
        BEGIN {found=0}
        $0 ~ marker {
            split($0, a, " ")
            if (a[2] == today) {
                print marker, today, minutes
                found=1
                next
            }
        }
        {print}
        END {
            if (!found) print marker, today, minutes
        }
    ' "$SCRIPT_FILE" > "$tmpfile"
    mv "$tmpfile" "$SCRIPT_FILE"
    chmod +x "$SCRIPT_FILE"
}

start_timer() {
    local work_duration=$((30 * 60))
    local break_duration=$((30 * 60))
    local start_time=$(date +%s)
    local today=$(get_today)
    local minutes=$(get_today_minutes)
    if [[ -z "$minutes" ]]; then
        minutes=0
    fi

    notify "Work session started! 30 minutes."
    for ((i=1; i<=30; i++)); do
        sleep 60
        minutes=$((minutes + 1))
        set_today_minutes "$minutes"
    done

    notify "Work session ended! Break time: 30 minutes."
    sleep $break_duration

    notify "Break ended! Today's work time: $minutes minutes."
}

show_overview() {
    local minutes=$(get_today_minutes)
    if [[ -z "$minutes" ]]; then
        minutes=0
    fi
    notify "Today's work time: $minutes minutes."
}

case "$1" in
    start)
        start_timer
        ;;
    stop)
        show_overview
        ;;
    *)
        ;;
esac

#__WORK_STATE__ 2024-06-11 0
#__WORK_STATE__ 2025-06-05 30
#__WORK_STATE__ 2025-06-10 30
#__WORK_STATE__ 2025-08-01 26
#__WORK_STATE__ 2025-08-26 1
