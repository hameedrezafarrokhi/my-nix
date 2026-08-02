# bspi

A C rewrite of the original `bspi.py`: renames bspwm desktops with icons
based on which applications are running on them, driven by the same
`bspi.ini` config format.

## Why rewrite it

The Python version worked, but had a few structural problems:

- It was invoked **once per bspwm event**, by whatever external loop
  called it (e.g. `bspc subscribe | while read -r; do bspi.py; done`).
  Every single invocation started a fresh Python interpreter, re-parsed
  `bspi.ini` from scratch (even once *per window on the desktop*, since
  a fresh `Icon()`/`configparser` object was created for every node),
  and forked a separate `bspc` subprocess for the state query and for
  every rename.
- On top of that, a missing/empty `WM_CLASS` triggered another forked
  subprocess (`xprop`) per window.
- Any unhandled exception (a node closing mid-query, `xprop` returning
  something unexpected, etc.) killed that invocation - and depending on
  how the outer loop was wired, could stop the whole pipeline from ever
  running again.

None of that is a knock on the original script's logic, which is
otherwise sound - it's just a lot of process-spawning and re-parsing
for something that runs on every window open/close/move. This rewrite
keeps the exact same renaming logic and config format, but as a small
persistent daemon:

- **No forking at all** for the normal path: it talks to bspwm's Unix
  socket directly (the same protocol `bspc` itself speaks) instead of
  shelling out to `bspc`, and to X directly via `libxcb` instead of
  shelling out to `xprop`.
- The `[Icons]` config is parsed once into an in-memory hash table (and
  can be hot-reloaded with `SIGHUP`), not once per window per event.
- JSON responses are parsed into a bump-allocated arena and freed in one
  shot, so nothing about a churn-heavy desktop (windows opening and
  closing quickly) causes per-object malloc/free pressure.
- It subscribes to bspwm's event stream itself and debounces bursts of
  events (default 50ms, capped at 250ms) instead of re-running fully on
  every single event - this is specifically aimed at the "crashes a lot
  when windows open/close fast" complaint.
- Errors are contained per-rescan: a malformed node, a lost X
  connection, or a lost bspwm connection is logged and recovered from
  (with backoff and automatic resubscription) rather than taking the
  whole process down. If bspwm itself restarts, bspi reconnects on its
  own instead of needing to be restarted.

One small deliberate behavior change: when `className` is empty and
bspi falls back to asking X directly, it uses the *class* half of the
`WM_CLASS` property (e.g. `Firefox`), not the *instance* half, which is
what the original's `xprop`-output parsing was actually extracting.
This matches what bspwm's own `className` field contains in the normal
case, so lookups behave consistently either way.

## Bug fix: sticky windows on an otherwise-empty desktop

The original script (and the first version of this rewrite) had a bug
that only shows up with sticky windows: if the desktop you're currently
looking at has no windows of its own, bspwm transfers any sticky
window into it (sticky windows always live on "whichever desktop of
this monitor is focused"). That desktop's tree is then non-empty - it
contains the sticky node - but since sticky windows are deliberately
excluded from naming, the code ended up computing an *empty string* as
the name instead of the usual "empty desktop" icon. A bar module that
hides zero-width desktop labels (many polybar configs do) then makes
every later desktop's label appear to shift left by one, which is
where the "workspace 2 shows workspace 3's icon" symptom came from.

The fix: after excluding sticky (and now also ignored, see below)
windows, if *nothing* is left to show for a desktop - regardless of
whether its tree was empty to begin with, or just empty of anything
worth displaying - it falls back to the same `_other` icon as a
genuinely empty desktop. This is covered by the sticky-only and
ignored-only test cases in `test/mock_bspwm.py`.

## Bug fix: renaming didn't react to focus changes

bspwm has an easy-to-miss quirk: sticky windows aren't duplicated
across every desktop - they're actually **moved into whichever
desktop is currently focused on their monitor**, and that move happens
as a side effect of focusing a desktop, not as a distinct, separately
subscribable "a node moved" event. bspi wasn't subscribing to focus
events at all, so it could stay unaware that a sticky window had
arrived on (or left) a desktop until some *other*, unrelated event
happened to trigger a rescan - which shows up as desktop labels/
occupied-state seeming to lag by one event, exactly the "it only lets
go of the old workspace once something else happens" symptom. Fixed by
also subscribing to `desktop_focus` and `desktop_activate`.

If you're seeing a bar module still fail to hide an unoccupied,
unfocused desktop promptly after upgrading and this doesn't fully
resolve it, it's likely coming from how that specific bar
module/script decides what to display rather than from bspi itself -
let me know which one you're using (polybar's built-in
`internal/bspwm` module vs. a custom script) and I can dig further.

## New config: `[ignore]` and `[workspaces]`

Two new optional sections in `bspi.ini` (see the commented examples at
the bottom of the shipped config):

```ini
[ignore]
class = Zoom, Peek
instance = tmux-256color
title = Picture-in-Picture, Save File
all = Volume Control*

[workspaces]
ws1 = 1
ws2 = 2
ws3 =
```

- **`[ignore]`** excludes matching windows entirely from a desktop's
  computed name - handy for floating utility windows (meeting
  toolbars, PiP video players) you don't want dominating the display.
  `class`/`instance` match the two halves of `WM_CLASS`; `title`
  matches the window title (only ever fetched from X if a `title` or
  `all` rule is configured, since it's an extra round-trip nothing
  else needs); `all` matches any of the three. Every value is a
  comma-separated list of glob patterns (`*`/`?`), matched
  case-insensitively - a plain string with no wildcard just needs to
  match exactly. A desktop left with nothing to show after ignoring
  falls back to the `_other` icon, same as a genuinely empty desktop.
- **`[workspaces]`** prepends a fixed prefix (a number, an icon,
  anything) to a desktop's computed name, based on its *position* on
  its monitor - the first desktop on each monitor is `ws1`, the second
  `ws2`, and so on, independent of whatever bspwm's own desktop id/name
  is (bspi overwrites the name anyway). Only `ws1` through `ws20` are
  recognized; leave a value empty (or omit the key) for no prefix.
  **Note:** this numbers desktops per-monitor. If you'd rather number
  them globally across all monitors instead, that's a one-line change
  in `bspi_rescan()` (move the `ws_index` counter outside the
  per-monitor loop) - happy to adjust if that's what you actually want.

## Building

```sh
make
sudo make install        # installs to /usr/local/bin/bspi
```

Requires `libxcb` (dev headers) and a C11 compiler. No other
dependencies - the JSON parsing and ini parsing are both self-contained
in this repo (see `src/json.c`, `src/ini.c`) rather than pulling in a
JSON library, so the whole thing is a few small files with no external
deps beyond `libxcb`.

## Running

`bspi.ini` uses the exact same format as before - the file you already
have will work unmodified. By default bspi looks for it in:

1. `$XDG_CONFIG_HOME/bspi/bspi.ini`
2. `~/.config/bspi/bspi.ini`
3. next to the `bspi` executable itself (matches where the old script
   looked, for an easy in-place upgrade)

or pass `-c /path/to/bspi.ini` explicitly.

Simplest setup: add this to your `bspwmrc`, near your other autostart
lines:

```sh
pgrep -x bspi > /dev/null || bspi &
```

`bspi` will pick up `BSPWM_SOCKET` from the environment bspwm already
exports, connect once, and keep desktop names in sync for as long as
it runs. `bspi -h` lists all options (`--socket`, `--debounce`,
`--once`, `-v`).

If you'd rather manage it with systemd, see `bspi.service` (a
`systemctl --user` unit) - adjust the `ExecStart` path and, if needed,
the `BSPWM_SOCKET` environment line as noted in the file.

Send `SIGHUP` to reload `bspi.ini` without restarting:

```sh
pkill -HUP bspi
```

### One-shot mode

If you'd rather keep your own event-triggering wrapper (like the
original script's usage) instead of bspi's built-in subscribe loop,
`bspi --once` does a single rescan-and-exit, same as invoking the old
Python script.

## Project layout

```
src/main.c     CLI parsing, config resolution, event loop, debounce/reconnect
src/config.c   Parses bspi.ini's [Icons]/[Ignore]/[Workspaces] sections in one pass
src/rescan.c   Walks the bspwm tree, computes desktop names, issues renames
src/ipc.c      bspwm Unix-socket client (send commands, subscribe to events)
src/xclass.c   Direct X WM_CLASS/title lookup via libxcb (replaces xprop)
src/ini.c      [Icons] hash table (WM class -> icon glyph)
src/ignore.c   [Ignore] glob-pattern matching
src/json.c     Minimal arena-allocated JSON parser for bspwm's `wm -d` output
test/mock_bspwm.py   A fake bspwm socket server for exercising the above
                      without a real X/bspwm session (see its header comment)
```
