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

/* Eject and Power Off act on the whole DRIVE, not just the partition
 * you clicked -- they fail with "device is busy" if *any* partition
 * on that drive is still mounted, including ones other than the row
 * you clicked (e.g. a USB stick with two partitions, only one
 * mounted). This controls what happens with those still-mounted
 * partitions before attempting Eject/Power Off:
 *   NONE   -- old behavior: just try, fail with "busy" if anything's
 *             still mounted, don't touch anything automatically.
 *   PROMPT -- ask (one confirmation dialog, listing what's mounted)
 *             before unmounting them and proceeding.
 *   ALWAYS -- unmount them automatically, no prompt, then proceed.
 * Applies to every partition sharing the same drive as the one you
 * clicked Eject/Power Off on, including that partition itself if it's
 * the one still mounted. */
#define EJECT_POWEROFF_UNMOUNT_NONE   0
#define EJECT_POWEROFF_UNMOUNT_PROMPT 1
#define EJECT_POWEROFF_UNMOUNT_ALWAYS 2
#define EJECT_POWEROFF_UNMOUNT_MODE EJECT_POWEROFF_UNMOUNT_PROMPT

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
#define FILE_MANAGER_CMD "hifile {MOUNTPOINT}"

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
 * ENCRYPTED (LUKS) CONTAINERS
 * ==================================================================
 * Unlocked via UDisks' own Encrypted interface (Unlock/Lock) -- same
 * D-Bus connection as everything else, no cryptsetup/libblockdev
 * dependency. A locked container shows as its own row (lock icon,
 * "Unlock" only). Once unlocked, the container row disappears and
 * the resulting cleartext filesystem takes its place as a normal
 * device row, with an added "Lock" action (which unmounts it first
 * if needed). */
#define ENABLE_LUKS 1

#define ICON_LUKS_LOCKED   "\uf023"  /*  closed padlock */
#define ICON_LUKS_UNLOCKED "\uf09c"  /*  open padlock -- combined with the normal device icon on the cleartext row */

#define MENU_ACTION_UNLOCK 1
#define MENU_ACTION_LOCK   1
#define CONFIRM_LOCK       0   /* locking is non-destructive (auto-unmounts first) so off by default, unlike CONFIRM_POWER_OFF */

#define NOTIFY_ON_UNLOCK_SUCCESS 1
#define NOTIFY_ON_UNLOCK_FAILURE 1
#define NOTIFY_ON_LOCK           1

/* Passphrase caching: kept ONLY in the kernel's per-UID user keyring
 * (add_key()/keyctl, see passphrase_cache.c) -- never written to
 * disk, never present in any config file, automatically gone once
 * you're fully logged out (no processes/open files left under your
 * UID). Global default plus per-device override, same matching rules
 * as DEVICE_OVERRIDES. "Forget Passphrase" in the device menu clears
 * a specific entry early if you don't want to wait for that. */
#define REMEMBER_PASSPHRASE_DEFAULT 1

typedef struct { const char *match; int remember; } PassphraseCacheOverride;
static const PassphraseCacheOverride PASSPHRASE_CACHE_OVERRIDES[] = {
    /* { "3A21-5F09", 0 }, */
    { NULL, 0 } /* sentinel -- keep last */
};

/* ==================================================================
 * MTP (Android / phones)
 * ==================================================================
 * Detection only is built-in (udev, watching for the ID_MTP_DEVICE=1
 * property set by the mtp-probe rule that ships with libmtp -- folded
 * into the daemon's existing poll() set, still 0% idle CPU). Actual
 * mounting is entirely handed off to an external command you choose
 * -- every in-house MTP mounting attempt (jmtpfs, then gvfs/gio) had
 * real problems on real hardware, so rather than a third in-house
 * attempt, this just runs whatever FUSE-based MTP tool you already
 * know works for your phone. */
#define ENABLE_MTP 1

#define ICON_PHONE_GENERIC   "\uf10b"
#define ICON_PHONE_MOUNTED   ""  /* "" -> falls back to ICON_PHONE_GENERIC */
#define ICON_PHONE_UNMOUNTED ""

#define MTP_COLOR_MODE COLOR_MODE_RAMP   /* reuses SPACE_RAMP/DEVICE_COLOR_CONSTANT/DEVICE_COLOR_UNMOUNTED from above -- MTP usage stats are best-effort (see README), not every phone reports them accurately */

/* The mount command. Split on whitespace into argv (so flags are
 * fine: "go-mtpfs -allow-other"), then the computed mount point (see
 * MTP_MOUNT_PARENT_DIR below) is appended as the final argument --
 * i.e. this actually runs `go-mtpfs ~/Phone/<device name>`. Whatever
 * you set here is expected to behave like an ordinary FUSE mount
 * tool given a mountpoint as its last argument: either it stays
 * running in the foreground for as long as the mount is active (like
 * go-mtpfs, the default -- confirmed to actually work, unlike every
 * MTP FUSE tool we tried before it) or it daemonizes to the
 * background after a successful mount (the libfuse default, e.g.
 * jmtpfs/simple-mtpfs) -- both are handled the same way on Unmount
 * (see MTP_UNMOUNT_CMD below), so switching tools never needs a code
 * change, just this line. */
#define MTP_MOUNT_CMD "go-mtpfs"

/* How long to wait for the mount to actually appear AND be answering
 * requests (checked via /proc/mounts plus a real directory read, not
 * just "is the process still alive" -- see mtp.c's
 * mount_is_functional() for why) before giving up and reporting
 * failure. Generous by default: the most common reason this takes a
 * while is the phone's own file-transfer permission prompt sitting
 * unanswered on its screen, not anything actually being slow. */
#define MTP_MOUNT_TIMEOUT_SEC 25

/* Parent directory for phone mounts -- a subdirectory named after the
 * device (sanitized vendor+model) is created and appended
 * automatically, e.g. "~/Phone/Xiaomi_Inc_Mi_Redmi_series". */
#define MTP_MOUNT_PARENT_DIR "~/Phone"

/* Unmounting always ends with `fusermount -u <mountpoint>` --
 * authoritative regardless of which tool mounted it or whether it
 * daemonized away from a PID we can still see, since it's a
 * kernel-level FUSE unmount request the serving process (whichever
 * one it turned out to be) can't ignore. Before that, if we still
 * have a live PID for the process we originally launched (true for
 * foreground tools like the go-mtpfs default; may just be an
 * already-exited PID for tools that daemonized, which is harmless --
 * the kill below simply no-ops), we SIGTERM it first, on the theory
 * that letting a well-behaved tool unmount itself cleanly is nicer
 * than yanking the mount out from under it. `fusermount -u` still
 * always runs afterward regardless of whether that worked. Same
 * two-step cleanup runs automatically if a phone is unplugged without
 * unmounting first (detected via udev), so nothing is ever left
 * dangling. */
#define MTP_UNMOUNT_FUSERMOUNT_CMD "fusermount"

#define CONFIRM_MTP_MOUNT   0
#define CONFIRM_MTP_UNMOUNT 0

#define MENU_SHOW_MTP_SERIAL 1
#define MENU_ACTION_MTP_MOUNT             1
#define MENU_ACTION_MTP_UNMOUNT           1
#define MENU_ACTION_MTP_OPEN_FILE_MANAGER 1
#define MENU_ACTION_MTP_COPY_MOUNT_PATH   1
#define MENU_ACTION_MTP_RELOAD            1

/* ---- Upload / Download (fmenu/filepicker-based file transfer) ---- */

#define MENU_ACTION_MTP_DOWNLOAD 1   /* phone -> PC */
#define MENU_ACTION_MTP_UPLOAD   1   /* PC -> phone */

/* Where the "pick a destination" browser starts for Download, and
 * where the "pick files to send" browser starts for Upload -- both
 * independent of the disk module's own FILEPICKER_START_DIR, since
 * this is specifically about phone transfers. */
#define MTP_TRANSFER_LOCAL_DIR "~"

/* What happens when a transferred file's name already exists at the
 * destination -- always asked interactively via a small popup
 * (Replace / Rename (numbered) / Skip / Cancel remaining), this just
 * controls whether that popup is skipped for a blanket default
 * instead. NONE = always ask (default). */
#define MTP_CONFLICT_ASK    0
#define MTP_CONFLICT_ALWAYS_REPLACE 1
#define MTP_CONFLICT_ALWAYS_RENAME  2
#define MTP_CONFLICT_ALWAYS_SKIP    3
#define MTP_CONFLICT_MODE MTP_CONFLICT_ASK

#define NOTIFY_ON_MTP_TRANSFER_COMPLETE 1

/* ---- scrcpy (screen mirroring) ---- */

#define MTP_AUTO_SPAWN_SCRCPY 1   /* launch scrcpy automatically whenever a phone is detected (not just mounted -- scrcpy doesn't need an MTP mount at all) */
#define SCRCPY_CMD "scrcpy"       /* split on whitespace into argv, same convention as MTP_MOUNT_CMD; add your own flags here, e.g. "scrcpy --turn-screen-off --stay-awake" */
#define MENU_ACTION_MTP_SCRCPY_TOGGLE 1   /* "Run scrcpy" / "Stop scrcpy" in the Android menu, depending on whether it's currently running for this device */

static const CustomMenuEntry CUSTOM_MTP_MENU_ENTRIES[] = {
    /* { "/home/you/bin/sync-photos.sh", "Sync Photos" }, */
    { NULL, NULL } /* sentinel -- keep last */
};

/* Click actions for a phone's bar segment -- same placeholder/slot
 * convention as POLYBAR_ACTION_1..5 above. {ID} here is the phone's
 * serial (or "busnum:devnum" if the device didn't report one). Empty
 * slot 1 defaults to opening the phone's action menu. */
#define POLYBAR_MTP_ACTION_1  ""   /* empty = default: {SELF} --mtp -i {ID} -m */
#define POLYBAR_MTP_ACTION_2  ""
#define POLYBAR_MTP_ACTION_3  ""
#define POLYBAR_MTP_ACTION_4  ""
#define POLYBAR_MTP_ACTION_5  ""

#define NOTIFY_ON_MTP_MOUNT_SUCCESS   1
#define NOTIFY_ON_MTP_MOUNT_FAILURE   1
#define NOTIFY_ON_MTP_UNMOUNT_SUCCESS 1
#define NOTIFY_ON_MTP_ATTACHED        1  /* phone detected but not yet mounted -- no automount for MTP: MTP is too slow/quirky for a surprise background mount, always a manual click */

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
 * MOUNTED ISOs IN THE BAR
 * ==================================================================
 * An ISO/image you mount via "Mount ISO / Image..." can optionally
 * get its own bar segment and dedicated menu, same idea as a regular
 * disk -- separate from the generic menu's "Detach ISO..." list
 * (which still exists regardless of this, and still shows every
 * loop-mounted image, tracked or not). Only images mounted through
 * this module's own "Mount ISO" are ever shown here: a typical
 * desktop already has many unrelated /dev/loopN devices in
 * background use (snap packages, flatpak runtimes, squashfs images),
 * and showing all of them would flood the bar -- this module tracks
 * which loop devices it created itself ($XDG_CACHE_HOME/polybar-udisks
 * /iso-loops) specifically to be able to tell the difference. */
#define SHOW_MOUNTED_ISOS_IN_BAR 1

#define ICON_ISO_MOUNTED "\uf1c9"

/* ISOs don't have a meaningful "free space" the way a real disk does
 * (an ISO is effectively always full) -- so no ramp, just one flat
 * color, and no low-space warning icon in the bar for these rows.
 * (This only affects the bar segment -- the dedicated ISO menu still
 * shows used/free/total, since that's about the *mounted filesystem*
 * you're browsing, not the image file itself, and can still be
 * useful there, e.g. for a writable UDF image.) */
#define COLOR_ISO "#83a598"

#define MENU_SHOW_ISO_BACKING_FILE  1
#define MENU_SHOW_ISO_MOUNT_POINT   1
#define MENU_SHOW_ISO_USED          1
#define MENU_SHOW_ISO_FREE          1
#define MENU_SHOW_ISO_TOTAL         1

#define MENU_ACTION_ISO_OPEN_FILE_MANAGER 1
#define MENU_ACTION_ISO_COPY_MOUNT_PATH   1
#define MENU_ACTION_ISO_DETACH            1   /* unmounts + deletes the loop device -- the ISO equivalent of Unmount/Eject/Power Off combined, since there's no drive to separately eject or power off */
#define MENU_ACTION_ISO_RELOAD            1
#define CONFIRM_ISO_DETACH                1   /* non-destructive (it's read-only media you can just remount), off by default unlike CONFIRM_POWER_OFF */

static const CustomMenuEntry CUSTOM_ISO_MENU_ENTRIES[] = {
    /* { "/home/you/bin/verify-checksum.sh", "Verify Checksum" }, */
    { NULL, NULL } /* sentinel -- keep last */
};

/* Click actions for an ISO's bar segment -- same convention as
 * POLYBAR_ACTION_1..5. Empty slot 1 defaults to opening the ISO's
 * dedicated menu. */
#define POLYBAR_ISO_ACTION_1  ""   /* empty = default: {SELF} --iso -i {ID} -m */
#define POLYBAR_ISO_ACTION_2  ""
#define POLYBAR_ISO_ACTION_3  ""
#define POLYBAR_ISO_ACTION_4  ""
#define POLYBAR_ISO_ACTION_5  ""

/* ==================================================================
 * JSON OUTPUT -- see README for the schema. No separate config knob
 * needed: `-j`/`--json` on the CLI selects it, same as kdeconnect. */

/* ==================================================================
 * DAEMON / D-BUS TIMING
 * ================================================================== */
#define DAEMON_DEBOUNCE_MS     150  /* coalesce a burst of PropertiesChanged/InterfacesAdded signals into one re-render */
#define DBUS_CALL_TIMEOUT_MS   4000 /* Mount/Unmount can involve polkit + actual device I/O -- longer than kdeconnect's 2000ms */

#endif /* CONFIG_H */
