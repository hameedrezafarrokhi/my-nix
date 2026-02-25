# User config

XDG_CONF=${XDG_CONFIG_DIR:-"$HOME/.config"}
CONFIG_DIR="$XDG_CONF/xwww"

# Default config
export R_X=1920
export R_Y=1080

export TRANSITION_CMD="hsetroot -cover"
export FINAL_CMD="hsetroot -cover "

export SLEEP=0.001
export FRAMES=14
export ANIMATION="fade"
export ACCEL=(-hwaccel vaapi)
export FORMAT=png
export RND=

export PIXELATE_SIZE=64
export WAVE_AMP=50
export WAVE_LENGHT=200

source "$CONFIG_DIR/xwwwrc" 2> /dev/null || true;
