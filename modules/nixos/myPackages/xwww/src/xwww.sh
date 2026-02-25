#!/bin/bash

export VERSION="{{VERSION}}";
export ROOT="{{SOURCE_PATH}}";

set -a
source "$ROOT/utils/config.sh"
set +a

source "$ROOT/utils/utils.sh"
export -f setup
export -f set_walls
export -f set_fade

if [ $# -lt 1 ]; then
    echo "Error: Path is required"
    echo "Usage: xwww <path_to_img> [--speed <number>] [--frame <number>] [--animation <animation_name>]"
    exit 1
fi

if [ -d "$1" ]; then
    images=($(find "$1" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.bmp" -o -iname "*.webp" \)))
    if [ ${#images[@]} -eq 0 ]; then
        echo "No images found in directory '$1'."
        exit 1
    fi
    random_index=$((RANDOM % ${#images[@]}))
    random_image="${images[$random_index]}"
    set -- "$random_image"
fi

export NEW_WALL="$1"
shift

while [[ $# -gt 0 ]]; do
    case $1 in
        --speed)
            export SPEED="$2"
            shift 2
            ;;
        --frame)
            export FRAMES="$2"
            shift 2
            ;;
        --animation)
            export ANIMATION="$2"
            shift 2
            ;;
        --format)
            export FORMAT="$2"
            shift 2
            ;;
        --random)
            export RND="$2"
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

if [[ -f "$ROOT/animations/$ANIMATION.sh" ]]; then
  $ROOT/animations/$ANIMATION.sh
elif [[ -f "$HOME/.config/xwww/animations/$ANIMATION.sh" ]]; then
  chmod +x "$HOME/.config/xwww/animations/$ANIMATION.sh"
  $HOME/.config/xwww/animations/$ANIMATION.sh
else
  echo "Animation '$ANIMATION' is not valid"
fi
