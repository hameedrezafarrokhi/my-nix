# this module extracts the user config.

# get the name of the config file.
XDG_CONF=${XDG_CONFIG_DIR:-"$HOME/.config"};
CONFIG_DIR="$XDG_CONF/bsp-layout";

# Default config.
export TALL_RATIO=0.6;
export WIDE_RATIO=0.6;
export CENTER_RATIO=0.6;             #WARNING ADDED NEW LINE
export RCENTER_RATIO=0.6;            #WARNING ADDED NEW LINE
export DCENTER_RATIO=0.5;            #WARNING ADDED NEW LINE
export HDCENTER_RATIO=0.5;           #WARNING ADDED NEW LINE
export DECK_RATIO=0.5;               #WARNING ADDED NEW LINE
export DWINDLE_RATIO=0.5;            #WARNING ADDED NEW LINE

export USE_NAMES=1;

export FLAGS="!hidden.!floating";    #WARNING ADDED NEW LINE

# extract the actual user config.
source "$CONFIG_DIR/layoutrc" 2> /dev/null || true;
