#ifndef CONFIG_H
#define CONFIG_H

#include <stddef.h> /* NULL, used by the CUSTOM_MENU_ENTRIES sentinel below */

/* ==================================================================
 * POLYBAR MODULE OUTPUT
 * ================================================================== */

/* Icons shown in polybar. These are Nerd Font glyphs; the X11 menus
 * render the same glyphs via Xft, so pick fonts that have them. */
#define ICON_SMARTPHONE            ""
#define ICON_TABLET                ""

/* Separate icons for the disconnected-but-paired and new/unpaired
 * states, instead of reusing the connected icon with just a different
 * color. Leave equal to ICON_SMARTPHONE/ICON_TABLET if you'd rather
 * keep the old look. */
#define ICON_DISCONNECTED_DEVICE   "󰥐"
#define ICON_NEW_DEVICE            "󰽁"

#define ICON_LOW_BATTERY   "󱐋"   /* prefixed onto the module when a connected device is critically low */
#define SEPARATOR          "|"

/* Colors for the two non-battery states (disconnected-but-paired,
 * new/unpaired). Full 6-digit hex. */
#define COLOR_DISCONNECTED  "#000000"
#define COLOR_NEWDEVICE     "#ffff00"

/* If a trusted+reachable device's battery is at or below this, ICON_
 * LOW_BATTERY is prepended to that device's entry in addition to its
 * normal color. Set to -1 to disable. */
#define LOW_BATTERY_THRESHOLD 15

/* Whether to print the numeric battery percentage next to the icon in
 * the bar itself. This is a *default* -- overridable per-run with
 * -b/--battery-percent regardless of what's set here. Note this
 * doesn't change how many D-Bus calls are made: battery charge is
 * already fetched every render to pick the icon's color band, so this
 * only changes what gets printed, not what gets queried. */
#define SHOW_BATTERY_PERCENT_DEFAULT 1

/* Battery color bands. Each row is { minimum percent (inclusive),
 * color }. Must be sorted descending by threshold; the last row's
 * threshold is effectively the "below everything else" catch-all
 * (make it 0). Change BATTERY_BAND_COUNT and this table together --
 * any number of bands works, not just 6. */
#define BATTERY_BAND_COUNT 6
typedef struct { int threshold; const char *color; } BatteryBand;
static const BatteryBand BATTERY_BANDS[BATTERY_BAND_COUNT] = {
    { 90, "#ffffff" },
    { 75, "#cccccc" },
    { 60, "#aaaaaa" },
    { 45, "#888888" },
    { 30, "#666666" },
    {  0, "#ff0000" },
};

/* When zero devices are known to KDE Connect at all (never paired
 * anything), the module is blank by default -- that stays the
 * default. Setting this to 1 shows ICON_NO_DEVICES/COLOR_NO_DEVICES
 * instead of blank. */
#define SHOW_ICON_WHEN_NO_DEVICES 1
#define ICON_NO_DEVICES    "󰥍"
#define COLOR_NO_DEVICES   "#444444"

/* Device name in the bar module, between the icon and the battery
 * percentage. Default off; overridable per-run with --show-name
 * regardless of what's set here (same pattern as -b/--battery-percent).
 * DEVICE_NAME_MAX_CHARS truncates to that many *characters* (not
 * bytes -- UTF-8 safe), appending DEVICE_NAME_TRUNCATE_SUFFIX. 0
 * means no limit. */
#define SHOW_DEVICE_NAME_DEFAULT     0
#define DEVICE_NAME_MAX_CHARS        7
#define DEVICE_NAME_TRUNCATE_SUFFIX  "\u2026"

/* Horizontal spacing in the bar module between icon/name/battery,
 * using polybar's %{O<px>} pixel-offset tag -- exact regardless of
 * bar font/size, unlike padding with literal space characters. Only
 * takes effect between segments that are actually both enabled (e.g.
 * ICON_NAME_SPACING_PX does nothing if SHOW_DEVICE_NAME is off). */
#define ICON_NAME_SPACING_PX      4
#define NAME_BATTERY_SPACING_PX   4

/* Polybar click actions for the device icon. Each is a full shell
 * command run via execvp-style invocation when that mouse button is
 * clicked (polybar buttons: 1=left, 2=middle, 3=right, 4=scroll up,
 * 5=scroll down). {SELF} expands to this binary's path, {ID} to the
 * device id, {NAME} to the device name (NOT shell-quoted for you --
 * quote it yourself in the template if you use it, the way the
 * built-in default does).
 *
 * Leave a slot as "" to not bind that button at all -- except slot 1,
 * where "" falls back to the built-in default (open the -m action
 * menu for that device), which is what makes this backward compatible
 * with every existing setup that hasn't touched this section. */
#define POLYBAR_ACTION_1  ""   /* empty = default: {SELF} -n '{NAME}' -i {ID} -m */
#define POLYBAR_ACTION_2  "notify-send hello"
#define POLYBAR_ACTION_3  ""
#define POLYBAR_ACTION_4  ""
#define POLYBAR_ACTION_5  ""

/* ==================================================================
 * SIM / CELLULAR SIGNAL STRENGTH
 * ================================================================== */
/* Read from KDE Connect's connectivity_report plugin, confirmed live:
 * plain int property "cellularNetworkStrength" (0-4) and string
 * property "cellularNetworkType" at <devpath>/connectivity_report.
 *
 * Only shown in the -m action menu header, on its own row below
 * battery -- never in the polybar bar module itself. */

#define SHOW_SIGNAL_STRENGTH   1

#define ICON_SIGNAL_0  "\uf6a9"  /* no signal   */
#define ICON_SIGNAL_1  "\uf68d"
#define ICON_SIGNAL_2  "\uf68e"
#define ICON_SIGNAL_3  "\uf68f"
#define ICON_SIGNAL_4  "\uf690"  /* full signal */

/* ==================================================================
 * X11 POPUP MENUS (xmenu / fmenu -- replaces rofi/zenity)
 * ================================================================== */

/* Xft font pattern, e.g. "monospace:size=11" or a specific family.
 * Must be a font that includes your Nerd Font icon glyphs if you want
 * icons to render inside the menus themselves (file picker, submenus). */
#define MENU_FONT            "JetBrainsMono Nerd Font:size=11"

#define MENU_COLOR_BG          "#1d2021"
#define MENU_COLOR_FG          "#ebdbb2"
#define MENU_COLOR_BORDER      "#458588"
#define MENU_COLOR_SELECT_BG   "#458588"
#define MENU_COLOR_SELECT_FG   "#1d2021"
#define MENU_COLOR_DISABLED_FG "#665c54"

#define MENU_BORDER_WIDTH   3   /* px */
#define MENU_ITEM_PAD_X     14  /* px, left/right padding inside each row */
#define MENU_ITEM_PAD_Y      6  /* px, top/bottom padding inside each row */
#define MENU_MIN_WIDTH      140 /* px */

/* Max content width in px; 0 disables (grow to fit, the old
 * behavior). When set and an entry's text would exceed it, the entry
 * (or, for the header row, the device name specifically) is trailed
 * with "..." -- submenu arrows and any protected suffix text (like
 * the header's "Battery: N%, Signal: N/4") are never truncated, only
 * the truncatable label portion is. */
#define MENU_MAX_WIDTH       360

/* Corner radius in px for both popup menus, applied by clipping the
 * window's real bounding shape via the X Shape extension -- the
 * window genuinely IS that shape at the X server level, so there's no
 * ambiguity for a compositor to get wrong. 0 disables (square
 * corners, the previous behavior). */
#define MENU_CORNER_RADIUS   8

/* Glyphs for a submenu indicator. LTR appends ARROW as a suffix; RTL
 * prepends ARROW_RTL as a prefix instead (see MENU_RTL below). */
#define MENU_SUBMENU_ARROW      " \u25b8"   /* " ▸" */
#define MENU_SUBMENU_ARROW_RTL  "\u25c2 "   /* "◂ " */

/* Where a submenu opens relative to its parent item, in px. Small
 * negative overlap looks more "attached"; 0 opens flush against the
 * parent. Applies to both LTR and RTL (mirrored automatically). */
#define MENU_SUBMENU_OVERLAP_X  2

/* 0 (default): menus open with their top-left corner at the pointer,
 *   growing right and down; submenus open to the right of their
 *   parent item; arrow suffix points right.
 * 1: mirrored -- menus open with their top-right corner at the
 *   pointer, growing left and down; submenus open to the left;
 *   arrow prefix points left. Use this if your bar/screen setup means
 *   menus opening rightward tend to run off-screen. */
#define MENU_RTL   0

/* Where -m/-p open by default. 1 = at the current pointer position
 * (typical for a bar click); 0 = at the fixed MENU_FIXED_X/Y below.
 * Overridable per-invocation with --at-pointer / --x N / --y N (CLI
 * flags always win over these defaults). */
#define MENU_POSITION_AT_POINTER  1
#define MENU_FIXED_X              20
#define MENU_FIXED_Y              20

/* The searchable file picker (fmenu) ignores the position entirely
 * and centers itself on screen when this is 1 -- a fixed popup
 * location makes more sense for something you're actively typing
 * into. Set to 0 to have it open at the same position -m did instead.
 * Size is independent of the main menu (FMENU_WIDTH above,
 * FMENU_MAX_VISIBLE_ROWS controls height). */
#define FMENU_CENTERED  1

/* ==================================================================
 * -m ACTION MENU: which entries appear (all independently toggleable)
 * ================================================================== */

#define SHOW_MENU_PING            1
#define SHOW_MENU_FIND_DEVICE     1
#define SHOW_MENU_SEND_FILE       1
#define SHOW_MENU_BROWSE_FILES    1
#define SHOW_MENU_CLIPBOARD       1
#define SHOW_MENU_MESSAGES        1
#define SHOW_MENU_SWITCH_DEVICE   1   /* only shown at all when >1 device is connected, regardless of this */
#define SHOW_MENU_PAIR_DEVICE     1   /* always offered (not just when unpaired) -- see README */
#define SHOW_MENU_UNPAIR          1
#define SHOW_MENU_OPEN_APP        1
#define SHOW_MENU_CUSTOM_ENTRIES  1   /* master toggle for the CUSTOM_MENU_ENTRIES table below */

/* ==================================================================
 * CUSTOM MENU ENTRIES
 * ================================================================== */
/* Appended at the bottom of the -m action menu. Each entry runs
 * `command` (via execvp, spawned detached, not waited on -- same as
 * the Messages/Open KDE Connect launchers) when selected.
 *
 * `command` is argv[0] verbatim: no shell is invoked, so shell syntax
 * (pipes, $VARS, ~, multiple arguments) will NOT work here -- point at
 * a script if you need any of that. Must be on PATH or an absolute
 * path.
 *
 * Leave the list empty to disable (SHOW_MENU_CUSTOM_ENTRIES above is
 * a separate master on/off switch if you'd rather keep entries defined
 * but temporarily hidden).
 *
 * Example:
 *   { "/home/you/bin/toggle-dnd.sh", "Toggle Do Not Disturb" },
 *   { "firefox",                     "Open Firefox" },
 */
typedef struct { const char *command; const char *label; } CustomMenuEntry;
static const CustomMenuEntry CUSTOM_MENU_ENTRIES[] = {
    /* { "/path/to/script", "My Script" }, */
    { "localsend_app", "LocalSend" }, /* sentinel -- always keep this as the last entry */
    { NULL, NULL } /* sentinel -- always keep this as the last entry */
};

/* ==================================================================
 * SEARCHABLE FILE PICKER (fmenu widget, replaces zenity, dmenu/rofi-style)
 * ================================================================== */

#define FMENU_WIDTH             460
#define FMENU_MAX_VISIBLE_ROWS  12

#define FMENU_PROMPT_ICON   "\uf002 "  /*  search glyph */
#define FMENU_CHECK_ON      "[x] "
#define FMENU_CHECK_OFF     "[ ] "

#define FILEPICKER_START_DIR   "~"
#define FILEPICKER_ICON_DIR    "\uf07b "  /*  folder */
#define FILEPICKER_ICON_FILE   "\uf15b "  /*  file   */
#define FILEPICKER_ICON_UP     "\uf062 "  /*  up     */
#define FILEPICKER_SHOW_HIDDEN  1

/* ==================================================================
 * DESKTOP NOTIFICATIONS
 * ================================================================== */
/* Sent via a direct D-Bus call to org.freedesktop.Notifications (the
 * standard desktop notification spec) -- no libnotify dependency
 * needed. Requires a running notification daemon (dunst, mako, etc). */

#define NOTIFY_ON_CONNECT       1
#define NOTIFY_ON_DISCONNECT    0
#define NOTIFY_ON_PAIR_REQUEST  1
#define NOTIFY_ON_LOW_BATTERY   1

#define NOTIFY_APP_NAME     "KDE Connect"
#define NOTIFY_ICON_NAME    "smartphone-symbolic"
#define NOTIFY_TIMEOUT_MS   5000

/* ==================================================================
 * DAEMON / D-BUS BEHAVIOR
 * ================================================================== */

#define DBUS_CALL_TIMEOUT_MS  2000

/* When running as --daemon, incoming D-Bus signals are coalesced: after
 * the first signal in a burst, wait this long for more before actually
 * re-rendering. */
#define DAEMON_DEBOUNCE_MS   150

/* ==================================================================
 * DEFAULT DEVICE (for -m with no -i/-n)
 * ================================================================== */
/* If set, this takes priority whenever -m is invoked without explicit
 * -i/-n -- ahead of live auto-detection. Leave DEFAULT_DEVICE_ID empty
 * to disable and rely entirely on auto-detection. Explicit -n/-i on
 * the command line always wins over this.
 * Find your device's id with:
 *   qdbus org.kde.kdeconnect /modules/kdeconnect org.kde.kdeconnect.daemon.devices
 * DEFAULT_DEVICE_NAME is only used for display -- if left empty, the
 * real name is fetched live over D-Bus instead. */
#define DEFAULT_DEVICE_ID    "adcf5d7a_3399_4747_8bf5_f730e58897d1"
#define DEFAULT_DEVICE_NAME  "Xiaomi 12T Pro"

/* ==================================================================
 * EXTERNAL APP LAUNCHERS
 * ================================================================== */
/* Spawned detached (not waited on), argv[0] only, same constraints as
 * CUSTOM_MENU_ENTRIES above. */

#define SMS_APP_BIN          "kdeconnect-sms"
#define KDECONNECT_APP_BIN   "kdeconnect-app"

#endif /* CONFIG_H */
