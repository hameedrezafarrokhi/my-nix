#ifndef CONFIG_H
#define CONFIG_H

// Widget layout and appearance
#define BUTTON_SIZE 60
#define BUTTON_MARGIN 8
#define WIDGET_PADDING 8
#define ICON_TEXT_SPACING 8
#define BORDER_WIDTH 2

// Page settings (0 = vertical nav, 1 = horizontal nav)
#define MAX_PAGES 2
#define BUTTONS_PER_PAGE 5
#define DEFAULT_PAGE 0
#define SCROLL_DIRECTION 1

// Page indicator dots
#define PAGE_INDICATOR_HEIGHT 17
#define PAGE_DOT_SIZE 5
#define PAGE_DOT_SPACING 8

// Animation and behavior
#define MAX_ANIMATION_FRAMES 15
#define IDLE_SLEEP_MS 50
#define ANIMATION_SLEEP_MS 16
#define HOVER_ZONE_WIDTH 10
#define HOVER_ZONE_HEIGHT 100

// Auto-calculated dimensions
#define WIDGET_WIDTH (WIDGET_PADDING * 2 + BUTTON_SIZE)
#define WIDGET_HEIGHT (WIDGET_PADDING * 2 + (BUTTONS_PER_PAGE * BUTTON_SIZE) + ((BUTTONS_PER_PAGE - 1) * BUTTON_MARGIN) + PAGE_INDICATOR_HEIGHT + 10)

// Color theme (hex values)
#define BG_COLOR               "#0d0f1c"
#define TEXT_COLOR             "#e2e8f0"
#define WINDOW_BORDER_COLOR    "#9c98d5"
#define BORDER_COLOR           "#2a2d3a"
#define BUTTON_BG_COLOR        "#151925"
#define ACTIVE_BG_COLOR        "#2a2a3a"
#define ACTIVE_TEXT_COLOR      "#c6a0f6"
#define ACTIVE_BORDER_COLOR    "#c6a0f6"
#define PRESSED_BG_COLOR       "#1a1a22"
#define ICON_COLOR             "#fbf9fe"
#define ACTIVE_ICON_COLOR      "#c6a0f6"
#define PAGE_COLOR             "#3a3d4a"
#define PAGE_ACTIVE_COLOR      "#c6a0f6"

// Font configuration
#define ICON_FONT_NAME         "Symbols Nerd Font"
#define ICON_FONT_SIZE         15
#define TEXT_FONT_NAME         "BigBlueTermPlus Nerd Font Mono:weight=Regular:antialias=true:hinting=true"
#define TEXT_FONT_SIZE         9
#define PAGE_FONT_NAME         "BigBlueTermPlus Nerd Font Mono:weight=Regular:antialias=true:hinting=true"
#define PAGE_FONT_SIZE         8

// Window properties
#define WINDOW_NAME            "SWGT"
#define WINDOW_CLASS_NAME      "swgt"
#define WINDOW_CLASS_CLASS     "SWGT"
#define WINDOW_OPACITY         1


// { "icon", "name", "oncommand", "offcommand", toggle/click (0/1) }

// Page 0: System Controls
#define PAGE_0_CONFIG { \
    {"\uf0f3", "Dnd", "pkill -SIGUSR1 dunst", "pkill -SIGUSR2 dunst", 0}, \
    {"\uf185", "Night", "redshift -O 3500", "redshift -x", 0}, \
    {"\uf017", "Timer", "~/code/swgt/scripts/timer.sh", "", 1}, \
    {"\uf0ae", "Work", "~/code/swgt/scripts/productivity.sh start", "~/code/swgt/scripts/productivity.sh stop", 0}, \
    {"\uf011", "Power", "~/code/swgt/scripts/power.sh", "", 1} \
}

// Page 1: Connectivity & Devices
#define PAGE_1_CONFIG { \
    {"\uf1eb", "Wifi", "nmcli radio wifi off", "nmcli radio wifi on", 0}, \
    {"\uf293", "Bt", "rfkill block bluetooth", "rfkill unblock bluetooth", 0}, \
    {"\uf072", "Air", "rfkill block all; bluetoothctl power off", "rfkill unblock all; sleep 1; bluetoothctl power on", 0}, \
    {"\uf108", "Mirror", "xrandr --output HDMI-1 --same-as eDP-1 --mode 1920x1080", "", 1}, \
    {"\uf03d", "Rec", "n=1; while [ -e ~/Videos/screenrecord_${n}.mkv ]; do n=$((n+1)); done; ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 ~/Videos/screenrecord_${n}.mkv & echo $! > /tmp/screenrec_pid", "kill $(cat /tmp/screenrec_pid); rm /tmp/screenrec_pid", 0} \
}


// Button configuration helper
static inline const void* get_page_config(int page) {
    static const struct {
        char icon[8];
        char text[32]; 
        char toggle_command[256];
        char untoggle_command[256];
        int click_only;
    } page_configs[][BUTTONS_PER_PAGE] = {
        PAGE_0_CONFIG,
        PAGE_1_CONFIG, 
    };
    
    return (page >= 0 && page < MAX_PAGES) ? page_configs[page] : NULL;
}

#endif
