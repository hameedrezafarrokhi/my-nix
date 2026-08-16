# dunst-notif-center

A full-featured notification history center for dunst on X11. Built as a
standalone GTK3 app (Python + PyGObject) driven entirely through `dunstctl`,
so it doesn't touch dunst's internals — just its public CLI.

## Install

```sh
sudo pacman -S python-gobject gtk3   # Arch; use your distro's equivalents
pip install --user tomli             # only needed on Python < 3.11
chmod +x notif_center.py
./notif_center.py
```

Bind it to a key in your WM (sxhkd/i3/etc), e.g. in sxhkdrc:
```
super + n
    /path/to/notif_center.py
```

Same binding works whether or not a daemon is already running — see below.

### Daemon mode (`-d`, opt-in — fixes slow open)

Daemon mode is controlled entirely by the `-d` CLI flag now, not config:

```
notif_center.py              plain: toggles a running daemon if one exists,
                              otherwise runs one-shot (built/shown/exits on close)
notif_center.py -d           starts a background daemon — does NOT open the
                              window itself; no-op if one is already running
notif_center.py --quit       tells a running daemon to exit cleanly
```

Bind your hotkey to the plain (no-flag) form either way — it does the right
thing automatically depending on whether a daemon happens to be running.
`-d` is for explicitly starting one (e.g. from a startup script, or the new
bottom bar's "Start d" button), not something you'd normally put on the hotkey.

To start the daemon once at login, e.g. a systemd user service:

```ini
# ~/.config/systemd/user/dunst-notif-center.service
[Unit]
Description=dunst-notif-center daemon
After=graphical-session.target

[Service]
ExecStart=/path/to/notif_center.py -d
Restart=on-failure

[Install]
WantedBy=graphical-session.target
```
```sh
systemctl --user enable --now dunst-notif-center.service
```

### Bottom bar (two rows now)

Row 1 (unchanged): Clear all / Pause-Resume / Reload / Kill / Open log.
`Reload` used to only call `dunstctl reload` (reloading dunst's own config)
without ever refreshing what you actually see — it now also re-fetches and
rebuilds the list.

Row 2, new — controls for the *daemon process itself*, work the same
whether or not the window you're clicking them in happens to be the
daemon's own window:
- **Start d** — starts a background daemon if none is running; no-op if one already is.
- **Stop d** — stops the running daemon.
- **Reload d** — re-reads `config.toml`/`style.css` and refreshes the list on
  a *running* daemon (no-op if none running). Scoped deliberately: this
  picks up behavior/keybind/rule/style changes live, but does **not**
  rebuild the topbar/bottombar/daemon-bar widget trees — so changing
  `buttons_top`/`buttons_bottom`/`buttons_daemon` visibility still needs a
  restart (Stop d, then Start d) to take effect. Kept simple on purpose;
  full live UI-structure reload is a lot of extra risk for a rarely-changed
  setting.
- **Config d** — opens `config.toml` via `xdg-open`.
- **Save** — dumps the current `dunstctl history` JSON to a timestamped file
  under `[general].history_save_dir` (default
  `~/.config/dunst-notif-center/history-saves/`).
- **Close** — closes the current window (same as Escape/click-outside).

### Click behavior

Left-click a row = expand (submenu). Right-click = reshow. (Swapped from
the previous version, per request.)

### New detection features

All of these are **opt-in and cost nothing when left off** — no path/color
scanning happens unless the relevant config option is turned on, and even
when it is, results are computed once per notification and cached, not
recomputed on every redraw.

**Path detection.** Scans both the header and body for a filesystem path —
tolerant of trailing sentence punctuation and quotes notifications commonly
stick onto paths (`"Saved to '/home/x/shot.png'."` correctly extracts
`/home/x/shot.png`), verified by progressively stripping trailing
characters and checking existence on disk each time. If both header and
body contain a path, `[general].path_priority` (`"body"` or `"header"`,
default `body`) decides which one wins. Classified into: `pictures`,
`videos`, `music`, `docs`, `text`, `code`, `archives`, `folders`,
`executables`, or `other`.

**Path-alias actions** (`[[path_actions]]` in config.toml) — attach submenu
actions per detected type, e.g. an "Edit" action running `gimp {path}` for
any notification with a picture path, regardless of which app sent it.
These stack on top of whatever `action_rules`/smart-guess already produced
for that notification, they don't replace it.

**Group by type** — new 4th grouping mode (cycle the Group button, or set
`default_group = "extension"`), buckets by the classification above.

**Color detection** (`[entry] detect_colors = true`) — if a hex (`#rrggbb`/
`#rgb`) or `rgb()`/`rgba()` color appears in the header or body, that row's
background gets tinted with it (opacity controlled by
`color_tint_opacity`, default 0.35, so text stays readable).

### Per-header styling (`[[header_style]]`)

Match by header (same glob syntax as `action_rules`, first match wins) to
set, per app: an icon shown immediately before the header text, and/or a
fallback appearance (flat color / background image / thumbnail) for when
path detection doesn't already supply one. Full priority order for a row's
appearance (highest first): **detected picture path** (needs
`pictures.show_preview` on) → **this rule's `background_image`/`thumbnail`**
→ **detected text color** (needs `entry.detect_colors` on) → **this rule's
`background_color`** → normal/default. So a specific screenshot's actual
image always wins over a generic per-app fallback, but an app with no
path in its notifications (e.g. Spotify) can still get a consistent themed
look via `background_color`/`background_image`.

### Picture previews (`[pictures]`, opt-in — off by default)

`show_preview = "thumbnail"` — a small image (`thumbnail_size`, default
48px) appears left of the body text; while the row is expanded, a bigger
version (`thumbnail_size_expanded`, default 128px) appears above the
submenu actions instead.

`show_preview = "background"` — the picture fills the row as a dimmed
background (cover-fit: scaled to fill, centered, cropped top/bottom as
needed — `dim_background` controls the darkening amount so overlaid text
stays legible). This automatically expands to cover the row's new height
when the submenu opens, with no special-case code — it repaints from the
row's *current* size on every frame, so it just tracks whatever the row's
actual size is at any moment. The submenu's own background becomes
transparent in this mode too (via a `.transparent-bg` CSS class), so the
expanding image stays visible behind the action list instead of being
hidden by it — hovering an individual option still shows a solid
highlight, since that's the button's own background, independent of the
now-transparent submenu container behind it.

Implementation note since I can't verify GTK rendering here: the background
mode deliberately does **not** use `Gtk.Overlay` (which was my first
instinct) — Overlay's "main" child drives both z-order *and* the widget's
size request, which would size the row off a bare image instead of its
actual text content and risk collapsing rows to near-zero height. Instead
it paints via a `draw` signal directly on the row's content box (paint the
image first, return `False`, let GTK's normal child-drawing continue on
top) — the standard GTK3 pattern for a custom background behind real
content, and it leaves the box's sizing completely untouched.

Regardless of mode, source images are always decoded at a bounded
resolution (`max_decode_width`, default 512px) — never full source
resolution — so a folder of raw screenshots can't balloon memory or CPU.

**Text shadow** (`[entry] text_shadow_*`) — applied only to rows whose
background differs from normal (color-tint or picture-background mode), so
text stays legible against a variable background without affecting normal
rows at all. Size/offset/blur/color all configurable; synthesized into a
small CSS snippet at startup (and on `Reload d`) rather than being fixed in
`style.css`, since these are meant to be tunable from config.toml directly.

### Icon customization (all opt-in, all fall back to current defaults)

- `[urgency_icons]` — replace the colored urgency dot with an image per
  urgency level (`low`/`normal`/`critical`). Leave blank to keep the dot.
- `[[header_style]]`'s `icon` field — a per-app icon immediately before the
  header text (see above).
- `[entry] close_icon` / `pin_icon` — replace the ✕/📌 glyphs with images.
  One caveat: the default 📌 glyph changes color via CSS when pinned; a
  custom image icon doesn't currently get that same visual feedback (color
  only affects text, not raster images) — same icon shown either way.

All icons (urgency/header/close/pin/thumbnails) go through a small bounded
cache (64 entries, evicts oldest) keyed by (path, size), so the same icon
file is never redecoded from disk repeatedly across rebuilds.

### Pin/close button visibility

`[entry] pin_close_visibility = "always"` (default, unchanged) or `"hover"`
— show pin/close on every row always, or only when hovering that row.

### Button label & command overrides

`[button_labels]` — replace any bottom-bar or top-bar button's text, e.g.
with an icon glyph instead of "Start d". `[sort_labels]`/`[group_labels]`
independently override the mode-name half of "Sort: Newest"/"Group: By
type", so e.g. `button_labels.sort` + `sort_labels.time_desc` together can
turn "Sort: Newest" into whatever icon combination you want. All default to
the current English text when left blank.

`[button_commands]` — override what Start d/Stop d/Reload d/Config d/Save
actually run, e.g. `reload_d = "systemctl --user reload-or-restart
dunst-notif-center.service"`. Takes priority over everything else,
including systemd auto-routing below.

### Systemd-aware daemon control

If `[general].systemd_service_name` is set, Start d/Stop d/Reload d route
through `systemctl --user start/stop/reload-or-restart <name>` instead of
the built-in socket-based control (`reload-or-restart` rather than plain
`reload` since we can't assume your unit defines `ExecReload=`).

If left blank, it's auto-detected on a best-effort basis by checking
whether the *current* process is itself running under a systemd user unit
(parses `/proc/self/cgroup`, matching the last `.service` segment — a
process's cgroup path nests multiple `.service` entries, e.g.
`user@1000.service` for the session manager and then the actual unit, so
this specifically takes the last/most specific one, not the first).
This only gives a useful answer when you're clicking the button from that
same daemon's own window — a one-shot window checking itself can't tell
you how some *other*, not-yet-running daemon should be managed, which is
why the explicit config option exists as the reliable path for that case.

**Bug fixed this round:** the detection was returning `user@1000.service`
itself as "the daemon's service" for *every* process, systemd-started or
not — that unit is the whole user session manager, present in every user
process's cgroup path regardless of how that specific process was
launched. It's now explicitly excluded, so a plain shell-started process
correctly detects as "not systemd" and falls through to the normal
socket-based control, exactly as it should. Verified against a plain-shell
cgroup path, a real per-app service path, and a terminal scope path.

### Close behavior

`[general].close_behavior` controls what closes the window:
- `click_outside` (default) — click anywhere outside the window. Two fixes
  applied this round based on what was actually broken: (1) the window
  never requested `BUTTON_PRESS_MASK` on itself, so even with the pointer
  successfully grabbed there was nothing telling GTK to deliver button
  events to the window in the first place — added `self.add_events(...)`
  at construction; (2) the grab was attempted via `GLib.idle_add()` after
  `show_all()`, which is a timing guess about when the window becomes
  mappable — replaced with grabbing on the `map-event` signal instead,
  which fires precisely when the window actually becomes visible on
  screen, for both the first one-shot show and every daemon toggle-show.
  I still can't verify this end-to-end without a real X11 session, but
  both were concrete, identifiable bugs, not guesses.
- `leave` — closes the instant the cursor physically leaves the window bounds.
- `focus_out` — closes when the window loses keyboard focus. On a
  focus-follows-mouse WM this behaves indistinguishably from `leave`.
- `none` — nothing auto-closes it; only Escape / your `close_window` keybind does.

### Nix

A `default.nix` is included, packaged the way nixpkgs would do it for a
single-script GTK app (`stdenv.mkDerivation` + `wrapGAppsHook3` + a
`python3.withPackages` env — `buildPythonApplication` wants a real
setup.py/pyproject.toml, which this doesn't have):

```sh
nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
./result/bin/dunst-notif-center
```

`dunstctl`/`dunst` is pulled in and put on `PATH` automatically via the
wrapper. Config/style still live in `~/.config/dunst-notif-center/` — the
Nix build only fixes where the *bundled defaults* get copied from on first
run (`$out/share/dunst-notif-center` instead of next to the script).

First run creates `~/.config/dunst-notif-center/config.toml` and `style.css`
from the bundled defaults — edit those, not the files next to the script.

**Note on testing:** I wrote and unit-tested the non-GTK logic (history JSON
parsing, the monotonic→wall-clock timestamp fix, action-rule matching, the
smart-guess fallback, fuzzy search) in isolation and confirmed it behaves
correctly. I don't have a GTK3/X11 display available in the environment I
wrote this in, so the actual window/widget behavior hasn't been visually
verified — expect to spend a little time on this to iron out layout quirks
once you run it for real. Flag anything broken and I'll fix it.

## What this is (and isn't)

This is a **client**, not a notification daemon — dunst is still the thing
receiving and rendering live notifications. This app only reads/manages dunst's
*history* and remote-controls dunst via `dunstctl`. That's the same relationship
SwayNotificationCenter has to mako/dunst-adjacent daemons.

## Resource-efficiency choices in this round

Every new feature this round was built to cost nothing when unused, and
bounded cost when used:
- Path/color detection only runs at all if the relevant config option
  (`show_preview`, `detect_colors`, or a `[[header_icons]]`/`[[path_actions]]`
  rule existing) is actually turned on — zero regex/filesystem work otherwise.
- Whatever detection *does* run is memoized on the `Notification` object
  itself (computed once, cached on the object), not recomputed on every
  rebuild/redraw/rescroll.
- Action resolution (including the new path-alias actions) stays lazy —
  only computed the first time a row's submenu is actually expanded, same
  as before this round.
- All image decoding (icons/thumbnails/backgrounds) goes through
  `new_from_file_at_scale()` with a bounded target size — never full source
  resolution — and through a small capped cache (64 entries, oldest evicted
  first) keyed by (path, size), so the same file never gets redecoded
  across rebuilds.
- No new subprocess spawns on any per-row or per-tick path — the new
  subprocess use (Save, Config d, Start d) is exclusively behind discrete
  button clicks, not anything that runs automatically or repeatedly.

## Other fixes this round

- **Hover-only pin/close (`pin_close_visibility = "hover"`) had two real
  bugs**, both from the same root cause: it used `.hide()`/`.show()`,
  but the window's own `show_all()` — called on every daemon toggle and
  once for one-shot — recursively force-shows *everything*, silently
  undoing the `.hide()` we'd done at row construction. That's why every
  row showed its buttons on first open regardless of the setting. It also
  meant hide/show was changing the row's actual allocated layout space,
  which is what caused the height jitter/bounce while cycling through
  rows. Fixed by switching to `opacity`/`sensitive` instead of
  `hide()`/`show()` — neither is touched by `show_all()`, and neither
  changes layout space, so both bugs shared one fix.
- **Window position drift in daemon mode**: some WMs apply their own
  placement/snapping *after* a window is mapped, which can override a
  pre-map `move()` and drift the window a few pixels per toggle. Now
  re-asserts position once more via `GLib.idle_add()` right after
  `present()`, on every toggle-show.
- **`Gtk.Widget.override_background_color` deprecation warning**: replaced
  with a tiny per-widget `Gtk.CssProvider` added via `add_provider()` (not
  `add_provider_for_screen()`), which scopes it to just that one row —
  same practical effect, no deprecated API, can't leak into/affect
  anything else on screen.

### Icon support for button labels

`[button_labels]`/`[sort_labels]`/`[group_labels]` values that end in
`.svg`/`.png`/`.jpg`/`.jpeg`/`.gif`/`.webp`/`.bmp` **and** point to a file
that actually exists are rendered as an icon instead of text —
`[button_labels].icon_size` controls the size. This applies uniformly to
every overridable button (bottom bars, and both halves of "Sort: Newest"/
"Group: By type" independently), so e.g. an icon for `sort` next to an
icon for `sort_labels.time_desc` gives you "🔽: 🆕"-style buttons if
that's what you want.

Built so the default (no icon configured) case is completely unaffected:
buttons only switch to the icon-capable rendering path when at least one
part actually resolves to an existing image file — otherwise it's the
exact same `Gtk.Button.set_label()` call as before this feature existed.

### Custom/extended extension groups

`[[extension_group_overrides]]` — add extensions to an existing built-in
group (e.g. treat `.png1` as a picture), remove extensions from one (e.g.
stop treating `.png` as a picture), or define an entirely new custom group
from scratch by giving a `group` name that isn't one of the built-ins.
Recomputed fresh from the built-ins on every load (including `Reload d`),
so repeated reloads don't accumulate stale state.

## Judgment calls I made on the ambiguous parts of the spec

- **"Reshow" semantics.** dunst has no "peek at history without touching it"
  primitive. The only reshow mechanism is `dunstctl history-pop <id>`, which
  removes the entry from history and re-fires it as a live notification; it
  lands back in history once you dismiss it. I mapped left-click, `s`, and
  the submenu "Show" entry directly onto this. Net effect from your POV: the
  notification pops up live again, then reappears in the list shortly after.
- **Timestamps.** `dunstctl history`'s `timestamp` field is
  `g_get_monotonic_time()` — microseconds since boot, not wall-clock time.
  I reconstruct real timestamps by diffing against the current monotonic
  clock at fetch time. This is exact as long as the system hasn't
  suspended/resumed in a way that skews the monotonic clock (rare on X11
  desktops, common on laptops with certain kernels) — flag it if you see
  drift and I'll switch to a periodic recalibration.
- **Missing `urgency` in history JSON.** Some dunst versions omit it
  (upstream issue #1425, being fixed upstream). I default to `"normal"` when
  absent rather than guessing from category/appname.
- **Config split.** Behavior/layout/keybinds/rules → `config.toml`.
  Colors/fonts/hover/animation-easing → `style.css` (real GTK CSS). This is
  the SwayNotificationCenter pattern, adapted to formats that are easier to
  hand-edit than JSON.
- **Action inference order** when a header has no configured rule: (1) URL in
  body → `xdg-open`, (2) an existing filesystem path in body → `xdg-open`,
  (3) a `.desktop` file matching the app name → `gtk-launch`, (4) nothing —
  you just get Clear/Show/Copy. Command substitution auto shell-quotes
  `{body}`/`{summary}`/`{appname}`/`{icon_path}`, so don't add your own
  quotes in `config.toml`.
- **Reshow no longer disturbs the list.** Previously, left-click/`s` called
  `history-pop` and then re-fetched+rebuilt the whole list from dunst, and
  since a popped notification is briefly *live* rather than *historical*,
  the very next fetch wouldn't include it — so it vanished, then reappeared
  in a possibly different spot once redismissed. Fixed structurally, not
  patched: the window now keeps its own session-local notification map that
  is **append-only except for explicit user removal** (clear / clear-all).
  A background dunst fetch merges in genuinely *new* notifications but never
  deletes an id just because one snapshot happens to omit it. Reshow itself
  doesn't trigger any re-fetch or re-render at all now — the row simply
  doesn't move.
- **Action resolution is lazy.** `resolve_actions()` — which can hit the
  filesystem (globbing `/usr/share/applications` for a matching `.desktop`
  file) — used to run for every row at window-build time, whether or not
  you ever opened that row's submenu. It's now deferred to first right-click
  expand and cached after that. This was the main addressable per-open cost
  on the Python side; the bulk of the original slowness was process/interpreter
  cold start, which daemon mode addresses separately (see README's Daemon
  mode section).
- **Pinned notifications** are stored as full snapshots in
  `~/.config/dunst-notif-center/pinned.json`, not just IDs — dunst's own
  history is a ring buffer and will happily forget an entry your pins file
  still remembers. On refresh, if dunst still has the entry we prefer its
  live data (updated urgency etc.); otherwise we fall back to the snapshot.
- **"Open history file"** — dunst doesn't persist history to a file on disk
  (it's in-memory only), so there's no literal file to open. I dump the
  current `dunstctl history` JSON to `/tmp/dunst-history-dump.json` and open
  that in `$EDITOR` (or `xdg-open` if unset). Good enough for "let me grep
  my history"; say the word if you'd rather this be a running log instead.
- **"Scroll" truncation mode** is currently rendered the same as no
  truncation (wrapped, not marquee-animated) — a real horizontally-scrolling
  marquee needs a per-row `GLib.timeout` + Pango layout offset that I didn't
  want to rush without being able to see it render. Flagging this as the one
  spec'd feature that's stubbed rather than implemented in this first pass.
- **Extension classification priority.** A file with both a recognized
  extension *and* the executable bit set (e.g. a `.sh`/`.py` script) is
  classified by its extension (`code`), not lumped into `executables` —
  that bucket is specifically for extension-less binaries/AppImages where
  the extension gives no information. Felt more useful than the reverse,
  but it's a judgment call, easy to flip in `classify_path()` if you'd
  rather executable-bit take priority.
- **`path_actions` matching**: applies whenever a path is detected and
  classified, independent of whether a `action_rules` header match also
  fired — both stack in the submenu rather than one replacing the other,
  since the request described them as additive ("these options would show
  in the submenu of notifs that has picture paths").
- **`ping` as an explicit message type**, not just "connect and disconnect
  without sending data." A bare connect-then-close reads as an empty
  message on the daemon side, and defaulting *that* to "toggle" would make
  "Start d"/every liveness check risk silently flashing the window open —
  so unrecognized/empty messages are a deliberate no-op, and `ping` exists
  specifically so "is a daemon running" checks (Start d, daemon_is_running)
  have zero side effects.
- **Header icon renamed to `[[header_style]]`** (was `[[header_icons]]`),
  extended with `background_color`/`background_image`/`thumbnail` fields
  alongside `icon` — one table matched by header instead of two separate
  ones, since they're conceptually the same "per-app appearance" concept
  and checking header-match twice per row would be redundant work.
- **Appearance priority order** (detected path > header rule's image/thumb
  > detected text color > header rule's flat color > none) — tested
  directly against 5 cases covering every tier winning over the one below
  it. The reasoning: a specific image actually in the notification should
  always beat a generic per-app fallback, and a color found in the
  notification's own text is more specific to that instance than a static
  per-app default.
- **Systemd detection takes the *last* `.service` match**, not the first —
  a process's own cgroup path nests multiple service units (the user
  session manager, then the actual unit), and naively taking the first
  match returns the wrong one. Caught by testing against a realistic
  cgroup path before shipping, not by inspection.

## Keybinds (default, all rebindable in config.toml)

| Key | Action |
|---|---|
| `q` | clear focused |
| `c` | copy focused |
| `Shift+q` | clear all |
| `s` | reshow focused |
| `Shift+s` | reshow all |
| `space` | expand/collapse focused |
| `→` | expand focused |
| `←` | collapse focused |
| `Enter` | run first/default action for focused |
| `↑`/`↓` | move selection (native GTK ListBox behavior) |
| `Escape` | close window |
| `/` | focus search |
| `h j k l` | vim nav, if `vim_keys = true` |

Left-click a row = expand + submenu (Clear/Show/Copy/actions). Right-click =
reshow. Click outside window = close (configurable, see above).

## Next iteration ideas (not yet built)

- Real marquee scroll for long bodies (still stubbed, see above)
- Drag-to-reorder pins
- Bigger/smaller thumbnail derived via `scale_simple()` from one decode
  instead of two separate file reads at different target sizes (minor;
  currently thumbnail mode's collapsed vs. expanded sizes each decode the
  source file once — bounded by `max_decode_width` either way, so not
  expensive, just not maximally efficient)

Let me know what breaks first when you actually run it against your dunst
setup and I'll iterate from there.
