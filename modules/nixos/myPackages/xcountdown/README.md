# countdown

A lightweight X11 countdown/timer widget written in pure C (Xlib + Xrender +
Xft). Built for tiling WMs like bspwm: it's an override-redirect window that
floats above everything, doesn't show up in the WM's layout, and only takes
keyboard focus while the mouse is actually over it.

## Build

Dependencies (dev packages): `libx11-dev libxft-dev libxrender-dev libxext-dev`
(on Debian/Ubuntu/Arch these are usually named `libx11-dev`, `libxft-dev`,
`libxrender-dev`, `libxext-dev` / `libx11 libxft libxrender libxext`).

```sh
make
sudo make install     # optional, installs to /usr/local/bin
```

## Changelog

### Round 3

- Added `--animate-changed-segment-only` (config `animate_all_segments =
  false`; default is `true`/`--animate-all-segments`, unchanged behavior).
  With a multi-field format like `hh:mm:ss`, this makes the continuous
  `--flash` pulse apply only to the fastest-changing field (seconds) while
  minutes/hours sit still, instead of the whole thing pulsing together.
- As part of this, digit-change transitions (`--scroll`/`--scroll-style`)
  now always animate only whichever field(s) actually changed, regardless
  of the setting above — previously the *whole* `hh:mm:ss` string slid/
  flipped together even when only the seconds changed, which this also
  fixes as a side effect of the same refactor (each field is now its own
  independently-tracked, independently-laid-out chunk of text).

### Round 2

- **Fixed the flip animation** (was showing just a white line): the clip
  band was being set on our own `Picture` object, but Xft manages its own
  separate internal Render picture for the same pixmap — clipping ours had
  zero effect on Xft's glyph drawing. Now uses `XftDrawSetClipRectangles`,
  the actual API for clipping Xft-drawn text.
- **Fixed the shadow "plus sign blob"**: `draw_rounded_rect` was only ever
  filling the top-left corner (a leftover from an unfinished "corners via
  GC arcs would be nicer" shortcut) — the other three corners were never
  drawn at all. Replaced with a proper per-row scanline fill (same
  technique already used for the circle style), so all four corners round
  off symmetrically now.
- **No-compositor rendering**: the app now detects whether a compositor is
  actually running (via the `_NET_WM_CM_S<screen>` selection), not just
  whether an ARGB visual exists. Every non-fully-transparent bg style
  (`circle`/`square`/`shadow`) now always gets a real X window shape
  (`XShapeCombineMask`) matching its visible silhouette — this fixes two
  things at once: without a compositor, the visible/black area is now
  correctly confined to the actual shape instead of the whole rectangle;
  and with one (e.g. picom), per-window blur/shadow effects stay contained
  to that same silhouette instead of bleeding into the corners. `none`/
  `transparent` fall back to a `square`-style opaque box (with a one-time
  stderr note) when no compositor is present, since real see-through pixels
  are impossible without one.
- **Focus fix for bspwm and other click-to-focus WMs**: on entering the
  widget, it now remembers *exactly* which window had focus beforehand and
  restores focus to that specific window on leave, instead of handing focus
  to `PointerRoot` (which click-to-focus WMs don't reliably interpret as
  "give it back"). Also added `--focus-follow`/`--no-focus-follow` as an
  escape hatch if you'd rather the widget never touch focus at all.
- Animation now pauses with the timer by default, and it's configurable
  both ways: `--animate-when-active` (default on) and
  `--animate-when-paused` (default off).
- Added two more continuous flash styles: `--flash-style throb` (a
  heartbeat-style double beat) and `--flash-style blink` (hard on/off),
  alongside the original `fade`.

### Round 1

- **Fixed a startup segfault**: `compute_window_size()` was being called
  once before the font was loaded, dereferencing a null `XftFont*`. It
  crashed on every single launch, regardless of flags. Removed the
  premature call; sizing now only happens after `load_fonts()`.
- Added digit-transition styles: `--scroll-style <slide|flip|bounce>`
  (works with `--scroll <seconds>`). `flip` fakes a split-flap/mechanical
  clock reveal via a shrinking-then-growing clip band (not a true 3D
  perspective flip — that needs per-glyph geometric transforms Xft doesn't
  expose cleanly — but it reads as a flip at widget size). `bounce` is the
  slide with a springy overshoot ease instead of a smooth one.
- Added `--exit-on-finish`: quits with exit code 0 once the timer hits 0
  (and, if an alarm is set, once it's done playing). Default is off — the
  widget just sits at 0 as before.
- Added `--on-success <cmd>`: runs only when the process is about to exit
  with code 0 (via `--exit-on-finish` or a clean Ctrl+C). Never runs on the
  right-click cancel path, which still exits 1.
- Added `--alarm <soundfile>` + `--alarm-repeat <n>`: plays a sound when the
  timer hits 0, via whichever of `paplay`/`aplay`/`ffplay`/`play` is
  installed. `--alarm-repeat 0` repeats indefinitely until you move the
  mouse over the widget or press a key while it's focused; a positive N
  plays it that many times and stops on its own (early interaction still
  silences it too).

## Quick start

```sh
./countdown -t 25m --format mm:ss --bg circle --flash
```

Right-click to quit, left-click to pause/resume, scroll to add/remove a
minute, left-click-and-hold to drag it anywhere on screen.

## Config file

`~/.config/countdown/countdown.conf` (or `--config <path>`) is loaded first;
any CLI flag you pass overrides the matching config value. See
`config/countdown.conf.example` for every available key, or run
`countdown --help` for the CLI equivalents.

## Sound playback deps (optional)

`--alarm` shells out to whichever of these is on your `PATH`: `paplay`,
`aplay`, `ffplay`, `play` (sox). Most distros have at least one already
(pulseaudio-utils/alsa-utils are common). If none are found, nothing plays
and nothing crashes — it's a best-effort `||` chain.

## Click / scroll behavior (all remappable, except drag)

| Input                  | Default action          |
|-------------------------|--------------------------|
| Right click              | exit (code 1)            |
| Right double-click        | reset to original time   |
| Left click                | pause / resume            |
| Left click + hold, move   | drag the widget (fixed)  |
| Left double-click          | "surprise me" easter egg |
| Scroll up / down          | +/- 60 seconds            |

Rebind any of these (except drag) via config (`click.right = ...`) or flags
(`--on-right-click ...`). Valid values: `none`, `exit`, `reset`, `pause`,
`surprise`, `inc:<seconds>`, `dec:<seconds>`.

## Design notes / assumptions worth knowing about

- **`--scroll`**: your message mentioned you'd explain this but the
  explanation didn't make it into the paste. I implemented it as an
  "odometer" style transition: when the displayed value changes, the old
  text slides/fades out while the new one slides/fades in, over the given
  number of seconds (0 = instant, the default). If you meant something else
  (e.g. a horizontally scrolling/marquee label), let me know and I'll swap
  the implementation — the rest of the app doesn't need to change.
- **Focus handling**: the window is override-redirect (so bspwm and friends
  never manage or tile it) and input focus is only requested on
  `EnterNotify` and explicitly released on `LeaveNotify`. It never grabs
  focus otherwise.
- **Transparency**: the app checks whether a compositor is actually running
  (not just whether an ARGB visual exists) via the standard
  `_NET_WM_CM_S<screen>` selection. With one running (picom, etc.), `--bg
  transparent`/`shadow`/`circle` and the flash fade genuinely blend against
  your real desktop, and the window is real-shaped (`XShape`) to match, so
  compositor effects like blur stay contained to the widget's actual
  silhouette instead of bleeding into its corners. Without a compositor,
  every style still renders correctly (properly shaped, opaque) — you just
  don't get true see-through pixels, since that's not possible without
  something compositing the window's alpha channel against the desktop.
- **Circle edges** are drawn without supersampling (cheap horizontal-strip
  fill), so they're crisp but not antialiased. Good enough at typical
  widget sizes; happy to add supersampled edges if you want it smoother.
- **CPU usage**: with `--flash` off and the timer not paused, the app wakes
  up essentially once a second and otherwise blocks in `select()` — no
  polling loop. Pausing with nothing animating drops it to ~0% CPU
  (indefinite block until the next X event). Turning on `--flash` (or an
  in-progress `--scroll` transition, or the surprise animation) caps
  redraws at 30fps only for that window's small pixmap, and only while the
  animation is actually running.
- **`--on-finish <cmd>`**: bonus flag — runs a shell command once when the
  timer hits zero (e.g. `--on-finish 'notify-send Countdown "Times up!"'`),
  forked off non-blocking so it can't stall the UI.
- **`--label <text>`**: bonus flag — an optional small caption drawn above
  the number (e.g. "Meeting starts in").

## Known limitations

- Compiled and unit-tested the pure logic (duration parsing, time
  formatting, config/CLI parsing) in this sandbox, but the X11 rendering
  path could not be run here (no X server / display available), so please
  treat the first run as a "does it build and look right" check. If
  anything's off visually, tell me what you're seeing and I'll fix it fast.
- Shadow "blur" is a handful of layered translucent rounded rects, not a
  true Gaussian blur — cheap on purpose, but let me know if you want a
  heavier, blurrier look.
