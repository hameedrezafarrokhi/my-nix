#ifndef CONFIG_H
#define CONFIG_H

#include <stddef.h> /* NULL, used by several sentinel-terminated tables below */

/* ==================================================================
 * WHAT THIS FILE IS
 * ==================================================================
 * Same philosophy as polybar-kdeconnect's config.h: everything that
 * could plausibly be a preference lives here as a #define or a small
 * static table, not buried in the C files. Rebuild after editing
 * (`make`). Nothing here is read at runtime from an ini/yaml/etc --
 * that's a deliberate choice carried over from the kdeconnect module,
 * for the same reason: zero parsing cost, zero parse-error surface,
 * and the compiler catches typos in table shapes for you.
 */

/* ==================================================================
 * DEVICE DISCOVERY & FILTERING
 * ================================================================== */

/* Show devices UDisks flags as "system" (HintSystem -- root, boot,
 * swap, LUKS-backing partitions of the running system, etc) in
 * addition to genuinely removable/external ones. Off by default --
 * this module exists to manage USB sticks and external drives, not
 * your root filesystem. */
#define SHOW_INTERNAL_DEVICES 0

/* A device counts as "external" (and so is shown even when
 * SHOW_INTERNAL_DEVICES is 0) if it is NOT HintSystem, AND either its
 * drive reports Removable, or its ConnectionBus is in this list.
 * Compared case-insensitively against UDisks' ConnectionBus string
 * ("usb", "sdio", "mmc", "ata", "scsi", "nvme", ...). */
static const char *EXTERNAL_BUS_LIST[] = {
    "usb", "sdio", "mmc", "ieee1394", NULL
};

/* Skip block devices with no recognized filesystem at all (extended
 * partitions, empty/unformatted partition tables, swap). Swap is
 * always skipped regardless of this, since there's nothing useful a
 * mount/unmount menu could do with it. */
#define FILTER_REQUIRE_FILESYSTEM 1

/* Loop devices (/dev/loopN -- includes squashfs mounts, snap/flatpak
 * runtimes, and anything you've mounted with `losetup`) and zram
 * devices are noisy and rarely what you want in a removable-disk
 * widget. Filtered by default; the generic "Mount ISO" feature below
 * creates loop devices on purpose and those are always shown
 * regardless of this setting for as long as they're attached, since
 * you'd otherwise have no way to unmount/detach them again from the
 * menu. */
#define FILTER_HIDE_LOOP_DEVICES 1
#define FILTER_HIDE_ZRAM_DEVICES 1

/* Partitions smaller than this are hidden (handy for e.g. tiny EFI/
 * BIOS-boot partitions on external drives you don't care to see).
 * 0 disables the size filter entirely. */
#define FILTER_MIN_SIZE_BYTES 0

/* Explicit hide list, checked case-insensitively against: device node
 * (e.g. "/dev/sdb1"), filesystem UUID, filesystem label, and drive
 * serial -- first match on any of those hides the device. Matching is
 * substring-based, so a partial serial/label works too. */
static const char *HIDDEN_DEVICES[] = {
    /* "/dev/sdc1", */
    /* "OLD-BACKUP-UUID-HERE", */
    NULL
};

/* ==================================================================
 * PER-DEVICE OVERRIDES
 * ==================================================================
 * `match` is checked case-insensitively, in order, against: UUID,
 * label, device node, then drive serial -- first field that matches
 * on a given row wins. Leave any override field as "" to fall back to
 * the relevant global default. display_name overrides what's shown
 * as the device's name everywhere (bar + menu) instead of its
 * filesystem label. */
typedef struct {
    const char *match;
    const char *icon;            /* "" -> ICON_DEVICE_GENERIC */
    const char *icon_mounted;    /* "" -> icon (above), then ICON_DEVICE_MOUNTED   */
    const char *icon_unmounted;  /* "" -> icon (above), then ICON_DEVICE_UNMOUNTED */
    const char *color;           /* "" -> ramp/constant per DEVICE_COLOR_MODE */
    const char *display_name;    /* "" -> filesystem label, then device node */
} DeviceOverride;

static const DeviceOverride DEVICE_OVERRIDES[] = {
    /* { "3A21-5F09", "", "", "", "#8ec07c", "Backup Stick" }, */
    { NULL, NULL, NULL, NULL, NULL, NULL } /* sentinel -- keep last */
};

/* ==================================================================
 * AUTOMOUNT
 * ==================================================================
 * When a new external filesystem block device appears (InterfacesAdded
 * on a device that passes the filters above) and is not already
 * mounted, automatically mount it. Global default, with per-device
 * overrides (same matching rules as DEVICE_OVERRIDES). This only
 * fires on the *daemon* path (--daemon), never on a one-shot -d/-j
 * invocation, since a one-shot call has no business mutating mount
 * state as a side effect of printing bar text. */
#define AUTOMOUNT_GLOBAL_DEFAULT 0

typedef struct {
    const char *match;   /* same matching rules as DEVICE_OVERRIDES */
    int automount;       /* 0 or 1, overrides AUTOMOUNT_GLOBAL_DEFAULT for this device */
} AutomountOverride;

static const AutomountOverride AUTOMOUNT_OVERRIDES[] = {
    /* { "3A21-5F09", 1 }, */
    { NULL, 0 } /* sentinel -- keep last */
};

/* ==================================================================
 * ICONS (Nerd Font glyphs, same as the kdeconnect module -- the X11
 * menus render these via Xft too, so pick a MENU_FONT that has them)
 * ================================================================== */

#define ICON_DEVICE_GENERIC     "\uf0a0"  /*  generic drive */
#define ICON_DEVICE_MOUNTED     ""       /* "" -> falls back to ICON_DEVICE_GENERIC */
#define ICON_DEVICE_UNMOUNTED   ""       /* "" -> falls back to ICON_DEVICE_GENERIC */

/* Optional icons by rough device shape, used when a device has no
 * per-device override and DEVICE_ICON_BY_KIND is on. Detected from
 * UDisks ConnectionBus + Drive.Optical / MediaRemovable, not exact
 * science -- treat as a nice-to-have, not guaranteed-correct. */
#define DEVICE_ICON_BY_KIND 1
#define ICON_KIND_USB_STICK      "\uf287"
#define ICON_KIND_EXTERNAL_HDD   "\uf0a0"
#define ICON_KIND_SD_CARD        "\uf7c2"
#define ICON_KIND_OPTICAL        "\uf0a1"

#define SEPARATOR "|"

/* Bar module when zero eligible devices exist at all (nothing
 * plugged in, or everything is filtered out). Off by default (blank
 * module), same pattern as kdeconnect's SHOW_ICON_WHEN_NO_DEVICES. */
#define SHOW_ICON_WHEN_NO_DEVICES 0
#define ICON_NO_DEVICES   "\uf0a0"
#define COLOR_NO_DEVICES  "#444444"

/* Click actions for the "no devices" icon (only relevant when
 * SHOW_ICON_WHEN_NO_DEVICES is on). {SELF} is the only placeholder
 * that means anything here (no specific device to target). Slot 1
 * empty = genuinely unbound, unlike the per-device default below --
 * there's no obvious universal action when there's nothing to act on.
 * A natural choice is `{SELF} --generic-menu` to open the non-disk
 * menu (mount ISO, launch disk utility, custom entries). */
#define NO_DEVICE_ACTION_1  ""
#define NO_DEVICE_ACTION_2  ""
#define NO_DEVICE_ACTION_3  ""
#define NO_DEVICE_ACTION_4  ""
#define NO_DEVICE_ACTION_5  ""

/* ==================================================================
 * COLOR: constant vs. free-space ramp
 * ================================================================== */

#define COLOR_MODE_CONSTANT 0
#define COLOR_MODE_RAMP     1

/* Applies to devices with no per-device DEVICE_OVERRIDES color set.
 * RAMP colors by percentage of the filesystem that's still free (not
 * used) -- unmounted devices always use DEVICE_COLOR_CONSTANT/
 * DEVICE_COLOR_UNMOUNTED regardless of this, since there's no usage
 * data to ramp on. */
#define DEVICE_COLOR_MODE COLOR_MODE_RAMP

#define DEVICE_COLOR_CONSTANT   "#ebdbb2"  /* used verbatim when DEVICE_COLOR_MODE == COLOR_MODE_CONSTANT */
#define DEVICE_COLOR_UNMOUNTED  "#665c54"  /* dim: plugged in, not mounted */

/* { minimum percent free (inclusive), color }. Sorted descending by
 * threshold; last row's threshold should be 0 (catch-all). Resize
 * freely, just keep SPACE_RAMP_COUNT matching the table. */
#define SPACE_RAMP_COUNT 5
typedef struct { int min_percent_free; const char *color; } SpaceBand;
static const SpaceBand SPACE_RAMP[SPACE_RAMP_COUNT] = {
    { 50, "#b8bb26" },
    { 25, "#ebdbb2" },
    { 15, "#fabd2f" },
    {  5, "#fe8019" },
    {  0, "#fb4934" },
};

/* Prefixed onto a mounted device's bar entry when free space drops at
 * or below this percentage, in addition to its ramp/override color.
 * -1 disables. */
#define LOW_SPACE_THRESHOLD_PERCENT 10
#define ICON_LOW_SPACE "\uf071"

/* ==================================================================
 * BAR MODULE: which fields to print, and in what order
 * ==================================================================
 * Order is fixed: icon -> name -> used/free/total/percent -> mount
 * indicator, each gap using polybar's %{O<px>} pixel-offset tag (see
 * *_SPACING_PX below) so spacing is exact regardless of bar font.
 * Multiple devices are joined with SEPARATOR. */

#define BAR_SHOW_NAME            0
#define BAR_NAME_MAX_CHARS       7   /* UTF-8-char-safe; 0 = no limit */
#define BAR_NAME_TRUNCATE_SUFFIX "\u2026"

#define BAR_SHOW_PERCENT_USED    0
#define BAR_SHOW_PERCENT_FREE    0
#define BAR_SHOW_USED            0
#define BAR_SHOW_FREE            0
#define BAR_SHOW_TOTAL           0

/* Appends a small mounted/unmounted glyph after everything else for
 * that device (separate from swapping the main icon via
 * ICON_DEVICE_MOUNTED/UNMOUNTED above -- you can use either, both, or
 * neither). */
#define BAR_SHOW_MOUNT_STATE_SUFFIX 0
#define ICON_MOUNT_STATE_MOUNTED    "\uf00c"  /*  check */
#define ICON_MOUNT_STATE_UNMOUNTED  "\uf00d"  /*  x */

#define ICON_NAME_SPACING_PX     4
#define NAME_STATS_SPACING_PX    4

/* How many bar entries wide any one device's used/free/total numbers
 * get formatted to, e.g. "12.3G" -- see render.c:format_size(). Purely
 * cosmetic column-width hinting, not a hard truncation. */
#define SIZE_DECIMAL_PLACES 1

/* Polybar click actions for a device's bar segment. Same shape as the
 * kdeconnect module: buttons 1=left 2=middle 3=right 4=scroll-up
 * 5=scroll-down. Placeholders: {SELF} {ID} (UDisks object path,
 * shell-quoted for you already) {NODE} (device node) {NAME}. Slot 1
 * empty = built-in default (open the per-device action menu); every
 * other empty slot = unbound. */
#define POLYBAR_ACTION_1  ""   /* empty = default: {SELF} -i {ID} -m */
#define POLYBAR_ACTION_2  ""
#define POLYBAR_ACTION_3  ""
#define POLYBAR_ACTION_4  ""
#define POLYBAR_ACTION_5  ""

/* ==================================================================
 * USAGE CHECKING (how free/used space gets refreshed)
 * ==================================================================
 * Deliberately cheap: statvfs() on the mount point, which reads
 * cached superblock stats already held by the kernel -- no directory
 * walk, no real I/O, effectively free even for spinning disks or
 * network-backed filesystems. This is a ballpark (blocks * frsize),
 * not exact-byte accounting, which is exactly what was asked for. */

#define USAGE_CHECK_MODE_ONCE      0  /* check once, right after mount/connect; never again until manual reload */
#define USAGE_CHECK_MODE_PERIODIC  1  /* also re-check on a timer, see interval below */
#define USAGE_CHECK_MODE USAGE_CHECK_MODE_PERIODIC

/* Only relevant in PERIODIC mode. This is a poll() timeout in the
 * daemon's already-blocking loop, not a spawned timer thread/process
 * -- still 0% CPU between wakeups. */
#define USAGE_CHECK_INTERVAL_SEC 30

/* ==================================================================
 * MENU: appearance (shared verbatim mechanism with fmenu/filepicker;
 * these exact macro names are read directly by xmenu.c/fmenu.c) */

#define MENU_FONT   "JetBrainsMono Nerd Font:size=11"

#define MENU_COLOR_BG          "#1d2021"
#define MENU_COLOR_FG          "#ebdbb2"
#define MENU_COLOR_BORDER      "#458588"
#define MENU_COLOR_SELECT_BG   "#458588"
#define MENU_COLOR_SELECT_FG   "#1d2021"
#define MENU_COLOR_DISABLED_FG "#665c54"

#define MENU_BORDER_WIDTH   1
#define MENU_ITEM_PAD_X     14
#define MENU_ITEM_PAD_Y      6
#define MENU_MIN_WIDTH      160
#define MENU_MAX_WIDTH       380
#define MENU_CORNER_RADIUS    8

#define MENU_SUBMENU_ARROW      " \u25b8"
#define MENU_SUBMENU_ARROW_RTL  "\u25c2 "
#define MENU_SUBMENU_OVERLAP_X  2

#define MENU_RTL 0

#define MENU_POSITION_AT_POINTER  1
#define MENU_FIXED_X              20
#define MENU_FIXED_Y              20

#define FMENU_CENTERED          1
#define FMENU_WIDTH              480
#define FMENU_MAX_VISIBLE_ROWS   14
#define FMENU_PROMPT_ICON        "\uf002 "
#define FMENU_CHECK_ON           "[x] "
#define FMENU_CHECK_OFF          "[ ] "

/* filepicker.c (reused verbatim from the kdeconnect module, used here
 * for "Mount ISO"'s file browser) */
#define FILEPICKER_START_DIR    "~"
#define FILEPICKER_SHOW_HIDDEN  0
#define FILEPICKER_ICON_DIR     "\uf07b "
#define FILEPICKER_ICON_FILE    "\uf15b "
#define FILEPICKER_ICON_UP      "\uf148 "

/* ==================================================================
 * PER-DEVICE MENU: what fields are shown in the header/body, and
 * which action rows are offered. Every row independently toggleable,
 * same pattern as kdeconnect's SHOW_MENU_* switches. */

#define MENU_SHOW_DEVICE_NODE        1   /* e.g. /dev/sdb1 */
#define MENU_SHOW_UUID               1
#define MENU_SHOW_FILESYSTEM_TYPE    1   /* e.g. ext4, exfat, ntfs */
#define MENU_SHOW_MOUNT_POINT        1
#define MENU_SHOW_SYMLINK_TARGET     1   /* if a custom mount-point symlink is configured for this device, show both it and the real mount point -- see CHANGE MOUNT POINT below */
#define MENU_SHOW_USED               1
#define MENU_SHOW_FREE               1
#define MENU_SHOW_TOTAL              1
#define MENU_SHOW_PERCENT_USED       1
#define MENU_SHOW_DRIVE_MODEL        1
#define MENU_SHOW_CONNECTION_BUS     1

#define MENU_ACTION_MOUNT              1
#define MENU_ACTION_UNMOUNT            1
#define MENU_ACTION_EJECT              1   /* Drive.Eject -- spins down/unlocks tray, keeps USB power on */
#define MENU_ACTION_POWER_OFF          1   /* Drive.PowerOff -- also cuts power to the USB port; "safely remove" */
#define MENU_ACTION_OPEN_FILE_MANAGER  1
#define MENU_ACTION_CHANGE_MOUNT_POINT 1   /* see "CHANGE MOUNT POINT" section below -- symlink-based */
#define MENU_ACTION_COPY_MOUNT_PATH    1   /* copies the mount path to the X PRIMARY+CLIPBOARD selections */

/* Copying to the X clipboard properly means becoming the selection
 * owner and answering SelectionRequest events for as long as the
 * clipboard holds your text -- which means either staying resident
 * (a whole daemon, just for this) or accepting the text vanishes when
 * this short-lived process exits, unless something else (a clipboard
 * manager) has since taken a copy. The built-in fallback below holds
 * the selection for a few seconds after the click, which is enough
 * for one manual Ctrl+V and covers most clipboard managers' polling
 * interval too. Set this to an external command (e.g. "xclip
 * -selection clipboard", "wl-copy") instead if you'd rather it be
 * genuinely durable and don't mind the extra dependency; leave empty
 * for the built-in behavior. */
#define CLIPBOARD_EXTERNAL_CMD ""
#define CLIPBOARD_HOLD_SECONDS 5
#define MENU_ACTION_RELOAD             1   /* manual re-check of usage stats + bar re-render, no state mutation */
#define MENU_SHOW_CUSTOM_ENTRIES       1   /* master toggle for CUSTOM_DEVICE_MENU_ENTRIES below */

/* Appended to the bottom of every per-device menu. {NODE}, {ID}
 * (object path), {MOUNTPOINT}, {NAME} are substituted, then run via
 * execvp (spawned detached) -- no shell, so no pipes/$VARS/~. Point
 * at a script for anything fancier. */
typedef struct { const char *command_template; const char *label; } CustomMenuEntry;

static const CustomMenuEntry CUSTOM_DEVICE_MENU_ENTRIES[] = {
    /* { "/home/you/bin/backup-to.sh", "Run Backup Here" }, */
    { NULL, NULL } /* sentinel -- keep last */
};

/* Command used for "Open in File Manager". {MOUNTPOINT} is
 * substituted with the real (non-symlink) mount path, shell-quoted
 * for you. xdg-open respects your configured default file manager;
 * override with e.g. "nautilus" or "pcmanfm" directly if you'd rather
 * skip the xdg-open indirection. */
#define FILE_MANAGER_CMD "gio open '{MOUNTPOINT}'"

/* ==================================================================
 * CHANGE MOUNT POINT
 * ==================================================================
 * UDisks mounts removable filesystems under a path it controls
 * itself (typically /run/media/$USER/<label-or-uuid>), via polkit --
 * there's no supported way to hand it an arbitrary path per-mount,
 * short of an /etc/fstab entry (which defeats the point of a
 * plug-and-play external-disk module, and is explicitly off the table
 * on an immutable /etc like NixOS anyway).
 *
 * So "change mount point" here means: maintain a symlink at a path
 * you choose, pointing at UDisks' real mount point. The real mount
 * point is *always* shown alongside the symlink wherever the symlink
 * appears (menu header, JSON output) -- this is a convenience alias,
 * never a silent substitute, specifically so it's never ambiguous
 * which one is the actual mount. The symlink is created after mount
 * and removed before/after unmount automatically; selecting "Change
 * Mount Point" in the menu opens the file picker (filepicker.c) to
 * choose the *parent directory*, then prompts for a leaf name via the
 * same searchable-list widget (type a name, nothing needs to match,
 * Enter confirms the typed text). Mappings persist in
 * $XDG_CACHE_HOME/polybar-udisks/mount-links (state_file.c), keyed by
 * filesystem UUID so they survive reboots/replugs. */
#define ENABLE_MOUNT_POINT_SYMLINKS 1
#define SYMLINK_DEFAULT_PARENT_DIR  "~/Disks"

/* ==================================================================
 * SAFETY: dangerous actions never offered, regardless of any config
 * above or DEVICE_OVERRIDES -- this is intentionally NOT
 * configurable. A device is treated as protected if UDisks reports
 * HintSystem, or if its mount point is "/" or under one of these
 * prefixes. (Relevant on NixOS and any other setup where the root/
 * boot filesystem is a UDisks-visible device mounted at boot by
 * systemd, not by us -- we must never offer to unmount or power off
 * that, confirmation dialog or not.) */
static const char *PROTECTED_MOUNT_PREFIXES[] = {
    "/", "/boot", "/nix", "/home", "/var", "/usr", "/etc", NULL
};

/* ==================================================================
 * CONFIRMATION for actions that can lose data or drop power
 * mid-write. Rendered as a small Xlib yes/no popup (xmenu.c, no new
 * dependency) when on. */
#define CONFIRM_UNMOUNT         0
#define CONFIRM_FORCE_UNMOUNT   1
#define CONFIRM_EJECT           0
#define CONFIRM_POWER_OFF       1

/* ==================================================================
 * NOTIFICATIONS -- independent toggles, same pattern as kdeconnect's
 * four NOTIFY_ON_* switches. */
#define NOTIFY_ON_MOUNT_SUCCESS        1
#define NOTIFY_ON_MOUNT_FAILURE        1
#define NOTIFY_ON_UNMOUNT_SUCCESS      1
#define NOTIFY_ON_UNMOUNT_FAILURE      1
#define NOTIFY_ON_EJECT                1
#define NOTIFY_ON_POWER_OFF            1
#define NOTIFY_ON_DEVICE_CONNECTED     1   /* device appeared, not yet mounted */
#define NOTIFY_ON_DEVICE_DISCONNECTED  1   /* device physically removed */
#define NOTIFY_ON_LOW_SPACE            1   /* fires once per mount session when free space first crosses LOW_SPACE_THRESHOLD_PERCENT */

#define NOTIFY_APP_NAME   "Disks"
#define NOTIFY_ICON_NAME  "drive-removable-media"
#define NOTIFY_TIMEOUT_MS 5000

/* ==================================================================
 * GENERIC (non-device-specific) MENU
 * ==================================================================
 * Opened via `--generic-menu` (bind it to a click action, e.g.
 * NO_DEVICE_ACTION_1 or one of the POLYBAR_ACTION_* slots on a
 * separate always-visible bar module -- see README). Covers anything
 * that isn't "about one specific already-attached disk". */
#define ENABLE_GENERIC_MENU          1
#define GENERIC_MENU_SHOW_MOUNT_ISO  1
#define GENERIC_MENU_SHOW_UNMOUNT_ISOS 1  /* lists currently-loop-mounted ISOs with a Detach action for each */
#define GENERIC_MENU_SHOW_DISK_UTILITY 1
#define DISK_UTILITY_CMD "gnome-disks"    /* launched via execvp, no args */
#define GENERIC_MENU_SHOW_RELOAD_ALL 1
#define GENERIC_MENU_SHOW_CUSTOM_ENTRIES 1

static const CustomMenuEntry CUSTOM_GENERIC_MENU_ENTRIES[] = {
    /* { "/home/you/bin/open-file-manager.sh", "Open File Manager" }, */
    { NULL, NULL } /* sentinel -- keep last */
};

/* ==================================================================
 * JSON OUTPUT -- see README for the schema. No separate config knob
 * needed: `-j`/`--json` on the CLI selects it, same as kdeconnect. */

/* ==================================================================
 * DAEMON / D-BUS TIMING
 * ================================================================== */
#define DAEMON_DEBOUNCE_MS     150  /* coalesce a burst of PropertiesChanged/InterfacesAdded signals into one re-render */
#define DBUS_CALL_TIMEOUT_MS   4000 /* Mount/Unmount can involve polkit + actual device I/O -- longer than kdeconnect's 2000ms */

#endif /* CONFIG_H */
