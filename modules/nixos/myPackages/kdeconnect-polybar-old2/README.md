# polybar-kdeconnect (pure C, X11 menus, no rofi/zenity/qdbus)

A KDE Connect status/control widget for polybar. Talks to KDE Connect
directly over D-Bus (no `qdbus`), draws its own popup menus with Xlib
+ Xft (no `rofi`), has its own searchable file picker (no `zenity`),
and runs as a signal-driven daemon for genuinely 0% idle CPU.

## Latest round

### Corner rounding: smoother alignment

The border and inner content were being rounded with two *different*
circle algorithms (`XFillArc` for the fill vs. the row-based math used
for the window's clipped shape), which left them very slightly
misaligned -- that mismatch, not just plain non-anti-aliased pixels,
is what made corners look jagged. Both now use the identical per-row
formula, so the fill and the actual clipped window shape line up
exactly. This is the "simple fix" -- true anti-aliased smoothing would
need an XRender-based fractional-coverage mask, which is a much bigger
undertaking and out of scope per your call.

### Signal strength: menu only, never the bar

Removed entirely from the polybar module (confirmed dead code -- it
never worked there, which is exactly why you never saw it; not worth
chasing further since it doesn't belong there anyway). In the `-m`
menu, the header is now two rows instead of one: `NAME — Battery: X%`
on its own line, `Signal: Y/4` on the line below (only shown if the
device actually reports a signal, and only at all if
`SHOW_SIGNAL_STRENGTH` in `config.h` is on).

### Bar module: device name + configurable spacing

- `SHOW_DEVICE_NAME_DEFAULT` (config.h) / `--show-name` (CLI,
  overrides the default either way) prints the device name between
  the icon and the battery percentage. `DEVICE_NAME_MAX_CHARS` caps
  it (UTF-8-character-safe truncation with `DEVICE_NAME_TRUNCATE_SUFFIX`
  appended); `0` means no limit.
- `ICON_NAME_SPACING_PX` / `NAME_BATTERY_SPACING_PX` control the gap
  between segments using polybar's `%{O<px>}` pixel-offset tag --
  exact regardless of bar font/size, unlike padding with literal
  spaces.
- Font size per segment isn't done, as agreed -- polybar only lets you
  switch between pre-configured `font-N` slots by index, not set an
  arbitrary literal point size from a module script, so it would've
  required you to also hand-configure matching `font-N` entries in
  your bar config to mean anything. Not worth the indirection for what
  you asked for.
- **One visible side effect worth knowing about**: since spacing is
  now handled uniformly via `%{O}` tags instead of a hardcoded literal
  space character, this changes *how* the icon-to-percentage gap is
  produced even when the device name is off and only `-b` is used --
  same visual result (icon, gap, number), different mechanism
  underneath. Nothing else about the default battery-percent display
  changed.

### A2-A5: configurable polybar click actions

`POLYBAR_ACTION_1` through `POLYBAR_ACTION_5` in `config.h` (buttons
1=left, 2=middle, 3=right, 4=scroll up, 5=scroll down). Every slot
defaults to `""` (unbound) **except slot 1**, where `""` specifically
means "fall back to the built-in default" (open the `-m` action menu)
-- that's what keeps every existing setup working unmodified with zero
config changes. `{SELF}`/`{ID}`/`{NAME}` placeholders are available in
custom templates; you're responsible for your own shell-quoting in
them, the same way the built-in default quotes `{NAME}` itself.

### "Nothing connected" icon (opt-in)

Blank stays the default when zero devices are known to KDE Connect at
all. `SHOW_ICON_WHEN_NO_DEVICES` (off by default) plus
`ICON_NO_DEVICES`/`COLOR_NO_DEVICES` let you show something instead if
you'd rather not have a blank module.

## This round's fixes and additions

### Bug fixes

1. **The `-b` flag silently getting eaten by `--daemon`.** Root cause:
   the previous version hand-rolled long-option parsing (a manual
   pre-scan for `"--daemon"` before calling plain `getopt()`), and
   plain `getopt()` doesn't understand `--`-prefixed tokens -- it
   scans them character-by-character as clustered short options. That
   meant `--daemon` got misread as `-d`, then `-m`, then `-n` (with
   the *next* argv token, e.g. `-b`, silently consumed as `-n`'s
   argument!). Rewrote argument parsing to use `getopt_long()`
   properly, which matches `--`-prefixed tokens against a real
   long-options table instead of character-scanning them. This is a
   real fix, not a workaround -- the failure mode is gone, not masked.

2. **`-m`/`-p` crashing with `BadMatch` on `X_CreateWindow`.** You
   correctly identified this predates the ARGB-visual experiment I'd
   added in response to the picom corner issue. That experiment is
   fully reverted -- windows are back to the plain default X11 visual
   they always used. I also removed the `WM_CLASS`/
   `_NET_WM_WINDOW_TYPE` hint-setting code from the same round, since
   I can't fully rule it out as a contributor and it's no longer
   needed now that corners are self-drawn (below). If this crash
   persists after rebuilding, it's something else entirely and I'd
   want a fresh backtrace/error to chase it further.

3. **`isTrusted` doesn't exist; real property is `isPaired`.** This
   was the root cause of the "always yellow, no battery %, `-m` says
   no device connected" bug from a couple rounds back -- confirmed
   against your `qdbus` introspection dump and already fixed. Also
   fixed in the same pass: `hasPairingRequests` → `isPairRequestedByPeer`,
   `requestPair` → `requestPairing`, `rejectPairing` (doesn't exist) →
   `cancelPairing`, and `connectivity_report`'s real (much simpler)
   API -- plain `cellularNetworkStrength`/`cellularNetworkType`
   properties, no subscription-id indirection.

### Picom rounded corners: the actual, final fix

Not an ARGB visual (reverted, see above) and not a WM_CLASS exclude
rule -- **we now draw the rounded corners ourselves**, at the X server
level, via the X Shape extension (`XShapeCombineRectangles`). The
window's real bounding shape *is* a rounded rectangle; there's no
mask for a compositor to guess at or conflict with. `MENU_CORNER_RADIUS`
in `config.h` controls the radius in px; `0` disables it (plain
rectangle, the original look).

### Battery bands, colors, and separate connection-state icons

- `BATTERY_BANDS` in `config.h` is now a `{threshold, color}` table
  you can resize freely (ships with 6 bands, as asked; change
  `BATTERY_BAND_COUNT` and the table together for any other count).
- All colors are full 6-digit hex now.
- `ICON_DISCONNECTED_DEVICE` and `ICON_NEW_DEVICE` are separate,
  independently configurable glyphs, instead of reusing the connected
  icon with just a different color.

### `-m`/`-p` unified: pairing is handled in the same menu

If the resolved device isn't paired yet, `-m` now shows a focused
"Pair Device" prompt instead of the normal (meaningless-when-unpaired)
action list. `-p` still works, but is now just a thin wrapper around
the same logic -- you genuinely don't need it anymore, though I kept
it for compatibility. An always-available "Pair Device" entry is also
in the normal action menu for an already-paired device (re-pair/
re-verify), toggleable via `SHOW_MENU_PAIR_DEVICE`.

**Pairing verification key notification**: selecting "Pair Device"
now calls `requestPairing()` and, after a brief grace period for the
key to become available, fetches `verificationKey()` and shows it as
a desktop notification -- so you can compare it against what's shown
on the phone without needing kdeconnect's own UI open. This is
best-effort: if the key isn't ready within ~400ms, the notification
just doesn't fire (no error, no crash).

### Every `-m` entry is independently toggleable

`SHOW_MENU_PING`, `SHOW_MENU_FIND_DEVICE`, `SHOW_MENU_SEND_FILE`,
`SHOW_MENU_BROWSE_FILES`, `SHOW_MENU_CLIPBOARD`, `SHOW_MENU_MESSAGES`,
`SHOW_MENU_SWITCH_DEVICE`, `SHOW_MENU_PAIR_DEVICE`,
`SHOW_MENU_UNPAIR`, `SHOW_MENU_OPEN_APP`, `SHOW_MENU_CUSTOM_ENTRIES` --
all `1`/`0` in `config.h`.

### Custom menu entries

`CUSTOM_MENU_ENTRIES` in `config.h` is a `{command, label}` table
appended at the bottom of the action menu. Each runs `command` via
`execvp` (spawned detached, not waited on) when selected -- no shell,
so no pipes/`$VARS`/`~`/multiple arguments; point at a script if you
need any of that.

```c
static const CustomMenuEntry CUSTOM_MENU_ENTRIES[] = {
    { "/home/you/bin/toggle-dnd.sh", "Toggle Do Not Disturb" },
    { "firefox",                     "Open Firefox" },
    { NULL, NULL } /* sentinel -- always keep this last */
};
```

### Menu orientation (RTL)

`MENU_RTL` in `config.h`: `0` (default) opens menus growing
right/down from the pointer with submenus to the right and a
right-pointing arrow; `1` mirrors everything -- opens growing
left/down, submenus to the left, left-pointing arrow, right-aligned
text. Useful if your bar/screen setup means rightward-opening menus
tend to run off-screen.

### `-m`/`-p` position: config defaults + CLI overrides

```c
#define MENU_POSITION_AT_POINTER  1   /* 1 = pointer, 0 = fixed MENU_FIXED_X/Y */
#define MENU_FIXED_X              20
#define MENU_FIXED_Y              20
```

Overridable per-invocation regardless of the config default:

```
--at-pointer     force opening at the current pointer position
--x N            open at this fixed X coordinate
--y N            open at this fixed Y coordinate
```

### fmenu (file picker): centered, configurable size

`FMENU_CENTERED 1` (default) centers the file picker on screen instead
of opening at the click/pointer position -- makes more sense for
something you're about to type into. `FMENU_WIDTH` and
`FMENU_MAX_VISIBLE_ROWS` control its size independently of the main
menu.

### Max width + ellipsis truncation

```c
#define MENU_MAX_WIDTH  360   /* 0 = unlimited, grow to fit (old behavior) */
```

When set and a row's text would exceed it, only the truncatable label
portion is shortened with `...` -- submenu arrows and the header's
battery/signal suffix are never cut off, only the device/entry *name*
portion is.

### `-j`/`--json` output

Same device data as `-d`/`--daemon`, formatted as a JSON array instead
of polybar markup:

```
polybar-kdeconnect -j                 # one-shot JSON dump
polybar-kdeconnect --daemon -j        # persistent, JSON per line instead of polybar markup
```

Each device object: `id`, `name`, `type`, `state`
(`"connected"`/`"disconnected"`/`"unpaired"`), `reachable` (bool),
`paired` (bool), `battery` (int or `null`), `low_battery` (bool),
`signal_bars` (int or `null`). Same transition-tracking and
notification side effects as the polybar-text path -- only the output
format differs.

## Dependencies

Build: `libdbus-1-dev`, `libx11-dev`, `libxft-dev`, `libxext-dev` (the
last one is new this round, for the Shape-extension corner rounding).

```sh
sudo apt install libdbus-1-dev libx11-dev libxft-dev libxext-dev
make
make install     # installs to ~/.local/bin (override with PREFIX=)
```

I still can't link-test this in the sandbox I write it in (no network
to fetch dev packages, no live KDE Connect/X server/compositor). Every
file compiles clean under `gcc -std=c11 -Wall -Wextra -Wpedantic`
against the real X11/Xrender/Xext/fontconfig headers plus hand-written
stubs for the small D-Bus/Xft API surface actually used, but that's
still not a real build or a real run.

## Polybar configuration

```ini
[module/kdeconnect]
type = custom/script
exec = ~/.local/bin/polybar-kdeconnect --daemon
tail = true
```

Add `-b` for battery percentage, `-j` for JSON instead of polybar
markup (not both meaningfully at once, obviously).

## CLI reference

```
polybar-kdeconnect --daemon [-b] [-j] [--show-name]
polybar-kdeconnect -d [-b] [-j] [--show-name]
polybar-kdeconnect -m [-n NAME -i ID] [--at-pointer | --x N --y N]
polybar-kdeconnect -n NAME -i ID -p [position opts]   (compat alias for -m)

polybar-kdeconnect --ping [-n NAME -i ID]
polybar-kdeconnect --find-device [-n NAME -i ID]
polybar-kdeconnect --send-file [-n NAME -i ID] [position opts]
polybar-kdeconnect --browse-files [-n NAME -i ID]
polybar-kdeconnect --send-clipboard [-n NAME -i ID]
polybar-kdeconnect --pair [-n NAME -i ID]
polybar-kdeconnect --unpair [-n NAME -i ID]
polybar-kdeconnect --messages
polybar-kdeconnect --open-app
```

The direct action flags use the same device auto-resolution as `-m`
when `-i`/`-n` are omitted (config.h `DEFAULT_DEVICE_ID` > live
detection), and run just that one action without opening any menu --
useful for dedicated keybindings.

## Default-device resolution for `-m`

When `-m` is invoked without `-i`:

1. `DEFAULT_DEVICE_ID` in `config.h`, if set -- used directly, no live
   detection at all.
2. Otherwise, live detection: the only connected device if there's
   exactly one; the most-recently-connected one (persisted to
   `$XDG_CACHE_HOME/polybar-kdeconnect/last-device`) if there are
   several; a brief "No devices connected" popup if there are none.

Regardless of how the device was picked, a "Switch Device" submenu is
always available when more than one device is connected.

## Menu controls

- Mouse: hover to highlight, click to select/open a submenu, click
  outside to cancel
- Keyboard: `Up`/`Down` or `j`/`k` to move; `Right`/`l`/`Enter` to
  select or open a submenu, `Left`/`h` to back out (swapped in RTL
  mode -- see `MENU_RTL`); `Escape`/`q` to cancel
- fmenu (file picker) has its own controls: type to filter
  (case-insensitive subsequence match), `Up`/`Down` to move, `Tab` or
  click to toggle a file for multi-select (Send File only), `Enter`
  confirms the checked set or the highlighted entry, `Escape` cancels

## Why the daemon is genuinely 0% idle

It blocks in `poll()` on the raw D-Bus socket fd (plus a self-pipe for
reliable `SIGINT`/`SIGTERM` shutdown) with an infinite timeout while
nothing is happening. A signal wakes it, a short debounce
(`DAEMON_DEBOUNCE_MS`) coalesces bursts, and it only prints when the
output actually changed. None of the flags added this round (`-b`,
`-j`, position overrides) touch this loop.

## What's configurable in config.h

Polybar output (icons per state, no-devices icon, battery bands,
low-battery threshold, device name display + truncation, inter-segment
spacing, A2-A5 click actions), menu appearance (font, colors, padding,
min/max width, corner radius, RTL, position defaults), per-entry menu
toggles, custom menu entries, file picker (start dir, icons, hidden
files, size, centering), notifications (four independent toggles),
daemon behavior (D-Bus timeout, debounce), default device, and the two
external app launcher binaries.

## Functionality preserved from the original bash script

Reachable/paired battery display, disconnected-but-paired icon,
incoming pairing-request prompt (shown once per request, not on every
poll tick), outgoing pair request, Ping, Find Device, Send File,
Browse Files, Unpair.

## What I didn't touch

Browse Files -- you mentioned you can't test it right now over
Bluetooth, so I've left it alone rather than guessing at a fix for a
problem I can't reproduce.
