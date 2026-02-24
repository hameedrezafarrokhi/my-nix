#!/bin/bash

export VERSION="{{VERSION}}";
export ROOT="{{SOURCE_PATH}}";

source "$ROOT/utils/config.sh"
source "$ROOT/utils/utils.sh"

if [ $# -lt 1 ]; then
    echo "Error: Path is required"
    echo "Usage: xwww <path_to_img> [--speed <number>] [--frame <number>] [--animation <animation_name>]"
    exit 1
fi

NEW_WALL="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --speed)
            SPEED="$2"
            shift 2
            ;;
        --frame)
            FRAMES="$2"
            shift 2
            ;;
        --animation)
            ANIMATION="$2"
            shift 2
            ;;
        --format)
            FORMAT="$2"
            shift 2
            ;;
        --random)
            RND="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

  if [[ -n "$RND" ]]; then
    set -- ${RND//,/ }
    export ANIMATION=$(eval "echo \${$((RANDOM % $# + 1))}")
  fi

$ROOT/animations/$ANIMATION.sh "$NEW_WALL" "$FRAMES" "$SPEED" "$ANIMATION" "$FORMAT" "$RND"
