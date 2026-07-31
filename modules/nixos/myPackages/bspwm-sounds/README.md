# bspwm-sounds

A lightweight native daemon that plays sounds on bspwm window-manager events
(open/close/focus/desktop switch/etc), replacing a bash+bspc+bc script that
was burning CPU and stacking overlapping sounds.

## Why this is fast where the bash version wasn't

The old script's costs, and what replaced them:

| Bash version cost                                   | This version                                              |
|------------------------------------------------------|-------------------------------------------------------------|
| `bspc subscribe` piping to a `while read` shell loop  | Talks to bspwm's Unix socket directly (no `bspc` process)   |
| A `date`, a `bc` call (sometimes two), per event      | `clock_gettime(CLOCK_MONOTONIC)` + plain float math in-process |
| `pw-play file &` forked **per sound, every time**     | One persistent audio engine; sounds are decoded once and played as in-memory voices |
| No cap on concurrent sounds -> pile-ups/lag           | Fixed voice pool with priority-based eviction               |
| Rate limiting via associative array + `bc` comparisons| O(1) monotonic-clock comparisons, no subprocess             |
| Idle cost: the device/stream approach in most rewrites | Audio device is only opened while something is playing, then closed after a short idle window -> ~0% CPU at rest |

## How it works

1. **Event source**: connects straight to `$BSPWM_SOCKET` (falls back to
   deriving the path the same way bspwm itself does) and issues the raw
   `subscribe` command over the socket. No `bspc` binary is ever spawned
   during normal operation.
2. **Window identification**: bspwm node IDs *are* the X11 window ID, so for
   `class`/`instance`/`title` matching we call `XGetClassHint` /
   `_NET_WM_NAME` directly via Xlib against that ID. No `xprop`, no `bspc
   query` subprocess.
3. **Audio**: uses [miniaudio](https://miniaud.io) (a single-header, dependency-free
   library that talks to PipeWire's PulseAudio-compatible server, native
   PulseAudio, or ALSA directly, auto-detecting whatever is running on the box).
   - `.wav` and `.mp3` are decoded natively by miniaudio, in memory, once.
   - `.ogg`/`.opus`/anything else miniaudio can't parse natively is
     transcoded **once** to a cached `.wav` (via a single `ffmpeg` call keyed
     off the source file's mtime+size) the first time the daemon sees it.
     After that it's a native, zero-decode-per-play WAV, same as everything
     else. This sidesteps needing to vendor an OGG/Vorbis decoder while still
     giving you full mp3/ogg support at effectively WAV speed.
   - The audio engine is only connected to the backend while something is
     playing, and is **fully disconnected** (`ma_engine_uninit`, not just
     `ma_engine_stop`) after `idle_shutdown_ms` of silence. This distinction
     matters on PipeWire: stopping/corking a stream leaves the client
     attached to the graph, where it can still get woken up periodically by
     the server's own scheduling -- you'll see small recurring CPU blips in
     `btop` long after the "idle" sound stopped. A full uninit actually
     drops the client, so a quiet desktop costs 0%, not "very low, but
     not zero, forever." The trade-off is a small (single-digit-to-tens of
     ms) reconnect cost the next time a sound plays after being fully idle
     -- imperceptible for a UI blip, and bursts of sounds within the idle
     window share one live connection so they don't pay it repeatedly.
4. **Overlap / spam handling** (the "smart" part):
   - Every rule has its own **debounce** (`debounce_ms`): re-firing the same
     rule faster than that is dropped.
   - Every rule has a **priority**. A fixed-size voice pool (`max_voices`)
     holds concurrently playing sounds; when it's full, a new sound only
     plays if its priority beats the *lowest*-priority sound currently
     playing (which gets cut). Otherwise it's dropped, not queued -
     queueing UI sounds behind a burst of alt-tabs is exactly the "lag"
     problem you had.
   - A rule can declare `suppress_if_events` + `suppress_window_ms`
     (this generalizes your original "skip focus sound if anything else
     happened in the last 50ms" hack) - e.g. don't play the plain focus
     sound if a node just opened/closed/desktop-switched in the last
     50-80ms, because that focus event is just noise trailing the real event.
5. **Config** is a small custom INI-like format (see `config.example.conf`)
   with `[settings]`, `[sounds]` (name -> file, defined by you, nothing
   hardcoded), and one `[rule:something]` block per behavior, each with its
   own sound, volume, priority, debounce, and optional `class`/`instance`/
   `title` POSIX-regex match. More specific/higher-priority rules win over
   the default for that event.
6. Extras: SIGHUP reloads the config live (no restart), a PID-file lock
   stops you from double-running it, and `--test <alias>` lets you audition
   a configured sound without touching bspwm at all.

## Building

```sh
curl -sSLo miniaudio.h https://raw.githubusercontent.com/mackron/miniaudio/master/miniaudio.h
make
```

Needs: a C compiler, `libX11` dev headers (`libx11-dev` / `libX11-devel`),
and `ffmpeg` on `$PATH` only if you actually use non-wav/mp3 sound files.
miniaudio itself has zero link-time dependencies on Linux beyond
`-lpthread -lm -ldl` (it dlopens PipeWire's pulse-compat lib, PulseAudio, or
ALSA at runtime - whichever is present - no dev packages needed for those).

## Running

```sh
./bspwm-sounds ~/.config/bspwm-sounds/config.conf
```

Add that line near the end of your `bspwmrc`, same place you'd start `sxhkd`.

Reload config without restarting:

```sh
pkill -HUP bspwm-sounds
```

Audition a sound defined in your config:

```sh
./bspwm-sounds ~/.config/bspwm-sounds/config.conf --test open_default
```
