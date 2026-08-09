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
symlinks, ISO mounting). Round 2 added LUKS unlock/lock and Android
(MTP) support -- see their own sections below.

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

Needs `dbus-1`, `x11`, `xft`, `xext`, `libudev`, and `keyutils` dev
packages. On NixOS, something like:

```nix
buildInputs = [ dbus xorg.libX11 xorg.libXft xorg.libXext systemd keyutils ];
nativeBuildInputs = [ pkg-config ];
```

Two optional runtime tools, needed only for the features they enable:
`gio` (part of the `glib`/`gvfs` toolchain -- practically always
already present on any Linux desktop) plus the `gvfs` package with its
D-Bus service active for phone mounting, and a notification daemon
(dunst, mako, etc) if you want `NOTIFY_ON_*` to do anything. Neither
is required to build or to use the disk-management features.

Running it needs `udisks2` and `polkit` active (they almost certainly
already are on NixOS -- `services.udisks2.enable = true;` is the
relevant option, on by default on most desktop configs).

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
polybar-udisks --mtp -m [-i ID]         open a phone's action menu
                                          (ID is a serial, or "bus:dev";
                                          omit -i if exactly one phone is attached)
polybar-udisks --iso -m -i ID           open a mounted ISO's action menu
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

**Eject/Power Off and sibling partitions:** both act on the whole
drive, not just the partition you clicked -- UDisks fails them with
"busy" if *any* partition on that drive is still mounted, including
ones other than the row you clicked (a USB stick with two partitions,
only one mounted, is enough to trigger this). `EJECT_POWEROFF_UNMOUNT_MODE`
controls what happens with those before attempting Eject/Power Off:
`NONE` (old behavior -- just try, fail if busy), `PROMPT` (default --
one confirmation dialog listing what's still mounted, then unmount and
proceed), or `ALWAYS` (unmount everything on that drive silently, no
prompt, then proceed).

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

## ISO / image mounting

"Mount ISO / Image..." (generic menu) opens the same searchable
file-browser widget kdeconnect's `--send-file` uses, attaches the
chosen file as a loop device via UDisks' `Manager.LoopSetup`, and
mounts it read-only. Handles both plain ISO9660/UDF images (the loop
device itself gets the mountable filesystem) and hybrid/bootable ISOs
-- common for Linux distro install media, meant to be `dd`'d to a USB
stick and booted -- where UDisks instead exposes the filesystem on a
*partition* of the loop device because of the embedded MBR/GPT table;
this is detected and mounted automatically either way.

**Mounted ISOs get their own bar segment and dedicated menu**
(`SHOW_MOUNTED_ISOS_IN_BAR`, on by default) -- Open in File Manager,
Copy Mount Path, Detach, Reload, custom entries
(`CUSTOM_ISO_MENU_ENTRIES`), reachable via `--iso -m -i ID` (same
click-action convention as everything else). Only images mounted
*through this module* ever show up this way: a typical desktop already
has plenty of unrelated `/dev/loopN` devices in background use (snap
packages, flatpak runtimes, squashfs images), and showing all of them
would flood the bar with noise nobody wants -- this module tracks
which loop devices it created itself
(`$XDG_CACHE_HOME/polybar-udisks/iso-loops`) specifically to be able
to tell the difference.

The generic menu's "Detach ISO..." list is still there regardless of
`SHOW_MOUNTED_ISOS_IN_BAR`, and still shows *every* loop-mounted image
system-wide, tracked by this module or not (UDisks itself doesn't
distinguish) -- useful as a catch-all cleanup tool, or if you'd rather
not have ISOs in the bar at all. Either detach path unmounts the loop
device and/or its partition (whichever applies) then deletes the loop
device.

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

`-j`/`--json` with `-d` or `--daemon` prints a JSON array instead of
polybar markup -- one line per invocation/render, same convention as
the kdeconnect module. Every object has a `"kind"` field -- `"disk"`,
`"iso"`, or `"phone"` -- since the array holds all three. ISO objects
reuse the same shape as disk objects (most disk-specific fields like
`uuid`/`ejectable`/`drive_vendor` just come back empty/false for
them); `name` is the image's filename.

Disk/ISO fields: `id`, `name`, `node`, `label`, `uuid`, `fs_type`,
`external`, `removable`, `mounted`, `mount_point`, `symlink`,
`read_only`, `protected`, `ejectable`, `can_power_off`, `encrypted`,
`locked`, `size_bytes`, `usage_valid`, `used_bytes`, `free_bytes`,
`total_bytes`, `percent_used`, `drive_vendor`, `drive_model`,
`connection_bus`, `color`.

Phone fields: `id` (serial, or "bus:dev"), `name`, `serial`, `vendor`,
`model`, `mounted`, `mount_point`, `usage_valid`, `used_bytes`,
`free_bytes`, `total_bytes`, `percent_used`, `color`.

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

## LUKS unlock/lock

Locked LUKS containers show as their own row (lock icon, "Unlock"
only, no size/usage stats). Unlocking calls UDisks' own `Encrypted`
interface (`Unlock`/`Lock`) over the same D-Bus connection as
everything else -- no `cryptsetup`/libblockdev dependency. Once
unlocked, the container's row disappears and the resulting cleartext
filesystem takes its place as an ordinary device row (mount/unmount/
usage/etc all work exactly like any other disk), with an added "Lock"
action that unmounts it first if needed.

**Passphrase entry** reuses the same modal text box as "Change Mount
Point" (`xinput.c`), in password mode (masked with bullets).
**Caching** lives *only* in the kernel's per-UID user keyring
(`add_key`/`request_key`/`keyctl_read_alloc`/`keyctl_revoke` --
`passphrase_cache.c`) -- never written to disk, never in a config
file, gone once you're fully logged out. (Deliberately the *user*
keyring rather than the *session* keyring: the session keyring only
persists if your login went through PAM's `pam_keyinit`, which plenty
of setups -- bare `startx`/`xinit`, many minimal WM configs -- never
do; without it, each of this module's short-lived one-shot processes
would get its own throwaway session keyring destroyed the instant it
exits, so caching would silently do nothing. The user keyring needs no
such setup.) `REMEMBER_PASSPHRASE_DEFAULT` is on by default, with
per-device overrides in `PASSPHRASE_CACHE_OVERRIDES`; "Forget Cached
Passphrase" clears one early without waiting to log out. If a cached
passphrase gets rejected (e.g. you changed it outside this tool),
it's dropped automatically and you're prompted fresh.

`CONFIRM_LOCK` (off by default -- locking is non-destructive, it
unmounts cleanly first) and `MENU_ACTION_UNLOCK`/`MENU_ACTION_LOCK`
toggle the feature as usual. `ENABLE_LUKS 0` disables it entirely and
reverts to Round 1 behavior (locked containers filtered out, same as
any other device with no `Filesystem` interface).

**Other encryption formats:** this doesn't hardcode LUKS specifically
-- it reacts to UDisks' generic `Encrypted` interface, which UDisks
populates for whatever its `cryptsetup` can auto-probe via `blkid`.
That already covers LUKS1/LUKS2 always, and on a reasonably modern
`cryptsetup`/`udisks2` (which NixOS will have), **BitLocker (BITLK)**
removable drives too -- should unlock through the exact same code
path with zero changes here. VeraCrypt/TrueCrypt volumes are a
different story: they deliberately have no on-disk signature (the
whole point is plausible deniability), so UDisks can't and won't
auto-detect them at all. Supporting those would mean a dedicated
feature shelling out to the `veracrypt` CLI directly -- not
implemented yet, see "What's next" below.

## Android / MTP

No glib/gio, no libmtp linked into this binary -- we shell out to the
`gio` CLI (same category of dependency as `xdg-open`, not a library
link). Two pieces:

- **Detection**: a `libudev` monitor (folded into the daemon's
  existing `poll()` set -- one more fd, still 0% idle CPU) watching
  for USB devices carrying the `ID_MTP_DEVICE=1` property. That
  property is set by the `mtp-probe` udev rule that ships with
  `libmtp`.
- **Mounting**: `gio mount mtp://[usb:BUS,DEV]/`, using gvfs's MTP
  backend -- actively maintained (part of freedesktop.org/GNOME,
  regular releases; the same code GNOME Files uses for Android
  transfers every day) and genuinely bidirectional. `gio mount` alone
  only creates a *virtual* GIO mount; what makes it usable from `cp`/
  `rsync`/any non-GIO program is gvfs's own FUSE bridge
  (`gvfsd-fuse`, part of the same `gvfs` package), which mirrors it as
  a real POSIX path under `$XDG_RUNTIME_DIR/gvfs/mtp:host=...` --
  this module locates that path (trying the known naming convention
  first, then falling back to diffing the directory listing for a few
  seconds in case gvfsd-fuse needs a moment) and treats it as the
  phone's mount point everywhere else. Unmounting is `gio mount -u`.

This replaced an earlier `jmtpfs`-based approach -- essentially
unmaintained, and its phone-to-PC-only transfer limitation turned out
to be a real, long-standing bug in the tool itself, not something
fixable from our side. gvfs doesn't have that problem.

**Requires the `gvfs` package with its D-Bus service active** -- on
NixOS, `services.gvfs.enable = true;`. `gio` itself should already be
present (it ships with `glib`, which is on virtually every Linux
desktop already). If mounting fails immediately with a "command not
found"-style error even though `gio` works fine in a terminal, the
process this module was launched from (often polybar itself) likely
has a minimal `PATH` that doesn't include it -- set `GIO_CMD` in
`config.h` to its absolute path (`which gio` in a normal terminal)
and rebuild. Failure notifications now include gio's actual error
output, not a guess, which should make any other failure mode
self-explanatory too.

Phones appear as their own bar segments (after disks, same
`SEPARATOR`) and get their own menu: Mount, Unmount, Open in File
Manager, Copy Mount Path, Reload, custom entries
(`CUSTOM_MTP_MENU_ENTRIES`).

A few things worth knowing:

- **No automount for MTP, ever** -- MTP is slow and occasionally flaky
  to enumerate depending on the phone/Android skin; a background
  automount on every phone unlock/screen-on would be more annoying
  than useful. Always a manual click.
- **Usage stats are best-effort.** `statvfs()` on the FUSE mount works
  for many phones, but some MTP stacks under-report or don't implement
  it at all -- the menu just shows "unavailable" rather than a wrong
  number in that case.
- Multiple phones attached at once are disambiguated by USB bus/device
  number (built into the `mtp://[usb:...]/` URI), so two phones won't
  collide.
- `ENABLE_MTP 0` disables the whole feature (no udev monitor opened,
  no phone rows, `mtp.c`'s functions become no-ops).

## What's next (not in this round)

- Real render-dedup in daemon mode (currently reprints on every
  periodic usage-check tick even if the numbers came out identical --
  harmless with polybar's `tail = true`, just a very slightly noisier
  log/pipe than strictly necessary).
- VeraCrypt/TrueCrypt volume support (UDisks can't auto-detect these
  by design -- no on-disk signature -- so it'd mean a dedicated
  feature shelling out to the `veracrypt` CLI directly, similar in
  spirit to how MTP works).

Let me know what to tackle first.
