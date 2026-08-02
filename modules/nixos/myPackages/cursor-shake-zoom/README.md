# cursor-scaler

Shake the mouse cursor to magnify it, on X11. No compositor required,
near-zero CPU at idle and while zooming, smooth linear growth tied
directly to the shake, and (optionally) true lossless zoom via SVG
rasterization.

This started as a fork of [adelmonte/x11_shake_to_magnify_cursor](https://github.com/adelmonte/x11_shake_to_magnify_cursor),
rewritten into a proper project with a config system, real no-compositor
support, lossless scaling, configurable easing, and a fullscreen guard.

## How it behaves

- Zooming **in** is a direct, linear ramp tied to wall-clock time while
  you're actively shaking (`zoom_in_rate`, in scale-units/second) - no
  eased "ticks" that restart and jerk around. It just tracks the shake.
- Zooming **out** (once you stop shaking) is a single eased transition
  back to normal size (`zoom_out_duration` + `easing`). Easing only ever
  applies to this one transition, by design.
- Below a fullscreen app (e.g. a game), the effect doesn't engage at
  all unless you turn that off - see `disable_in_fullscreen`.

## What changed from the original, and why

**Works without a compositor, without flickering.** A black box used
to appear behind the magnified cursor without a compositor, because an
ARGB override-redirect window's alpha channel is only honored if
something is actually blending it. The fix is `XShape`: the window is
cut down to the cursor's actual silhouette every frame, so nothing is
drawn outside of it - no compositor needed. The first version of this
fix still flickered/flashed black while zooming, because it resized the
overlay window on every animation frame; resizing an unmanaged window
gives the X server a chance to show its (cleared) backing content
before the next paint lands. This build creates the overlay window
**once**, at a fixed size big enough for `max_scale`, and only ever
*moves* it (never resizes it) - the visible region grows/shrinks purely
via content + the shape mask, both painted into pre-existing, reused
buffers. No resize, no flash.

**Much less pixelation, without repeated CPU cost.** The original
always rasterized from a fixed 32px cursor bitmap and stretched it up
to 30x, which gets blocky fast. This build instead loads the *largest*
bitmap your cursor theme actually ships and scales from that, or - if
you point it at the cursor's *source SVG* (many themes, including
Catppuccin, publish these separately from the compiled xcursor theme) -
rasterizes it **once, at startup**, at the resolution needed for
`max_scale`, and downscales from that per frame with XRender. Down-
scaling a high-res source looks effectively lossless at any smaller
size, so there's no need to re-rasterize on every frame - repeatedly
calling into librsvg/cairo during the animation was the single biggest
cause of high CPU usage while zooming in the first pass at this.

X11/libXcursor has no built-in concept of vector cursors - a theme
being "SVG-based" upstream doesn't mean X11 ever sees the SVG, only
whatever bitmap sizes got baked into the installed xcursor theme. There
is no way around that without doing the SVG rasterization ourselves,
which is what `svg_path` (or auto-detection) is for.

**Correct starting size.** The "shrinks first, then jumps big" glitch
came from the replacement window's 1.0x size being computed from
`XcursorGetDefaultSize()`, which can disagree with whatever pixel size
your desktop actually renders the real cursor at (HiDPI/scaling
setups especially). The overlay now prefers `$XCURSOR_SIZE` (what your
session actually configures) before falling back to the library
default, so the swap from the real system cursor to the overlay at
scale 1.0 shouldn't be visible at all.

**CPU usage.** The event loop blocks indefinitely on the X11 connection
whenever nothing is animating and no shake is in progress - 0% idle
CPU, not a fast poll loop. While the pointer moves without shaking, raw
motion events are drained from the queue in a batch and only one
`XQueryPointer` call is made per batch (instead of one per event).
While zooming, every per-frame allocation that used to happen (a fresh
mask pixmap, a fresh SVG raster) has been replaced with a buffer
allocated once at startup and reused; rendering is capped to a
configurable fps and driven by a clock.

**Fullscreen guard.** Right as a shake is about to engage (not every
frame - only checked once per potential shake, so the cost is
negligible), the focused window is checked against the EWMH fullscreen
state and a "borderless window covering the whole screen" heuristic. If
either matches, the shake is ignored. This is best-effort - some
exclusive-fullscreen setups won't set either signal - but it's free
enough to just leave on. Toggle it off with `disable_in_fullscreen =
false` / `--enable-in-fullscreen`, or send `SIGUSR1` to the running
process to pause/resume the whole effect manually at any time (e.g.
bind that to a hotkey yourself if the automatic detection ever misses
a game):

```sh
pkill -SIGUSR1 cursor-scaler
```

## Building

```sh
# Debian/Ubuntu
sudo apt install build-essential pkg-config \
    libx11-dev libxext-dev libxcursor-dev libxi-dev \
    libxrender-dev libxfixes-dev libxrandr-dev

# optional, for lossless SVG zoom:
sudo apt install librsvg2-dev libcairo2-dev

make
sudo make install       # installs to /usr/local/bin/cursor-scaler
```

The build auto-detects librsvg/cairo via `pkg-config` and prints
whether SVG support is compiled in. Force it off with `make NO_RSVG=1`
or force it on (fail loudly if missing) with `make RSVG=1`.

### Nix

```sh
nix build .
# or, without cloning:
nix run github:yourname/cursor-scaler
```

`nix/default.nix` also works as a standalone `callPackage`-able
derivation if you'd rather vendor it into an existing flake/overlay.

## Running

```sh
cursor-scaler
```

Runs in the foreground; `Ctrl-C`/`SIGTERM` restores the normal system
cursor and exits cleanly. `SIGUSR1` toggles a manual pause. See
`systemd/cursor-scaler.service` for an autostart unit
(`systemctl --user enable --now cursor-scaler`, after installing it and
adjusting the `ExecStart` path if needed).

## Configuration

Copy `config/cursor-scaler.conf.example` to
`~/.config/cursor-scaler/config.conf` and edit it - every option is
documented inline. Every option is also available as a `--flag`;
command-line flags always win over the config file.

```sh
cursor-scaler --help            # list all flags
cursor-scaler --print-config    # show the effective config and exit
```

Notable options:

| Setting | What it does |
|---|---|
| `shake_threshold`, `shake_timeout`, `movement_threshold` | shake-gesture sensitivity |
| `min_scale`, `max_scale`, `zoom_in_rate` | how big it gets, and how fast it grows while shaking (linear, always) |
| `zoom_out_duration`, `easing` | the single shrink-back-to-normal transition |
| `fps` | animation frame cap - match your monitor's refresh rate |
| `cursor_name`, `cursor_theme`, `cursor_size` | which cursor to magnify, and at what base resolution |
| `svg_path`, `disable_svg` | lossless SVG zoom |
| `filter`, `shape_mode` | rendering internals / no-compositor behavior |
| `disable_in_fullscreen` | skip the effect while a fullscreen app is focused |

### Getting true lossless zoom

If your cursor theme's source SVGs are available somewhere on disk
(check the theme's upstream git repository - the *installed* xcursor
theme itself never contains SVGs, only baked bitmaps), point
`cursor-scaler` at the file for your cursor:

```sh
cursor-scaler --cursor-name left_ptr --svg-path ~/src/catppuccin-cursors/svg/left_ptr.svg
```

A short list of conventional install locations is auto-searched as a
best-effort convenience if you don't set this explicitly, but it isn't
guaranteed to find anything - manual `--svg-path` is the reliable
option. Without an SVG, cursor-scaler still looks about as good as
X11/Xcursor is capable of, by scaling from the largest bitmap the
theme ships instead of a small fixed size.

## Project layout

```
src/            cursor_scaler.c (X11/XRender/XShape/XInput2 + event loop),
                config.c (config file + CLI parsing), svg_loader.c (optional)
include/        headers, incl. header-only easing.h
config/         example config file
systemd/        optional user service unit
nix/            Nix derivation
flake.nix       Nix flake wrapper
```

## License

MIT, see `LICENSE`.
