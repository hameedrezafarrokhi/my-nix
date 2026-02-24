# this module extracts the user config.

# get the name of the config file.
XDG_CONF=${XDG_CONFIG_DIR:-"$HOME/.config"}
CONFIG_DIR="$XDG_CONF/xwww"

# Default config.
export SLEEP=0.001
export FRAMES=14
export ANIMATION="fade"

source "$CONFIG_DIR/xwwwc" 2> /dev/null || true;
