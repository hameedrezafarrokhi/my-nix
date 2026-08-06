# polybar-udisks (pure C, X11 menus, no udiskie)

A removable-disk status/control widget for polybar. Talks to UDisks2
directly over D-Bus (system bus, raw libdbus -- no glib/gio), draws its
own popup menus with Xlib + Xft (the same widgets from
polybar-kdeconnect), and runs as a signal-driven daemon for genuinely
0% idle CPU. No udiskie, no udiskie tray icon, no `pmount`/`udisksctl`
shelling out.

This is Round 1: the core disk-management path end to end (discovery,
filtering, mount/unmount/eject/power-off, usage checking, colors,
menus, notifications, confirmation, automount, custom mount-point
symlinks, ISO mounting). Two things were deliberately deferred to a
later round, per our conversation:

- **MTP (phones/Android via gvfs)** -- not implemented yet.
- **LUKS-encrypted external drives** -- currently filtered out
  entirely (see "What's filtered out" below), same as loop/zram
  devices. Unlocking would mean a passphrase-entry dialog plus a fair
  bit of state tracking for the resulting cleartext device; wanted to
  get the core path solid first.

UDisks2 itself is still the thing doing the actual mounting -- we
decided against reinventing that layer (its own README explains why:
https://www.freedesktop.org/wiki/Software/udisks/). This module only
replaces udiskie: the automount daemon, the tray icon, and the
mount/unmount decision-making.

## Build & install

```sh
make
make install    # copies to ~/.local/bin/polybar-udisks (override with PREFIX=)
```

Needs `dbus-1`, `x11`, `xft`, `xext` dev packages (same as
polybar-kdeconnect). On NixOS, something like:

```nix
buildInputs = [ dbus xorg.libX11 xorg.libXft xorg.libXext ];
nativeBuildInputs = [ pkg-config ];
```

Running it needs `udisks2` and `polkit` active (they almost certainly
already are on NixOS -- `services.udisks2.enable = true;` is the
relevant option, on by default on most desktop configs) and a
notification daemon if you want `NOTIFY_ON_*` to do anything (dunst,
mako, etc -- optional).

**Permissions:** UDisks' own polkit rules already allow the active
local session user to mount/unmount/eject/power-off *removable* media
without a password prompt. That's exactly the population this module
targets by default (`SHOW_INTERNAL_DEVICES 0`), so you shouldn't need
any custom polkit rules. If you turn on `SHOW_INTERNAL_DEVICES` and
point it at something UDisks doesn't consider removable, you may get a
polkit auth prompt (or a permission-denied error surfaced via a
notification) -- that's UDisks/polkit's policy, not something this
module can or should override.

## Rebuild after editing config.h

Like the kdeconnect module, everything configurable lives in
`config.h` as `#define`s and small static tables -- edit it, then
`make && make install`. No separate config file is read at runtime.

## Polybar setup

Two script modules, one for the disk list and one for a persistent
"generic" menu launcher (mount ISO, disk utility, etc) if you want one
-- entirely optional, `--generic-menu` also works fine bound to a
keybinding instead via `polybar-msg` or your WM's keybind system:

```ini
[module/udisks]
type = custom/script
exec = ~/.local/bin/polybar-udisks -d
tail = false
interval = 15
; or, for genuinely 0% idle CPU instead of a 15s poll:
; exec = ~/.local/bin/polybar-udisks --daemon
; tail = true
click-left = ~/.local/bin/polybar-udisks -i "%output%" -m   ; see note below
format-prefix = ""

[module/udisks-menu]
type = custom/text
content = "\uf0a0"
click-left = ~/.local/bin/polybar-udisks --generic-menu
```

The per-device click action is actually simpler than the ini snippet
above suggests: `config.h`'s `POLYBAR_ACTION_1` default already
expands to `{SELF} -i {ID} -m` and is baked directly into each
device's `%{A1:...:}` wrapper in the bar text itself (this is exactly
how the kdeconnect module's action buttons work) -- polybar doesn't
need a module-level `click-left` at all for that. `-d`/`--daemon`
alone is normally all your polybar config needs; clicking a specific
device segment is handled by the embedded action, not by polybar.

## CLI

```
polybar-udisks --daemon [-j]           run persistent daemon (0% idle CPU, tail=true)
polybar-udisks -d [-j]                 print module text once and exit (for interval-based polling)
polybar-udisks -m [-i ID]               open a device's action menu
                                          (uses whichever device menu was opened
                                          most recently if -i is omitted, or the
                                          only device if exactly one is attached)
polybar-udisks --generic-menu           open the non-device menu

  -j / --json          print JSON instead of polybar markup (-d/--daemon)
  --at-pointer         open a menu at the current pointer position
  --x N / --y N        open a menu at a fixed position
```

`ID` is a device's UDisks object path -- you'll never type this by
hand, it's what `{ID}` expands to in the generated click actions.

## What gets shown, by default

Only external/removable devices with a recognized filesystem:
`SHOW_INTERNAL_DEVICES 0`, classified via `EXTERNAL_BUS_LIST` (usb,
sdio, mmc, ieee1394 by default) plus UDisks' own `Removable` flag,
and never anything UDisks itself flags `HintSystem`. Flip
`SHOW_INTERNAL_DEVICES` on if you want your internal drives listed
too -- **unmount/eject/power-off are still refused for anything whose
mount point is `/`, `/boot`, `/nix`, `/home`, `/var`, `/usr`, or `/etc`
(see `PROTECTED_MOUNT_PREFIXES`), or that UDisks flags `HintSystem`,
regardless of that setting and regardless of `DEVICE_OVERRIDES` --
this is intentionally not configurable.** That's specifically for
setups like yours where the root/boot/nix store filesystems are
UDisks-visible devices mounted at boot by systemd, not by us; there's
no legitimate reason for a polybar click to ever be able to unmount
`/nix`.

### What's filtered out (not shown at all, regardless of internal/external)

- Loop devices (`/dev/loopN`) and zram -- noisy, not "disks" in the
  relevant sense. ISOs you mount via this module's own "Mount ISO"
  feature are managed through the generic menu's "Detach ISO" list
  instead of appearing as bar segments.
- Anything without a UDisks `Filesystem` interface at all: extended
  partitions, empty/unpartitioned space, swap, and (for now) locked
  LUKS containers -- see the deferred-features note above.
- Anything matching `HIDDEN_DEVICES` (by UUID/label/node/serial
  substring) or under `FILTER_MIN_SIZE_BYTES`.

## Usage checking (the "ballpark, not exact bytes" part)

`statvfs()` on the mount point -- reads cached superblock stats the
kernel already has, no directory walk, no real I/O, effectively free
even for a spinning disk. `USAGE_CHECK_MODE_PERIODIC` (default) also
re-checks every `USAGE_CHECK_INTERVAL_SEC` (default 30s) as a bounded
`poll()` timeout in the daemon's already-blocking loop -- not a
spawned timer thread, still 0% CPU between wakeups.

"Reload" (per-device menu row, or the generic menu's "Reload" row)
signals the running `--daemon` process (`SIGUSR1`, via a small PID
file) to re-check and re-render immediately, instead of waiting for
the next timer tick. Does nothing if you're using `-d`/interval mode
instead of `--daemon` -- there's no persistent process to signal, and
the next scheduled `-d` invocation will pick up current numbers
anyway.

## Change Mount Point (symlinks, not real remounts)

UDisks mounts removable filesystems wherever *it* decides (typically
`/run/media/$USER/<label-or-uuid>`) via polkit; there's no supported
way to hand it an arbitrary path per-mount short of an `/etc/fstab`
entry, which is off the table both in general (defeats plug-and-play)
and specifically on NixOS (`/etc` isn't something this module should
be writing to, full stop).

So "Change Mount Point" creates/updates a **symlink** you name,
pointing at UDisks' real mount point -- recreated automatically every
time that device gets mounted again (mappings persist by filesystem
UUID in `$XDG_CACHE_HOME/polybar-udisks/mount-links`, survive
reboots/replugs), and removed automatically on unmount. The real
mount point is always shown alongside the symlink in the device menu
(`MENU_SHOW_SYMLINK_TARGET`) so it's never ambiguous which one is the
actual mount. "Remove Custom Mount Point" clears the mapping.

## Safety / confirmation

`CONFIRM_UNMOUNT`, `CONFIRM_FORCE_UNMOUNT`, `CONFIRM_EJECT`,
`CONFIRM_POWER_OFF` in `config.h` -- each independently toggleable,
each renders as a small Xlib yes/no popup (no `zenity`/GTK dependency,
reuses the same menu widget as everything else). If a plain unmount
fails (device busy), you're offered a force-unmount confirmation
regardless of `CONFIRM_UNMOUNT`'s setting, since that's specifically
the case where blindly retrying with `force` is the actual
data-loss-risk moment.

The protected-mount-prefix / `HintSystem` check described above is
**not** part of this configurable confirmation system -- it's a hard
filter on which menu rows even appear, checked before any
confirmation dialog would run.

## Notifications

Nine independent `NOTIFY_ON_*` toggles (mount/unmount success and
failure, eject, power-off, device connected/disconnected, low space).
Sent via a direct D-Bus call to `org.freedesktop.Notifications` (same
approach as kdeconnect's `notify.c`) -- needs a running notification
daemon, silently no-ops if there isn't one.

## Copy Mount Path (clipboard, no xclip dependency by default)

Becoming the X clipboard owner properly means answering
`SelectionRequest` events for as long as the clipboard holds your
text, which means either staying resident just for that, or accepting
the text is only available for a short window after this (short-lived,
one-shot) process exits. The built-in default holds the selection for
`CLIPBOARD_HOLD_SECONDS` (5s) after the click -- enough for one manual
paste, and most clipboard managers poll faster than that and will pick
it up permanently. Set `CLIPBOARD_EXTERNAL_CMD` to e.g. `"xclip
-selection clipboard"` or `"wl-copy"` instead if you want it genuinely
durable and don't mind the extra dependency.

## Automount

Off by default (`AUTOMOUNT_GLOBAL_DEFAULT 0`), per-device overrides in
`AUTOMOUNT_OVERRIDES`. Only fires in `--daemon` mode, and only once
per physical attachment -- manually unmounting an automounted device
doesn't cause it to immediately remount itself; unplugging and
replugging it does re-arm automount for that attachment, as expected.
A one-shot `-d` invocation never automounts anything as a side effect
of printing bar text.

## ISO / image mounting (generic menu)

"Mount ISO / Image..." opens the same searchable file-browser widget
kdeconnect's `--send-file` uses, attaches the chosen file as a loop
device via UDisks' `Manager.LoopSetup`, and mounts it read-only.
"Detach ISO..." lists everything currently loop-mounted through this
module (or anything else visible as a loop device, honestly -- UDisks
doesn't distinguish) with a Detach action for each, which unmounts
then deletes the loop device.

## Icons, colors, bar fields, menu fields

All independently toggleable in `config.h` -- see the comments there,
it's the source of truth and kept current, deliberately not
duplicated in more detail here. Short version: per-device icon/color/
name overrides (`DEVICE_OVERRIDES`, matched by UUID/label/node/
serial), a free-space color ramp or a flat constant color
(`DEVICE_COLOR_MODE`), and independent show/hide toggles for name,
used/free/total/percent in both the bar (`BAR_SHOW_*`) and the menu
(`MENU_SHOW_*`).

## JSON output

`-j`/`--json` with `-d` or `--daemon` prints a JSON array (one object
per device) instead of polybar markup -- one line per invocation/
render, same convention as the kdeconnect module. Fields: `id`,
`name`, `node`, `label`, `uuid`, `fs_type`, `external`, `removable`,
`mounted`, `mount_point`, `symlink`, `read_only`, `protected`,
`ejectable`, `can_power_off`, `size_bytes`, `usage_valid`,
`used_bytes`, `free_bytes`, `total_bytes`, `percent_used`,
`drive_vendor`, `drive_model`, `connection_bus`, `color`.

## Custom menu entries

`CUSTOM_DEVICE_MENU_ENTRIES` (per-device menu) and
`CUSTOM_GENERIC_MENU_ENTRIES` (generic menu) in `config.h`, same shape
as kdeconnect's: `{SELF} {ID} {NODE} {NAME} {MOUNTPOINT}` placeholders,
run via `execvp` after simple whitespace splitting -- no shell, so no
`$VARS`/`~`/pipes, and (unlike the polybar click-action templates,
which are shell-quoted since polybar runs those through a shell) no
support for spaces inside a substituted value either. Point at a
wrapper script for anything fancier than a plain command + one
placeholder.

## What's next (not in this round)

- MTP/gvfs support for phones.
- LUKS unlock/lock for encrypted external drives (currently just
  hidden, same as any other device with no `Filesystem` interface).
- Real render-dedup in daemon mode (currently reprints on every
  periodic usage-check tick even if the numbers came out identical --
  harmless with polybar's `tail = true`, just a very slightly noisier
  log/pipe than strictly necessary).

Let me know what to tackle first.
