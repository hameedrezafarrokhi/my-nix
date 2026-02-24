# this module extracts the user config.

# get the name of the config file.
XDG_CONF=${XDG_CONFIG_DIR:-"$HOME/.config"}
CONFIG_DIR="$XDG_CONF/xwww"

# Default config.
export TRANSITION_CMD=(hsetroot -cover)
export FINAL_CMD=(hsetroot -cover)
export SLEEP=0.001
export FRAMES=14
export ANIMATION="fade"
export ACCEL=(-hwaccel vaapi)
export FORMAT=png
export RND=
# -c:v mjpeg

source "$CONFIG_DIR/xwwwc" 2> /dev/null || true;
