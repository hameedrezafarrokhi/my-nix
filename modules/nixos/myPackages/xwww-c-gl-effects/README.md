# xwww (C rewrite)

> **This is the `gl-effects` branch.** It adds an optional GLX/OpenGL
> renderer for `cube`, `axis-spin`, the swing/page-turn/roll/carpet
> family, `shatter`, `paper-plane`, `burn`, `melt`, and `ripple` — see
> **[README-GL.md](README-GL.md)** for what changed and how it falls
> back to the CPU versions below when GL isn't available. Everything
> else on this page describes the base (`main`-branch) tool unchanged.

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
- *(optional, runtime-only)* `paplay`, `aplay`, `ffplay`, or `mpv` — only
  needed if you use `logo-sting`'s `--logo-sound`; xwww tries each in
  turn and just stays silent if none are installed. Not a build
  dependency at all.

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
`dissolve`, `checker`, `blinds-h/v`,
`stripes-left/right/up/down`, `stripes-oblique-left/right`,
`panes-left/right/up/down`,
`fire-ring`, `burn`,
`full-swing-forward/backward`, `half-swing-forward/backward`,
`page-turn-left/right/up/down`,
`shatter`, `matrix`, `melt`,
`roll-away-up/down/left/right`, `carpet-up/down/left/right`,
`bubbles`, `ripple`, `flicker`, `axis-spin`, `cube`, `logo-sting`,
`paper-plane`, `none` (instant, no animation).

`xwww --list` prints the full set (74 and counting) with a one-line
description of each. Some naming notes, since a few of these went
through revisions:

- **`stripes-*`** is a cascade: the screen splits into `BLINDS_COUNT`
  bars that slide into place staggered, arriving as a wave.
  **`stripes-oblique-*`** is the same idea on a diagonal instead of
  straight rows/columns. **`panes-*`** is a different effect that's
  easy to confuse with `stripes-*`: the screen splits into bars too, but
  each bar reveals independently via its own little wipe, all moving
  *together* rather than staggered — like several blinds opening in
  sync rather than a cascade.
- **`fire-ring`** is a clean radial fire front (this used to be called
  `burn`). **`burn`** now means something more literal: `BURN_PATCHES`
  independent ignition points grow into jagged, irregular blobs (not
  circles — each one's edge is perturbed by a couple of random sine
  harmonics) that merge into each other as they spread, with sparse
  ember sparks flaring near the active edges.
- **`full-swing-*`** is a door hinged at the screen edge (this used to
  just be called `swing-*`). **`half-swing-*`** is the same swinging
  door, but hinged at a configurable interior point (`PIVOT_PCT`)
  instead of the edge — only the side of the pivot in the swing
  direction actually moves; the other side just crossfades.
- **`page-turn-*`** is hinged at the center, like a real open book: one
  half of the screen curls over the spine with a highlight/shadow band
  at its curling edge, and the other half (the "other page") crossfades
  since it isn't the page being turned.
- **`shatter`** breaks the old image into irregular polygon pieces (a
  jittered Voronoi diagram — the same cheap trick used for cracked-glass
  looks in shaders, not a uniform grid) that fall away with gravity, with
  a thin crack-line highlight right at the break lines early on. Pieces
  translate but don't rotate.
- **`matrix`** is a staggered per-column wipe with a sinusoidal edge
  (this used to be called `melt`). **`melt`** now means an actual goo
  drip: colors smear across a soft (not hard-edged) boundary and the old
  image visibly sags downward before it's gone.
- **`roll-away-*`**/**`carpet-*`** now do a real cylindrical shading
  pass within a band straddling the wipe boundary (brightness follows a
  sine falloff, with a touch of compression toward the band's edges) so
  the material actually reads as curving through a roll, not just a flat
  cut with a highlight line riding on it.
- **`cube`** and **`axis-spin`** are both honest two-face foreshortening
  flips (front = old image, back = new), not a real 3D/6-face
  perspective renderer — that needs an actual rasterizer. `cube` adds a
  zoom in/out through the spin; `axis-spin` is a plain spin around your
  choice of vertical or horizontal axis, internally eased so the
  slow → fast → slow spin shape holds regardless of your `--easing`
  choice, and motion-blurs 3 close angle samples per pixel to keep the
  fastest part of the spin from looking choppy.
- **`logo-sting`** needs `--logo-path` to do anything interesting
  (otherwise it just fades) — see below.
- **`paper-plane`** is a stylized flying thumbnail card on a swooping
  path, not a literal paper-fold simulation — genuinely folding and
  unfolding paper geometry is out of reach for per-pixel 2D math.

### Per-effect fine control

Several effects take extra parameters beyond the global timing/easing
settings, all with CLI flags and config-file keys:

| flag | config key | affects | default |
|---|---|---|---|
| `--origin-x`/`--origin-y` | `ORIGIN_X`/`ORIGIN_Y` | `circle-in/out`, `grow-center`, `diamond`, `clock`, `fire-ring`, `burn` (1st patch), `bubbles` (1st bubble), `ripple` (primary droplet) | 50, 50 (center) |
| `--oblique-angle` | `OBLIQUE_ANGLE` | `oblique-left/right`, `stripes-oblique-*` | 45 (degrees) |
| `--wave-amp`/`--wave-length` | `WAVE_AMP`/`WAVE_LENGTH` | `wave` | 50, 200 |
| `--pixelate-size` | `PIXELATE_SIZE` | `pixelate` | 64 |
| `--blinds-count` | `BLINDS_COUNT` | `blinds-h/v`, `stripes-*`, `panes-*` | 12 |
| `--checker-size` | `CHECKER_SIZE` | `checker` | 48 |
| `--shard-size` | `SHARD_SIZE` | `shatter` | 64 |
| `--curl-pct` | `CURL_PCT` | `page-turn-*`, `roll-away-*`, `carpet-*` (roll/curl radius) | 5 |
| `--pivot-pct` | `PIVOT_PCT` | `half-swing-forward/backward` | 50 (center) |
| `--burn-patches`/`--burn-jaggedness` | `BURN_PATCHES`/`BURN_JAGGEDNESS` | `burn` (and patch count for `bubbles`) | 10, 0.5 |
| `--cube-zoom`/`--cube-spin-speed` | `CUBE_ZOOM`/`CUBE_SPIN_SPEED` | `cube` | 0.3, 1.5 |
| `--axisspin-vertical` | `AXISSPIN_VERTICAL` | `axis-spin` (spin around horizontal instead of vertical axis) | off |
| `--axisspin-turns` | `AXISSPIN_TURNS` | `axis-spin` | 6 |
| `--ripple-amp`/`--ripple-freq`/`--ripple-droplets` | `RIPPLE_AMP`/`RIPPLE_FREQ`/`RIPPLE_DROPLETS` | `ripple` | 18, 0.15, 0 |
| `--flicker-min-brightness`/`--flicker-count` | `FLICKER_MIN_BRIGHTNESS`/`FLICKER_COUNT` | `flicker` | 0.12, 8 |
| `--logo-path`/`--logo-sound` | `LOGO_PATH`/`LOGO_SOUND` | `logo-sting` | none |
| `--logo-static-frac`/`--logo-fadein-frac`/`--logo-spin-speed`/`--logo-zoom-speed` | `LOGO_STATIC_FRAC`/`LOGO_FADEIN_FRAC`/`LOGO_SPIN_SPEED`/`LOGO_ZOOM_SPEED` | `logo-sting` | 0.15, 0.15, 3.0, 1.0 |

`--origin-x 100 --origin-y 100` starts a circle/diamond/clock/fire-ring
from the bottom-right corner instead of the center; `0 0` is top-left.

`logo-sting` needs `--logo-path` pointing at a PNG (or a directory of
them, randomly picked) with the logo/face/whatever you want, ideally
with alpha transparency. SVG depends entirely on whether your Imlib2
build has the svg loader plugin installed — PNG is the safe bet.
`--logo-sound` is optional and plays once via whichever of
`paplay`/`aplay`/`ffplay`/`mpv` it finds on your system (fire-and-forget,
never a hard dependency — if none are installed it just stays silent).

### More easing control

`--easing` accepts a lot more than the original three curves: run
`xwww --list-easings` for the full set (quad/cubic/sine/expo/back/
elastic/bounce, each in/out/in-out where it makes sense). For anything
even more specific, pass a raw CSS-style curve instead of a preset:

```
xwww wall.jpg --bezier 0.68,-0.55,0.27,1.55   # a springy overshoot curve
```

`--bezier X1,Y1,X2,Y2` implies `--easing bezier`; same thing works as
`EASING="bezier(0.68,-0.55,0.27,1.55)"` or `BEZIER=0.68,-0.55,0.27,1.55`
in the config file.

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

### Slideshow / daemon-style mode

xwww is still daemonless by default — a single run does one wallpaper
change and exits. `--slideshow` is the one opt-in exception, for people
who want a timed rotation:

```sh
xwww --slideshow ~/Pictures/wallpapers --interval 300          # foreground
xwww --slideshow ~/Pictures/wallpapers --interval 300 --shuffle --daemonize
xwww --slideshow-stop                                          # stop it
```

Without `--daemonize` it just runs in the foreground (background it
yourself with `&`, a systemd user unit, or your WM's autostart — that's
more robust than any ad hoc daemonization this tool could do itself).
With `--daemonize` it does a single `fork()` + `setsid()`, writes its
pid to `$HOME/.xwww-slideshow.pid`, and detaches; `--slideshow-stop`
reads that pidfile and sends `SIGTERM`. Sequential mode (the default)
walks the directory alphabetically and loops; `--shuffle` picks
randomly each cycle. All the normal transition/timing/placement flags
and config-file settings (including per-effect `[section]` overrides)
apply to every change in the rotation. The directory is rescanned each
cycle, so images added while it's running show up automatically.

### Config file

`$HOME/.config/xwww/xwwwrc` (or `--config PATH`). See
`config/xwwwrc.example` for every option with comments. CLI flags
override the config file's global section; a `[effect-name]` section in
the config file is the most specific scope and overrides *both* the
global section and CLI flags whenever that particular effect is the one
running — see the example file for how to give, say, `wave` or
`page-turn-left` their own timing and parameters. An old-format `xwwwrc`
(with `R_X`, `TRANSITION_CMD`, `FORMAT`, `ACCEL`, ...) won't error out —
those keys are accepted and silently ignored, since none of them apply
anymore.

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
