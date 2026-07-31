# xwww (C rewrite)

Animated wallpaper transitions for X11. Daemonless: each invocation is a
single short-lived process that draws a transition and exits — nothing
keeps running in the background.

This is a ground-up rewrite of the original bash+ffmpeg+hsetroot version
in pure C. It removes every external process from the pipeline; there is
no ffmpeg, no hsetroot, no `bc`, no bash.

## Why it's faster

The old pipeline, per frame: ffmpeg renders a frame to a PNG/BMP on disk,
then a *new process* (hsetroot) is spawned to read it back and set the
root window. That's a file write + two process spawns + two exec's, times
however many frames you configured. On an old CPU with a 4K wallpaper
that adds up fast, and it's why the original README calls large images
"slow."

xwww does everything in one process, in memory:

- **One-time decode.** The image is decoded once via Imlib2 straight into
  an RGBA buffer; there's no per-frame file I/O at all.
- **All transition math is hand-written C** operating on plain `uint32_t`
  ARGB buffers (`src/transitions.c`) — no filter graphs, no subprocess.
- **Every frame is pushed to the X server in-process.** Each frame is
  written into a fresh `Pixmap` via `XShmPutImage` (MIT-SHM, shared
  memory, no encoding), set as the root window's background, and
  announced via the `_XROOTPMAP_ID`/`ESETROOT_PMAP_ID` properties —
  the same mechanism `hsetroot`/`feh` use, and the reason wallpaper
  changes show up correctly under compositors and desktop-background
  tools (which redraw from that property, not from watching raw root
  pixels; drawing straight onto the root window's pixels without
  updating it is invisible under almost every real desktop today).
  What xwww skips is the *process spawn and exec* that made the old
  approach slow, not this bookkeeping — that part was always required
  and every frame here still does it. It's simply doing X11 protocol
  requests in a live connection instead of paying fork/exec + file I/O
  for each one, which is the actual cost `hsetroot`-per-frame had.
- **Reclaiming a stale pixmap is only expensive once per run.** Freeing
  a pixmap left behind by a *previous* xwww process needs the
  feh-style `XGetWindowProperty` ×2 + `XKillClient` dance (because
  that process is long gone). Pixmaps xwww creates itself during the
  same run are freed with a plain, cheap `XFreePixmap` the moment the
  next frame supersedes them.
- **Rows are split across threads** (`pthread`, one job per CPU core) so
  multi-core machines — even old, low-clock ones — parallelize the
  per-pixel transition math.
- **Optional `RENDER_SCALE`** lets you compute the animation itself at a
  fraction of native resolution (e.g. 0.5) and upscale each frame for
  display; only the final frame is always rendered at full quality. This
  is the single biggest lever for "large image + old CPU": it shrinks
  the O(w·h) per-frame cost for effects with real math in them (wave,
  spin, circle, clock) without touching final image quality.

## No more external wallpaper setter, but new placement flags

Since xwww talks to X11 directly instead of shelling out to
feh/hsetroot/nitrogen/xwallpaper, it needed to grow their job: image
placement. `--scale-mode` covers `fill` (cover+crop, default), `fit`
(contain+letterbox), `stretch`, `center`, and `tile`, with `--bg-color`
for the fit/center/tile padding.

## No daemon, no tracked state — screen capture instead

Being daemonless means xwww has no memory of "what was on screen before"
between runs. Rather than requiring you to track a previous-wallpaper
file, xwww just **screenshots the current root window** at startup and
uses that as the transition's starting frame. This has a nice side
effect: it transitions cleanly out of *whatever* is currently displayed,
regardless of what set it — xwww, feh, a solid color, even nothing.

## Dependencies

- `libx11-dev` (Xlib)
- `libimlib2-dev` (image decoding: png/jpg/bmp/webp/gif/tiff/...)
- `libxext-dev` (MIT-SHM, for the fast per-frame path — auto-detected,
  falls back to plain `XPutImage` if unavailable)
- `libxinerama-dev` *(optional, for `--output <monitor>`; falls back to
  treating the whole X screen as one monitor if not installed)*
- `pthread` (part of libc on Linux)

No ffmpeg, no hsetroot, no bash, no bc.

## Install

```sh
git clone <this repo>
cd xwww-c
make
sudo make install            # installs to /usr/local/bin/xwww
```

Build options: `make HAVE_XSHM=0` / `make HAVE_XINERAMA=0` to force
either optional feature off, `make PREFIX=/usr` to change install
location.

## Usage

```
xwww                                   # restore last wallpaper (see below)
xwww ~/Pictures/wall.jpg               # set an image, default transition
xwww ~/Pictures/wallpapers             # random image from a directory
xwww wall.jpg --animation wave
xwww wall.jpg --random                 # random transition
xwww wall.jpg --random wave,fade,circle-out
xwww wall.jpg --duration 800 --easing ease-in-out-cubic
xwww wall.jpg --scale-mode fit --bg-color '#101010'
xwww wall.jpg --output monitor-1       # only touch one monitor
xwww --list                            # show every available transition
```

Run `xwww --help` for the full flag reference.

### List of transitions

`fade`, `wipe-left/right/up/down`, `slide-left/right/up/down`,
`push-left/right/up/down`, `oblique-left/right`,
`emerge-left/right/up/down`, `circle-in/out`, `grow-center`, `diamond`,
`clock`, `pixelate`, `wave`, `spin`, `open`, `close`, `zoom-in/out`,
`dissolve`, `checker`, `blinds-h/v`, `none` (instant, no animation).

That's every effect from the original list plus everything in
swww/awww's set, plus new ones (`dissolve`, `checker`, `blinds-*`,
`diamond`, `clock`, `grow-center`, direction-complete `push-*`/
`emerge-*`/`slide-*`/`oblique-*`).

### Restoring at login (feh-style)

Every successful run writes `$HOME/.xwww-bg`, an executable shell script
containing the exact command to instantly re-set that wallpaper with no
transition — exactly like feh's `~/.fehbg`. Source it from your
`.xinitrc` or WM autostart:

```sh
[ -f "$HOME/.xwww-bg" ] && sh "$HOME/.xwww-bg" &
```

Running `xwww` with no arguments, or `xwww --restore`, does the same
thing without needing a shell wrapper.

### Config file

`$HOME/.config/xwww/xwwwrc` (or `--config PATH`). See
`config/xwwwrc.example` for every option with comments. CLI flags always
override the config file. An old-format `xwwwrc` (with `R_X`,
`TRANSITION_CMD`, `FORMAT`, `ACCEL`, ...) won't error out — those keys
are accepted and silently ignored, since none of them apply anymore.

### Adding your own transition

See `templates/custom_transition_template.c` for a fully commented,
copy-pasteable example. Effects are plain C functions registered in a
table (`src/transitions.c`) — no plugin system, no scripting layer,
just the same code path every built-in effect uses, so a custom effect
is exactly as fast as a built-in one.

## Multi-monitor

`--output all` (default) spans the whole X screen — if you run separate
X screens per monitor rather than one big virtual screen, "all" is
already what you want. `--output monitor-0` / `monitor-1` / ... (via
Xinerama geometry) targets a single monitor and leaves the others
untouched; xwww captures the full root image first and only overwrites
that monitor's region, so nothing else on screen flickers or gets
touched.

## GPU acceleration

Deliberately not used. GLX/EGL would help most for effects like `spin`,
`wave`, or `circle-*` that involve per-pixel trig/sqrt, but it adds a
real chunk of complexity (context setup, shader compilation, texture
upload/readback, driver-dependent failure modes) that's hard to test
reliably across the range of old/integrated GPUs this project targets.
The CPU path is already parallelized across cores and has the
`RENDER_SCALE` knob for exactly the "old CPU, big image" case this
project cares about, which covers most of the real-world benefit at a
fraction of the risk. `src/xroot.c`'s frame-push interface
(`xroot_draw_transient`/`xroot_commit_background`) is intentionally the
only place that talks to the display, so a GL backend could be dropped
in later as an alternative implementation of just that file without
touching the transition math at all.

## Limitations

- Every animation frame updates the root pixmap/atoms (see "Why it's
  faster" above) since that's what actually makes a frame visible on a
  real desktop. On a compositor that does non-trivial work on every
  wallpaper-property change (texture re-upload, etc.), very high frame
  counts could in principle cause more compositor-side load than a
  no-op frame would. If you see stutter under a specific compositor,
  lowering `--fps`/`--duration` (fewer frames) helps more than
  `RENDER_SCALE` does, since it's the atom updates, not the pixel math,
  that scale with frame count.
- Assumes a 24- or 32-bit TrueColor visual (the overwhelming majority of
  real-world X11 setups). Unusual depths/visuals fall back to a slower,
  portable per-pixel path (`XPutPixel`/`XGetPixel`) rather than failing
  outright.
- `--output` monitor geometry comes from Xinerama; if your setup only
  exposes monitors via RandR-1.5-without-Xinerama-compat, monitor
  detection falls back to treating the whole screen as one output (`all`
  still works correctly either way).
- No video/GIF wallpapers — this project animates *transitions between
  two still images*, not looping video wallpapers.
