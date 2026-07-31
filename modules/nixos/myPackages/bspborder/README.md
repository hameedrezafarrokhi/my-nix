# bspborder

A tiny C daemon that gives bspwm per-window border colors, which bspwm
doesn't support natively. It's a rewrite of a bash script that did the same
thing by shelling out to `bspc`, `jq`, `xprop`, `awk`, and `sed` on every
focus change.

## Why the rewrite was necessary

The original script forked roughly six external processes per event
(`bspc query`, two `jq` calls, `xprop`, `awk`, `sed`, plus `bspc config` to
apply the color). Each of those is a fresh `fork()+exec()`, dynamic linking,
and — for `xprop`/`bspc` — a fresh X11/socket connection setup. That's fine
once. It's very much not fine when you're alt-tabbing quickly: events queue
up faster than the process-spawn pipeline can drain them, so the CPU spikes
to 100% within seconds and the border visibly lags behind the actual focus
change.

`bspborder` does the same job with **zero forked processes** on the hot
path:

- It connects to the bspwm Unix socket directly and speaks its protocol
  itself (the same one `bspc` uses), instead of invoking `bspc`.
- It queries X11 properties (WM_CLASS, `_NET_WM_NAME`, `_NET_WM_WINDOW_TYPE`)
  via Xlib in-process, instead of invoking `xprop` and text-processing its
  output with `awk`/`sed`.
- It parses the tiny amount of JSON it needs (only when a window is first
  seen) with a couple of `strstr` calls, instead of shelling out to `jq`.
- It keeps a small in-memory cache of each window's tiling state and
  sticky/private/locked/marked flags, kept current by listening to
  `node_state`/`node_flag` events. So on a plain focus change (the hot
  path — this is what alt-tab hammers), there is no bspwm tree query at
  all: just a cache lookup plus a couple of Xlib calls.
- It blocks on `recv()` between events instead of polling, so idle CPU
  usage is 0%.
- It skips re-sending `config focused_border_color` when the resolved
  color hasn't actually changed (e.g. alt-tabbing between two windows of
  the same class).

The net effect: focus-change handling drops from "spawn six processes and
parse their text output" to "a few hash-table/array lookups and two Xlib
calls," which is why it fixes both the CPU usage and the color-lag/flash
you were seeing.

## Build & install

```sh
make
sudo make install        # installs to /usr/local/bin/bspborder
```

Or just `make` and copy the `bspborder` binary wherever you like — it has
no runtime dependencies beyond libX11 and bspwm itself.

## Config

Copy `bspborder.conf` to `~/.config/bspborder/bspborder.conf` (or point
`bspborder -c /path/to/file` at it) and edit it. The format is documented
at the top of the file; the short version:

```
default #7dc4e4

rule class=firefox color=#fab387
rule state=floating color=#eed49f
rule type=DIALOG color=#ed8796
rule flag=sticky color=#ee99a0
```

- Rules are evaluated top to bottom. Every rule whose conditions **all**
  match (AND) overwrites the color chosen so far — so a rule further down
  the file has higher priority, exactly like the original script's
  `case` statement, where the sticky check being last meant it always won.
  That's ported over directly: `flag=sticky` is still the last rule.
- A rule can combine multiple conditions to require them all:
  `rule class=firefox state=floating color=#xxxxxx` only matches a
  floating Firefox window.
- Add `stop` at the end of a rule if you want it to be a hard override that
  skips every rule below it, instead of just cascading.
- `class~=`, `title~=` accept POSIX extended regexes instead of exact/
  substring matches. `title=` is a substring match (window titles change
  constantly — e.g. browser tabs — so exact match is rarely useful).

Send `SIGHUP` to the running daemon to reload the config without
restarting it:

```sh
pkill -HUP bspborder
```

## Running it

Add to `bspwmrc`, same as the original script:

```sh
pgrep -x bspborder > /dev/null || bspborder &
```

## Notes on the bspwm event format

bspwm's `subscribe` stream doesn't label its fields by name, and the exact
column position of the node ID differs a bit between event types
(`node_focus mon desk node`, `node_state mon desk node state status`, ...).
Rather than hardcode column offsets — which is fragile across bspwm
versions and is arguably what silently made `$node_id` in the original
script's `read` line not what you'd expect for some event types — this
daemon finds the node ID by taking the **last token that looks like a hex
ID** (`0x...`) on the line. Monitor/desktop/node IDs are always hex; state
names and on/off statuses never are, so this reliably picks out the node ID
regardless of exact field count.
