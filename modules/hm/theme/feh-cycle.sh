#!/bin/bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"  # Change to your folder
WALLPAPERS=("$WALLPAPER_DIR"/*)  # Collect all image files in the folder

# Get the current wallpaper index (last used)
CURRENT_INDEX=$(cat ~/.current_wallpaper_index 2>/dev/null || echo 0)

# Calculate the next wallpaper index
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))

# Set the next wallpaper
feh --bg-fill "${WALLPAPERS[$NEXT_INDEX]}"

# Update the index for the next run
echo $NEXT_INDEX > ~/.current_wallpaper_index
