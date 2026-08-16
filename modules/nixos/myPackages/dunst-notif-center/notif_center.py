#!/usr/bin/env python3
"""
dunst-notif-center — a full-featured notification history center for dunst/X11.

Reads history via `dunstctl history`, renders it as an interactive panel,
and drives dunst via `dunstctl` for show/clear/pause/reload/kill actions.

CLI:
    notif_center.py           plain invocation: shows/toggles a running
                               daemon if one exists, otherwise runs as a
                               one-shot window (built, shown, exits on close)
    notif_center.py -d        starts a background daemon (no window shown);
                               no-op if one is already running
    notif_center.py --quit    tells a running daemon to exit cleanly

Daemon mode exists purely for reopen speed: once started, later plain
invocations are a near-instant client that just tells the daemon to toggle
visibility over a Unix socket, never importing gi/GTK at all. One-shot mode
has no lingering process but pays GTK/gi's cold-start cost every launch.

Config:
    ~/.config/dunst-notif-center/config.toml   (behavior, keybinds, rules)
    ~/.config/dunst-notif-center/style.css     (GTK CSS — colors/fonts/hover/anim)
Both are created from bundled defaults on first run if missing.

See README.md for design notes and the judgment calls made on ambiguous parts
of the spec.
"""

# --- stdlib-only imports up top. Kept deliberately light: the common case
# (a daemon is already running) never needs to import gi/GTK at all. ---
import os
import re
import sys
import gc
import json
import time
import shlex
import fnmatch
import atexit
import ctypes
import socket
import subprocess
from dataclasses import dataclass
from datetime import datetime, timedelta
from pathlib import Path

try:
    import tomllib  # py3.11+
except ImportError:
    import tomli as tomllib  # pip install tomli

APP_DIR = Path.home() / ".config" / "dunst-notif-center"
CONFIG_PATH = APP_DIR / "config.toml"
STYLE_PATH = APP_DIR / "style.css"
# Nix packaging sets DUNST_NOTIF_CENTER_DATA_DIR to $out/share/dunst-notif-center
# (the script itself lives in $out/bin there, so __file__-relative lookup
# wouldn't find config.toml/style.css). Plain git-checkout usage falls back
# to the directory the script lives in.
BUNDLED_DIR = Path(os.environ.get(
    "DUNST_NOTIF_CENTER_DATA_DIR", str(Path(__file__).resolve().parent)
))

URGENCY_ORDER = {"critical": 0, "normal": 1, "low": 2, "unknown": 3}


# --------------------------------------------------------------------------- #
# Config
# --------------------------------------------------------------------------- #

def ensure_user_files():
    """Copy bundled config.toml / style.css into ~/.config on first run."""
    APP_DIR.mkdir(parents=True, exist_ok=True)
    if not CONFIG_PATH.exists():
        bundled = BUNDLED_DIR / "config.toml"
        if bundled.exists():
            CONFIG_PATH.write_text(bundled.read_text())
    if not STYLE_PATH.exists():
        bundled = BUNDLED_DIR / "style.css"
        if bundled.exists():
            STYLE_PATH.write_text(bundled.read_text())


def load_config() -> dict:
    ensure_user_files()
    with open(CONFIG_PATH, "rb") as f:
        return tomllib.load(f)


def expand(path_str: str) -> Path:
    return Path(os.path.expandvars(str(path_str))).expanduser()


def get_socket_path(cfg: dict) -> str:
    override = cfg.get("general", {}).get("socket_path", "")
    if override:
        return os.path.expandvars(os.path.expanduser(override))
    runtime_dir = os.environ.get("XDG_RUNTIME_DIR")
    if runtime_dir and os.path.isdir(runtime_dir):
        return os.path.join(runtime_dir, "dunst-notif-center.sock")
    return f"/tmp/dunst-notif-center-{os.getuid()}.sock"


# --------------------------------------------------------------------------- #
# Fast client path — no gi/GTK import, this is the whole point of daemon mode
# --------------------------------------------------------------------------- #

def try_notify_running_daemon(cfg: dict, message: str = "toggle") -> bool:
    """If a daemon is already listening, ping it and return True (handled).
    Returns False if no daemon is reachable (including a stale socket file
    left behind by a crashed daemon, which is cleaned up here)."""
    path = get_socket_path(cfg)
    if not os.path.exists(path):
        return False
    try:
        s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        s.settimeout(0.3)
        s.connect(path)
        s.sendall(message.encode() + b"\n")
        s.close()
        return True
    except OSError:
        try:
            os.remove(path)
        except OSError:
            pass
        return False


def daemon_is_running(cfg: dict) -> bool:
    """Reachability check with no side effects on the daemon (uses the
    explicit 'ping' message, which the daemon's dispatch recognizes and
    does nothing with — unlike connecting and closing without sending
    anything, which would read as an empty message and could be
    misinterpreted)."""
    return try_notify_running_daemon(cfg, message="ping")


def detect_own_systemd_unit() -> str:
    """Best-effort: if THIS process is running under a user systemd unit,
    return its name by parsing /proc/self/cgroup (works on cgroups v2, the
    default on any reasonably current Linux). Returns "" if not detected.

    Only tells us about the CURRENT process, not an arbitrary already-
    running daemon elsewhere — so this only gives a useful answer when
    called from the daemon's own window (clicking Reload d on a systemd-
    started daemon's own UI, say). For controlling a daemon from an
    unrelated one-shot window, [general].systemd_service_name is what
    makes that reliable; this is just a convenience for the common case."""
    try:
        with open("/proc/self/cgroup") as f:
            content = f.read()
        matches = re.findall(r"[\w.@-]+\.service", content)
        # user@<uid>.service is the systemd --user session manager itself
        # — it's present in EVERY user process's cgroup path, whether or
        # not that process was started as its own systemd unit. Excluding
        # it is what makes "not running under systemd" actually detectable
        # rather than always matching.
        app_matches = [m for m in matches if not re.fullmatch(r"user@\d+\.service", m)]
        if app_matches:
            return app_matches[-1]
    except OSError:
        pass
    return ""


def _effective_systemd_service(cfg: dict) -> str:
    configured = cfg["general"].get("systemd_service_name", "")
    return configured or detect_own_systemd_unit()


def start_daemon_process(cfg: dict):
    """Spawn a new background daemon if one isn't already running. No-op
    if one is (matches the 'start d' button's spec exactly)."""
    service = _effective_systemd_service(cfg)
    if service:
        subprocess.Popen(["systemctl", "--user", "start", service])
        return
    if daemon_is_running(cfg):
        return
    script = os.path.abspath(sys.argv[0])
    subprocess.Popen(
        [sys.executable, script, "-d"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        start_new_session=True,
    )


def stop_daemon_process(cfg: dict):
    service = _effective_systemd_service(cfg)
    if service:
        subprocess.Popen(["systemctl", "--user", "stop", service])
        return
    try_notify_running_daemon(cfg, message="quit")


def reload_daemon_process(cfg: dict):
    """No-op if no daemon is running (matches 'reload d' spec: 'reloads if
    it's running'). Uses reload-or-restart rather than plain reload for the
    systemd path since we can't assume the unit defines ExecReload=."""
    service = _effective_systemd_service(cfg)
    if service:
        subprocess.Popen(["systemctl", "--user", "reload-or-restart", service])
        return
    try_notify_running_daemon(cfg, message="reload")


# --------------------------------------------------------------------------- #
# Data model
# --------------------------------------------------------------------------- #

@dataclass
class Notification:
    id: int
    appname: str
    summary: str
    body: str
    category: str
    icon_path: str
    urgency: str
    timestamp_us: int
    dt: datetime
    urls: str = ""
    pinned: bool = False
    # Lazily computed and cached on first use (by grouping, actions, or
    # preview rendering — whichever needs it first) rather than eagerly for
    # every notification. None = not yet computed; "" = computed, nothing
    # found; otherwise the actual value.
    detected_path: object = None
    detected_color: object = None

    def to_dict(self):
        d = dict(self.__dict__)
        d["dt"] = self.dt.isoformat()
        return d

    @staticmethod
    def from_dict(d):
        d = dict(d)
        d["dt"] = datetime.fromisoformat(d["dt"])
        return Notification(**d)


def _field(entry: dict, key: str, default=None):
    v = entry.get(key)
    if isinstance(v, dict):
        return v.get("data", default)
    return default if v is None else v


def fetch_history() -> list:
    """Run `dunstctl history` and parse into Notification objects.

    dunstctl's history timestamp is g_get_monotonic_time() (microseconds
    since boot), NOT a wall-clock unix timestamp. We snapshot the current
    monotonic clock alongside wall-clock "now" once per fetch and diff
    against that, which gives an accurate real-world timestamp regardless
    of how long the machine has been up.
    """
    try:
        out = subprocess.run(
            ["dunstctl", "history"], capture_output=True, text=True, timeout=5
        )
    except FileNotFoundError:
        return []
    if out.returncode != 0 or not out.stdout.strip():
        return []

    try:
        obj = json.loads(out.stdout)
    except json.JSONDecodeError:
        return []

    data = obj.get("data", [])
    # Some dunst versions wrap history as an array-of-array ("aa{sv}");
    # others give a flat array. Normalize to a flat list of dicts.
    if len(data) == 1 and isinstance(data[0], list):
        data = data[0]

    now_wall = datetime.now()
    now_mono_us = int(time.clock_gettime(time.CLOCK_MONOTONIC) * 1_000_000)

    results = []
    for entry in data:
        if not isinstance(entry, dict):
            continue
        ts_us = _field(entry, "timestamp", now_mono_us)
        delta_us = now_mono_us - int(ts_us)
        dt = now_wall - timedelta(microseconds=delta_us)
        urgency = str(_field(entry, "urgency", "normal") or "normal").lower()
        if urgency not in URGENCY_ORDER:
            urgency = "unknown"
        results.append(
            Notification(
                id=int(_field(entry, "id", 0)),
                appname=str(_field(entry, "appname", "")),
                summary=str(_field(entry, "summary", "")),
                body=str(_field(entry, "body", "")),
                category=str(_field(entry, "category", "")),
                icon_path=str(_field(entry, "icon_path", "")),
                urgency=urgency,
                timestamp_us=int(ts_us),
                dt=dt,
                urls=str(_field(entry, "urls", "")),
            )
        )
    return results


# --------------------------------------------------------------------------- #
# dunstctl driver
# --------------------------------------------------------------------------- #

def dunstctl(*args) -> subprocess.CompletedProcess:
    return subprocess.run(["dunstctl", *args], capture_output=True, text=True)


def history_pop(nid: int):
    """'Reshow' a notification. dunst's only primitive for this is
    history-pop, which removes the entry from history and re-fires it live;
    it returns to history once dismissed. That's what backs left-click/'s'.

    IMPORTANT: callers must NOT trigger a re-fetch/re-render of the visible
    list right after this. dunst will briefly not report this id in
    `dunstctl history` (it's live, not historical) — re-rendering from a
    fresh fetch at that moment would make the row vanish and reappear
    out of place once it's dismissed again. The app's session-local
    notification list is deliberately append-only aside from explicit
    clears, specifically so this is a non-issue: the row just stays put.
    """
    dunstctl("history-pop", str(nid))


def history_rm(nid: int):
    dunstctl("history-rm", str(nid))


def history_clear():
    dunstctl("history-clear")


def set_paused(state: bool):
    dunstctl("set-paused", "true" if state else "false")


def is_paused() -> bool:
    r = dunstctl("is-paused")
    return r.stdout.strip() == "true"


def reload_dunst():
    dunstctl("reload")


def kill_dunst():
    subprocess.run(["pkill", "-x", "dunst"])


# --------------------------------------------------------------------------- #
# Pinned notifications (persisted across reboots)
# --------------------------------------------------------------------------- #

class PinStore:
    def __init__(self, path: Path):
        self.path = path
        self.pins = {}
        self.load()

    def load(self):
        self.pins.clear()
        if not self.path.exists():
            return
        try:
            raw = json.loads(self.path.read_text())
        except (json.JSONDecodeError, OSError):
            return
        for d in raw:
            try:
                n = Notification.from_dict(d)
                n.pinned = True
                self.pins[n.id] = n
            except (KeyError, ValueError):
                continue

    def save(self):
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(
            json.dumps([n.to_dict() for n in self.pins.values()], indent=2)
        )

    def is_pinned(self, nid: int) -> bool:
        return nid in self.pins

    def pin(self, n: Notification):
        n.pinned = True
        self.pins[n.id] = n
        self.save()

    def unpin(self, nid: int):
        self.pins.pop(nid, None)
        self.save()


# --------------------------------------------------------------------------- #
# Action resolution — deliberately NOT called at row-build time. It's the
# most expensive per-notification work (can hit the filesystem to look for a
# matching .desktop file), so rows resolve it lazily on first expand instead.
# --------------------------------------------------------------------------- #

URL_RE = re.compile(r"https?://\S+")

# --- Path detection ---------------------------------------------------------
# Notifications often embed a filesystem path in the body, frequently with
# trailing sentence punctuation or quotes stuck to it (e.g. "Saved to
# '/home/x/shot.png'."). Rather than trying to parse that away up front, we
# take the simplest robust approach: progressively strip trailing
# punctuation and re-check existence on disk each time — existence is the
# ground truth, so there's no risk of over- or under-stripping.
_PATH_CANDIDATE_RE = re.compile(r"(~?/[^\s]+)")
_TRAILING_PUNCT = ".,;:!?)]}'\"\u2018\u2019\u201c\u201d\u2013\u2014"


def extract_path(text: str):
    """First existing filesystem path found in text, or None. Cheap: a
    regex scan plus a handful of os.path.exists() stat calls at most."""
    for raw in _PATH_CANDIDATE_RE.findall(text):
        candidate = raw
        for _ in range(6):
            if not candidate:
                break
            expanded = os.path.expanduser(os.path.expandvars(candidate))
            if os.path.exists(expanded):
                return expanded
            if candidate[-1] in _TRAILING_PUNCT:
                candidate = candidate[:-1]
            else:
                break
    return None


_BUILTIN_EXTENSION_GROUPS = {
    "pictures": {".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp", ".svg", ".tiff", ".ico", ".heic"},
    "videos": {".mp4", ".mkv", ".webm", ".avi", ".mov", ".flv", ".wmv", ".m4v"},
    "music": {".mp3", ".flac", ".wav", ".ogg", ".m4a", ".aac", ".opus", ".wma"},
    "docs": {".pdf", ".doc", ".docx", ".odt", ".xls", ".xlsx", ".ppt", ".pptx", ".epub"},
    "text": {".txt", ".md", ".log", ".csv", ".json", ".yaml", ".yml", ".toml", ".ini", ".conf"},
    "code": {".py", ".js", ".ts", ".c", ".cpp", ".h", ".rs", ".go", ".java", ".sh", ".rb", ".php", ".html", ".css", ".vala"},
    "archives": {".zip", ".tar", ".gz", ".xz", ".7z", ".rar", ".bz2"},
}

# The *effective* groups classify_path() actually uses — starts as a copy
# of the built-ins; apply_extension_group_overrides() rebuilds this in
# place from config.toml's [[extension_group_overrides]]. Kept as a
# separate mutable name (not the built-in dict itself) so overrides can
# always be recomputed cleanly from scratch on config reload, rather than
# accumulating stale adds/removes across repeated reloads.
EXTENSION_GROUPS = {k: set(v) for k, v in _BUILTIN_EXTENSION_GROUPS.items()}


def apply_extension_group_overrides(cfg: dict):
    """Rebuilds EXTENSION_GROUPS from the built-ins plus config.toml's
    [[extension_group_overrides]] — each rule's `group` either extends an
    existing built-in group (add/remove extensions) or, if it names a new
    group, defines a custom one from scratch. Mutates the module-level
    EXTENSION_GROUPS dict in place (well, reassigns the global name — see
    below) so classify_path() and all its callers pick this up
    automatically with no changes needed on their end, since they already
    look up EXTENSION_GROUPS by module-level name at call time."""
    global EXTENSION_GROUPS
    groups = {k: set(v) for k, v in _BUILTIN_EXTENSION_GROUPS.items()}
    for rule in cfg.get("extension_group_overrides", []):
        name = rule.get("group", "")
        if not name:
            continue
        if name not in groups:
            groups[name] = set()
        for ext in rule.get("add", []):
            groups[name].add(str(ext).lower())
        for ext in rule.get("remove", []):
            groups[name].discard(str(ext).lower())
    EXTENSION_GROUPS = groups


def classify_path(path: str) -> str:
    """One of EXTENSION_GROUPS' keys, "folders", "executables", or "other"."""
    if os.path.isdir(path):
        return "folders"
    ext = os.path.splitext(path)[1].lower()
    for group, exts in EXTENSION_GROUPS.items():
        if ext in exts:
            return group
    if os.path.isfile(path) and os.access(path, os.X_OK):
        return "executables"
    return "other"


def get_detected_path(n: Notification, priority: str = "body") -> str:
    """Memoized: only ever computed once per notification, regardless of
    how many times grouping/actions/preview rendering ask for it. Scans
    both header and body; `priority` ("body" or "header") decides which
    one wins if both contain a path."""
    if n.detected_path is None:
        texts = (n.body, n.summary) if priority != "header" else (n.summary, n.body)
        found = ""
        for text in texts:
            found = extract_path(text)
            if found:
                break
        n.detected_path = found or ""
    return n.detected_path


# --- Color detection ---------------------------------------------------------
COLOR_HEX_RE = re.compile(r"#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\b")
COLOR_RGB_RE = re.compile(r"rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*[\d.]+\s*)?\)")


def detect_color(text: str):
    m = COLOR_HEX_RE.search(text)
    if m:
        return m.group(0)
    m = COLOR_RGB_RE.search(text)
    if m:
        r, g, b = (max(0, min(255, int(x))) for x in m.groups())
        return f"#{r:02x}{g:02x}{b:02x}"
    return None


def get_detected_color(n: Notification) -> str:
    """Memoized, same reasoning as get_detected_path()."""
    if n.detected_color is None:
        n.detected_color = detect_color(f"{n.summary} {n.body}") or ""
    return n.detected_color


def resolve_actions(n: Notification, action_rules: list, path_actions: list = (), path_priority: str = "body") -> list:
    """Return [(label, shell_command), ...] for a notification.

    1. First matching config rule (fnmatch on summary) wins, OR the
       smart-guess fallback if nothing matches (URL in body > existing path
       in body > launchable .desktop matching appname > nothing).
    2. If a path is detected and classified, path_actions rules matching
       that alias are appended on top of whichever of the above applied.
    """
    actions = []
    matched_rule = False
    for rule in action_rules:
        pattern = rule.get("match_header", "*")
        if fnmatch.fnmatchcase(n.summary, pattern):
            for a in rule.get("actions", []):
                cmd = _substitute(a.get("command", ""), n)
                actions.append((a.get("name", "action"), cmd))
            matched_rule = True
            break

    if not matched_rule:
        m = URL_RE.search(n.body)
        if m:
            url = m.group(0)
            actions.append(("Open link", f"xdg-open {shlex.quote(url)}"))
        else:
            path = get_detected_path(n, path_priority)
            if path:
                actions.append(("Open path", f"xdg-open {shlex.quote(path)}"))
            else:
                for appdir in ("/usr/share/applications", str(Path.home() / ".local/share/applications")):
                    p = Path(appdir)
                    if not p.exists():
                        continue
                    found = False
                    for f in p.glob(f"*{n.appname.lower()}*.desktop"):
                        actions.append((f"Open {n.appname}", f"gtk-launch {shlex.quote(f.stem)}"))
                        found = True
                        break
                    if found:
                        break

    path = get_detected_path(n, path_priority)
    if path and path_actions:
        alias = classify_path(path)
        for rule in path_actions:
            if rule.get("alias", "") == alias:
                for a in rule.get("actions", []):
                    cmd = _substitute(a.get("command", ""), n, path=path)
                    actions.append((a.get("name", "action"), cmd))
                break

    return actions


def _substitute(template: str, n: Notification, path: str = "") -> str:
    def q(s):
        return shlex.quote(str(s))
    return (
        template.replace("{body}", q(n.body))
        .replace("{summary}", q(n.summary))
        .replace("{appname}", q(n.appname))
        .replace("{icon_path}", q(n.icon_path))
        .replace("{path}", q(path))
    )


def run_shell(cmd: str):
    if cmd.strip():
        subprocess.Popen(["/bin/sh", "-c", cmd])


def _fuzzy_match(needle: str, haystack: str) -> bool:
    """Simple subsequence fuzzy match."""
    it = iter(haystack)
    return all(c in it for c in needle)


SORT_MODES = ["time_desc", "time_asc", "urgency", "header"]
SORT_LABELS = {"time_desc": "Newest", "time_asc": "Oldest", "urgency": "Urgency", "header": "A-Z"}
GROUP_MODES = ["none", "urgency", "header", "extension"]
GROUP_LABELS = {"none": "No group", "urgency": "By urgency", "header": "By header", "extension": "By type"}
CLOSE_BEHAVIORS = ("click_outside", "leave", "focus_out", "none")


# --------------------------------------------------------------------------- #
# GTK app (gi is only imported here — never on the fast client path)
# --------------------------------------------------------------------------- #

def run_daemon(cfg: dict, mode: str = "one-shot"):
    apply_extension_group_overrides(cfg)

    # These two shave real time off Gtk.init(): NO_AT_BRIDGE skips a DBus
    # round-trip to the accessibility bus that GTK otherwise attempts on
    # every startup (a well-known, often-overlooked chunk of GTK init
    # latency), and forcing the X11 backend skips Wayland-then-X11 backend
    # probing (irrelevant here anyway — this app is X11/dunst-specific).
    os.environ.setdefault("NO_AT_BRIDGE", "1")
    os.environ.setdefault("GDK_BACKEND", "x11")

    import gi
    gi.require_version("Gtk", "3.0")
    gi.require_version("Gdk", "3.0")
    gi.require_version("GdkPixbuf", "2.0")
    from gi.repository import Gtk, Gdk, GLib, Pango, GdkPixbuf

    # glibc keeps freed heap around for reuse rather than handing it back to
    # the OS. Python's own allocator sits on top of that and is even more
    # reluctant to release memory, which is the main reason a long-running
    # PyGObject daemon's RSS climbs after the first open and never comes
    # back down even once objects are freed. Explicitly asking glibc to
    # trim after a teardown-heavy operation (hiding the window, which drops
    # every NotifRow widget) is what actually returns that memory to the OS.
    try:
        _libc = ctypes.CDLL("libc.so.6")
    except OSError:
        _libc = None

    def trim_memory():
        gc.collect()
        if _libc is not None:
            try:
                _libc.malloc_trim(0)
            except Exception:
                pass

    class BoundedPixbufCache:
        """Small cache for decoded icons/thumbnails, keyed by (path, w, h).
        Bounded so a long-running daemon with many distinct picture
        notifications over its lifetime doesn't grow this unboundedly.
        Decoding always goes through new_from_file_at_scale, which
        downscales at load time rather than decoding full resolution then
        scaling — bounded memory/CPU cost regardless of source image size."""

        def __init__(self, max_entries=64):
            self.max_entries = max_entries
            self._cache = {}
            self._order = []

        def get(self, path, target_width, target_height=-1):
            key = (path, target_width, target_height)
            if key in self._cache:
                if key in self._order:
                    self._order.remove(key)
                self._order.append(key)
                return self._cache[key]
            try:
                pixbuf = GdkPixbuf.Pixbuf.new_from_file_at_scale(
                    path, target_width, target_height, True
                )
            except GLib.Error:
                pixbuf = None
            self._cache[key] = pixbuf
            self._order.append(key)
            if len(self._order) > self.max_entries:
                oldest = self._order.pop(0)
                self._cache.pop(oldest, None)
            return pixbuf

    def _draw_cover_background(widget, cr, pixbuf, dim_alpha):
        """Paints a cover-fit (scale-to-fill, crop excess, centered) image
        + optional dim overlay as the widget's background, using its
        *current* allocation — recomputed on every paint, so this
        automatically expands correctly when the row grows (submenu
        opened) with no special-case code needed. Connected as a normal
        (non-'after') 'draw' handler and returns False, so GTK's default
        handler still runs afterward and draws the widget's real children
        on top — this is the standard GTK3 pattern for a custom background
        behind normal content, and deliberately avoids Gtk.Overlay here:
        Overlay's "main" child drives both z-order AND the widget's size
        request, which would size the row off a bare image rather than its
        actual text content."""
        if pixbuf is None:
            return False
        alloc = widget.get_allocation()
        w, h = alloc.width, alloc.height
        pw, ph = pixbuf.get_width(), pixbuf.get_height()
        if w <= 0 or h <= 0 or pw <= 0 or ph <= 0:
            return False
        scale = max(w / pw, h / ph)
        sw, sh = pw * scale, ph * scale
        ox, oy = (w - sw) / 2.0, (h - sh) / 2.0
        cr.save()
        cr.translate(ox, oy)
        cr.scale(scale, scale)
        Gdk.cairo_set_source_pixbuf(cr, pixbuf, 0, 0)
        cr.paint()
        cr.restore()
        if dim_alpha > 0:
            cr.set_source_rgba(0, 0, 0, dim_alpha)
            cr.rectangle(0, 0, w, h)
            cr.fill()
        return False

    def _apply_color_tint(widget, rgba):
        """Non-deprecated replacement for Gtk.Widget.override_background_color:
        a tiny CSS provider added directly to this one widget's style
        context via add_provider() (not add_provider_for_screen()), which
        scopes it to just this widget — it can't affect anything else on
        screen, same practical effect as the old API without the
        deprecation warning. Only ever built for rows that actually have a
        detected/configured color (opt-in feature), so the extra CSS parse
        is real but narrow — nowhere near the cost of the image decoding
        this app already does for picture previews."""
        css = (
            "* { background-color: rgba(%d, %d, %d, %s); }"
            % (round(rgba.red * 255), round(rgba.green * 255), round(rgba.blue * 255), rgba.alpha)
        )
        provider = Gtk.CssProvider()
        try:
            provider.load_from_data(css.encode())
            widget.get_style_context().add_provider(provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION)
        except GLib.Error:
            pass

    _ICON_EXTENSIONS = (".svg", ".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp")

    def _make_label_part(win, text_or_path, size):
        """A single button-label 'part': an icon Image if text_or_path
        looks like an existing image file, otherwise a Label. Shared by
        every overridable button (bottom bars, sort/group), so icon
        support works uniformly without separate icon-vs-text config keys
        — whatever's in the label override string is just used as-is."""
        if text_or_path and text_or_path.lower().endswith(_ICON_EXTENSIONS):
            expanded = os.path.expanduser(text_or_path)
            if os.path.exists(expanded):
                pixbuf = win.pixbuf_cache.get(expanded, size, size)
                if pixbuf is not None:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
        return Gtk.Label(label=text_or_path)

    def _build_button_box(win, parts, size):
        """parts: list of text-or-icon-path strings. Multiple parts get a
        ':' separator (used for Sort:/Group: + mode name)."""
        box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=4)
        for i, part in enumerate(parts):
            if i > 0:
                box.pack_start(Gtk.Label(label=":"), False, False, 0)
            box.pack_start(_make_label_part(win, part, size), False, False, 0)
        box.show_all()
        return box

    def _make_urgency_indicator(win, urgency):
        """Icon (if configured for this urgency and the file exists) or the
        original colored dot — unchanged default behavior either way."""
        icon_path = win.cfg.get("urgency_icons", {}).get(urgency, "")
        if icon_path:
            expanded = os.path.expanduser(icon_path)
            if os.path.exists(expanded):
                size = win.cfg.get("urgency_icons", {}).get("icon_size", 12)
                pixbuf = win.pixbuf_cache.get(expanded, size, size)
                if pixbuf is not None:
                    return Gtk.Image.new_from_pixbuf(pixbuf)
        dot = Gtk.Box()
        dot.get_style_context().add_class("urgency-dot")
        dot.get_style_context().add_class(f"urgency-{urgency}")
        return dot

    def _find_header_style(win, summary):
        """The first matching [[header_style]] rule for this header, or
        None. Cheap fnmatch scan over a typically-tiny config list."""
        for rule in win.cfg.get("header_style", []):
            if fnmatch.fnmatchcase(summary, rule.get("match_header", "*")):
                return rule
        return None

    def _resolve_row_appearance(win, notif, header_rule):
        """Priority-resolved cell appearance: (image_path, mode, color_hex)
        where mode is 'background' | 'thumbnail' | 'color' | 'none'.
        Priority (highest first): detected picture path > header_style's
        background_image/thumbnail > detected text color > header_style's
        background_color > none."""
        pic_cfg = win.cfg.get("pictures", {})
        show_preview = pic_cfg.get("show_preview", "none")
        priority = win.cfg["general"].get("path_priority", "body")

        if show_preview != "none":
            p = get_detected_path(notif, priority)
            if p and classify_path(p) == "pictures":
                return (p, show_preview, None)

        if header_rule:
            bg_image = header_rule.get("background_image", "")
            if bg_image:
                expanded = os.path.expanduser(bg_image)
                if os.path.exists(expanded):
                    return (expanded, "background", None)
            thumb = header_rule.get("thumbnail", "")
            if thumb:
                expanded = os.path.expanduser(thumb)
                if os.path.exists(expanded):
                    return (expanded, "thumbnail", None)

        if win.cfg["entry"].get("detect_colors", False):
            color_hex = get_detected_color(notif)
            if color_hex:
                return (None, "color", color_hex)

        if header_rule:
            color = header_rule.get("background_color", "")
            if color:
                return (None, "color", color)

        return (None, "none", None)

    def _make_icon_button(win, css_class, custom_icon_key, default_glyph, handler):
        """Pin/close button: custom icon (if configured and the file
        exists) or the original text-glyph button — unchanged default
        either way."""
        custom_path = win.cfg["entry"].get(custom_icon_key, "")
        btn = None
        if custom_path:
            expanded = os.path.expanduser(custom_path)
            if os.path.exists(expanded):
                size = win.cfg["entry"].get("icon_button_size", 14)
                pixbuf = win.pixbuf_cache.get(expanded, size, size)
                if pixbuf is not None:
                    btn = Gtk.Button()
                    btn.set_image(Gtk.Image.new_from_pixbuf(pixbuf))
        if btn is None:
            btn = Gtk.Button(label=default_glyph)
        btn.get_style_context().add_class(css_class)
        btn.set_relief(Gtk.ReliefStyle.NONE)
        btn.connect("clicked", handler)
        return btn

    class NotifRow(Gtk.ListBoxRow):
        def __init__(self, win, notif: Notification):
            super().__init__()
            self.win = win
            self.notif = notif
            self.expanded = False
            self._actions_built = False
            self.get_style_context().add_class("notif-row")
            if notif.pinned:
                self.get_style_context().add_class("pinned")

            wcfg = win.cfg
            header_rule = _find_header_style(win, notif.summary)
            appearance_path, appearance_mode, appearance_color = _resolve_row_appearance(win, notif, header_rule)
            self._pic_path = appearance_path if appearance_mode in ("background", "thumbnail") else None
            self._preview_mode = appearance_mode

            if appearance_mode == "color" and appearance_color:
                rgba = Gdk.RGBA()
                if rgba.parse(appearance_color):
                    rgba.alpha = wcfg["entry"].get("color_tint_opacity", 0.35)
                    _apply_color_tint(self, rgba)

            # Text shadow only for rows whose background actually differs
            # from normal (color tint or picture background) — a fixed,
            # small set of CSS classes toggled per row, not per-row CSS
            # generation (see load_css() for where the actual shadow values
            # get synthesized into CSS once, at startup/reload).
            needs_shadow = appearance_mode in ("color", "background") and wcfg["entry"].get("text_shadow_enabled", True)

            self.revealer = Gtk.Revealer()
            self.revealer.set_reveal_child(True)
            self.revealer.set_transition_type(
                Gtk.RevealerTransitionType.SLIDE_DOWN
                if wcfg["general"]["animations"] else Gtk.RevealerTransitionType.NONE
            )
            self.add(self.revealer)

            outer = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            self.revealer.add(outer)

            # Background-picture mode: paint the cover-fit image as outer's
            # background via a draw signal (see _draw_cover_background for
            # why this is used instead of Gtk.Overlay). outer's own size is
            # completely unaffected — still driven entirely by its normal
            # children — so this only ever adds a paint callback, never
            # changes layout/sizing behavior. Only rows that actually have
            # a resolved background image pay for this at all.
            if appearance_mode == "background" and appearance_path:
                pic_cfg = wcfg.get("pictures", {})
                bg_pixbuf = win.pixbuf_cache.get(appearance_path, pic_cfg.get("max_decode_width", 512), -1)
                if bg_pixbuf is not None:
                    dim_alpha = pic_cfg.get("dim_background", 0.55)
                    outer.connect("draw", _draw_cover_background, bg_pixbuf, dim_alpha)

            ev = Gtk.EventBox()
            ev.connect("button-press-event", self.on_click)
            outer.pack_start(ev, False, False, 0)

            content = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            content.set_margin_top(6)
            content.set_margin_bottom(6)
            content.set_margin_start(8)
            content.set_margin_end(8)
            if needs_shadow:
                content.get_style_context().add_class("text-shadow-cell")
            ev.add(content)

            # Line 1: urgency indicator, timestamp, header icon, header, pin, close
            line1 = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            content.pack_start(line1, False, False, 0)

            line1.pack_start(_make_urgency_indicator(win, notif.urgency), False, False, 0)

            if wcfg["timestamp"]["show"]:
                ts_label = Gtk.Label(label=notif.dt.strftime(wcfg["timestamp"]["format"]))
                ts_label.get_style_context().add_class("notif-timestamp")
                line1.pack_start(ts_label, False, False, 0)

            # Header icon sits immediately before the header text (per-app
            # icon, e.g. Flameshot's logo) — packed after the timestamp
            # rather than before it, so it's adjacent to what it's labeling.
            if header_rule:
                icon_path = header_rule.get("icon", "")
                if icon_path:
                    expanded = os.path.expanduser(icon_path)
                    if os.path.exists(expanded):
                        size = wcfg["entry"].get("header_icon_size", 16)
                        pixbuf = win.pixbuf_cache.get(expanded, size, size)
                        if pixbuf is not None:
                            line1.pack_start(Gtk.Image.new_from_pixbuf(pixbuf), False, False, 0)

            header = Gtk.Label(label=notif.summary or notif.appname or "(no title)")
            header.get_style_context().add_class("notif-header")
            header.set_xalign(0)
            header.set_ellipsize(Pango.EllipsizeMode.END)
            header.set_hexpand(True)
            line1.pack_start(header, True, True, 0)

            hover_only = wcfg["entry"].get("pin_close_visibility", "always") == "hover"

            self.pin_btn = None
            if wcfg["entry"]["show_pin_button"]:
                self.pin_btn = _make_icon_button(
                    win, "notif-pin-btn", "pin_icon", "\U0001F4CC", self.on_pin_clicked
                )
                if notif.pinned:
                    self.pin_btn.get_style_context().add_class("active")
                line1.pack_start(self.pin_btn, False, False, 0)

            self.close_btn = None
            if wcfg["entry"]["show_close_button"]:
                self.close_btn = _make_icon_button(
                    win, "notif-close-btn", "close_icon", "\u2715", self.on_close_clicked
                )
                line1.pack_start(self.close_btn, False, False, 0)

            if hover_only:
                ev.add_events(Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK)
                ev.connect("enter-notify-event", self._on_hover_enter)
                ev.connect("leave-notify-event", self._on_hover_leave)

            # Line 2: body (thumbnail mode prepends a small image)
            body_label = Gtk.Label(label=notif.body)
            body_label.get_style_context().add_class("notif-body")
            body_label.set_xalign(0)
            trunc = wcfg["entry"]["truncate_mode"]
            if trunc == "truncate":
                body_label.set_ellipsize(Pango.EllipsizeMode.END)
                body_label.set_lines(wcfg["entry"]["body_max_lines"])
                body_label.set_line_wrap(True)
            elif trunc == "none":
                body_label.set_line_wrap(True)

            if appearance_mode == "thumbnail" and appearance_path:
                pic_cfg = wcfg.get("pictures", {})
                thumb_size = pic_cfg.get("thumbnail_size", 48)
                thumb_pixbuf = win.pixbuf_cache.get(appearance_path, thumb_size, thumb_size)
                line2 = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
                if thumb_pixbuf is not None:
                    line2.pack_start(Gtk.Image.new_from_pixbuf(thumb_pixbuf), False, False, 0)
                line2.pack_start(body_label, True, True, 0)
                content.pack_start(line2, False, False, 0)
            else:
                content.pack_start(body_label, False, False, 0)

            # Line 3: submenu (revealed on right-click). Clear/Show/Copy are
            # built now (cheap); per-notification actions (and, in
            # thumbnail mode, the bigger expanded preview) are resolved
            # lazily in _ensure_actions_built(), only if the row is ever
            # expanded.
            self.submenu_revealer = Gtk.Revealer()
            self.submenu_revealer.set_transition_type(
                Gtk.RevealerTransitionType.SLIDE_DOWN
                if wcfg["general"]["animations"] else Gtk.RevealerTransitionType.NONE
            )
            outer.pack_start(self.submenu_revealer, False, False, 0)

            self.submenu = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=2)
            self.submenu.get_style_context().add_class("notif-submenu")
            if appearance_mode == "background":
                # Otherwise the submenu's opaque background would hide the
                # picture that's expanding to cover it. Hovering an
                # individual option still shows a solid highlight (see
                # .submenu-item:hover in style.css) so you can tell which
                # one you're on even with a transparent submenu behind it.
                self.submenu.get_style_context().add_class("transparent-bg")
            if needs_shadow:
                self.submenu.get_style_context().add_class("text-shadow-cell")
            self.submenu_revealer.add(self.submenu)

            sm_cfg = wcfg["submenu"]
            if sm_cfg["show_clear"]:
                self.submenu.pack_start(self._submenu_btn("Clear", self.on_close_clicked), False, False, 0)
            if sm_cfg["show_show"]:
                self.submenu.pack_start(self._submenu_btn("Show", lambda *_: self.win.reshow(self.notif)), False, False, 0)
            if sm_cfg["show_copy"]:
                self.submenu.pack_start(self._submenu_btn("Copy", lambda *_: self.win.copy_notif(self.notif)), False, False, 0)

            self.show_all()
            if hover_only:
                # opacity+sensitive, NOT hide()/show(): the window's own
                # show_all() (called on every daemon toggle, and once for
                # one-shot) recursively force-shows every descendant,
                # which would silently undo a hide() done here — opacity
                # isn't touched by show_all() at all, so it actually stays
                # applied. This also keeps the button's layout space
                # reserved even while "hidden", which is what stops row
                # height from jittering by a pixel or two as you hover
                # across rows (hide()/show() actually changes the
                # allocated space; opacity doesn't).
                if self.pin_btn is not None:
                    self.pin_btn.set_opacity(0.0)
                    self.pin_btn.set_sensitive(False)
                if self.close_btn is not None:
                    self.close_btn.set_opacity(0.0)
                    self.close_btn.set_sensitive(False)

        def _on_hover_enter(self, widget, event):
            if self.pin_btn is not None:
                self.pin_btn.set_opacity(1.0)
                self.pin_btn.set_sensitive(True)
            if self.close_btn is not None:
                self.close_btn.set_opacity(1.0)
                self.close_btn.set_sensitive(True)
            return False

        def _on_hover_leave(self, widget, event):
            if event.detail == Gdk.NotifyType.INFERIOR:
                return False  # moved onto a child widget, not actually left
            if self.pin_btn is not None:
                self.pin_btn.set_opacity(0.0)
                self.pin_btn.set_sensitive(False)
            if self.close_btn is not None:
                self.close_btn.set_opacity(0.0)
                self.close_btn.set_sensitive(False)
            return False

        def _ensure_actions_built(self):
            if self._actions_built:
                return
            self._actions_built = True

            wcfg = self.win.cfg
            pic_cfg = wcfg.get("pictures", {})
            if self._pic_path and self._preview_mode == "thumbnail":
                big_size = pic_cfg.get("thumbnail_size_expanded", 128)
                big_pixbuf = self.win.pixbuf_cache.get(self._pic_path, big_size, big_size)
                if big_pixbuf is not None:
                    big_img = Gtk.Image.new_from_pixbuf(big_pixbuf)
                    big_img.set_margin_bottom(4)
                    self.submenu.pack_start(big_img, False, False, 0)
                    self.submenu.reorder_child(big_img, 0)

            rules = wcfg.get("action_rules", [])
            path_actions = wcfg.get("path_actions", [])
            priority = wcfg["general"].get("path_priority", "body")
            for name, cmd in resolve_actions(self.notif, rules, path_actions, priority):
                self.submenu.pack_start(
                    self._submenu_btn(name, lambda *_, c=cmd: run_shell(c)), False, False, 0
                )
            self.submenu.show_all()

        def _submenu_btn(self, label, handler):
            b = Gtk.Button(label=label)
            b.get_style_context().add_class("submenu-item")
            b.set_relief(Gtk.ReliefStyle.NONE)
            b.connect("clicked", handler)
            return b

        def on_click(self, widget, event):
            if event.type != Gdk.EventType.BUTTON_PRESS:
                return False
            if event.button == 1:
                self.toggle_expand()
                return True
            elif event.button == 3:
                self.win.reshow(self.notif)
                return True
            return False

        def toggle_expand(self):
            if not self.expanded:
                self._ensure_actions_built()
                if self.win.cfg["general"]["close_on_expand_other"]:
                    self.win.collapse_all_except(self)
            self.expanded = not self.expanded
            self.submenu_revealer.set_reveal_child(self.expanded)
            ctx = self.get_style_context()
            if self.expanded:
                ctx.add_class("expanded")
            else:
                ctx.remove_class("expanded")

        def collapse(self):
            if self.expanded:
                self.expanded = False
                self.submenu_revealer.set_reveal_child(False)
                self.get_style_context().remove_class("expanded")

        def on_pin_clicked(self, *_):
            self.win.toggle_pin(self.notif)

        def on_close_clicked(self, *_):
            self.win.clear_notif(self, self.notif)

    class NotifCenterWindow(Gtk.Window):
        def __init__(self, cfg: dict):
            super().__init__(title="Notification Center")
            self.cfg = cfg
            self.is_daemon = False  # set explicitly by main()/run_daemon() after construction
            self.pins = PinStore(expand(cfg["general"]["pinned_file"]))
            self.sort_mode = cfg["general"]["default_sort"]
            self.group_mode = cfg["general"]["default_group"]
            self.search_text = ""
            self.rows = []
            self.notifications = {}  # id -> Notification, session-local truth
            self._grabbed = False
            self.pixbuf_cache = BoundedPixbufCache(max_entries=64)

            self.add_events(Gdk.EventMask.BUTTON_PRESS_MASK)
            self.set_type_hint(Gdk.WindowTypeHint.UTILITY)
            self.set_skip_taskbar_hint(cfg["window"]["skip_taskbar"])
            self.set_decorated(False)
            self.set_default_size(cfg["window"]["width"], cfg["window"]["height"])
            self.get_style_context().add_class("notif-center-window")
            self.set_name("notif-center-window")

            root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            self.add(root)

            self._build_topbar(root)

            scroller = Gtk.ScrolledWindow()
            scroller.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
            root.pack_start(scroller, True, True, 0)

            self.listbox = Gtk.ListBox()
            self.listbox.set_selection_mode(Gtk.SelectionMode.SINGLE)
            self.listbox.set_filter_func(self._filter_func)
            scroller.add(self.listbox)

            self._build_bottombar(root)
            self._build_daemon_bar(root)

            self.connect("key-press-event", self.on_key_press)
            self.connect("realize", self.on_realize)
            self._wire_close_behavior()

            self._merge_from_dunst()
            self._rebuild_listbox()

            poll_ms = cfg["general"].get("poll_interval_ms", 0)
            if poll_ms:
                GLib.timeout_add(poll_ms, self._poll_tick)

        # ---- close behavior ----

        def _wire_close_behavior(self):
            behavior = self.cfg["general"].get("close_behavior", "click_outside")
            if behavior not in CLOSE_BEHAVIORS:
                behavior = "click_outside"
            if behavior == "focus_out":
                self.connect("focus-out-event", lambda *_a: (self.request_close(), False)[1])
            elif behavior == "leave":
                self.connect("leave-notify-event", self._on_leave_notify)
            elif behavior == "click_outside":
                self.connect("button-press-event", self._on_button_press_check_outside)
                # map-event fires every time the window actually becomes
                # visible on screen — both the first one-shot show and every
                # daemon toggle-show — which is a more reliable point to grab
                # than scheduling an idle callback after show_all()/present()
                # and hoping the window is mapped by then.
                self.connect("map-event", lambda *_a: (self._grab_for_click_outside(), False)[1])
            # "none": nothing wired up; only Escape/keybind closes.

        def _on_leave_notify(self, widget, event):
            # NotifyType.INFERIOR fires when the pointer moves onto a child
            # widget within the same window, not when it actually leaves —
            # ignore that case or every internal mouse-move would close us.
            if event.detail == Gdk.NotifyType.INFERIOR:
                return False
            self.request_close()
            return False

        def _on_button_press_check_outside(self, widget, event):
            alloc = self.get_allocation()
            wx, wy = getattr(self, "_cached_x", 0), getattr(self, "_cached_y", 0)
            inside = (wx <= event.x_root <= wx + alloc.width and
                      wy <= event.y_root <= wy + alloc.height)
            if not inside:
                self.request_close()
            return False

        def _grab_for_click_outside(self):
            gdkwin = self.get_window()
            if gdkwin is None:
                return False
            seat = Gdk.Display.get_default().get_default_seat()
            status = seat.grab(
                gdkwin, Gdk.SeatCapabilities.ALL_POINTING, True, None, None, None, None
            )
            self._grabbed = (status == Gdk.GrabStatus.SUCCESS)
            return False

        def _ungrab(self):
            if self._grabbed:
                Gdk.Display.get_default().get_default_seat().ungrab()
                self._grabbed = False

        def request_close(self):
            if self.is_daemon:
                self.hide()
                self._on_hide_cleanup()
            else:
                Gtk.main_quit()

        def _on_hide_cleanup(self):
            self._ungrab()
            for r in self.rows:
                r.collapse()
            # Actually free the row widgets while hidden — self.notifications
            # (the cheap data) stays in memory so reopening just rebuilds
            # widgets from it, but PyGObject widget instances are the real
            # memory cost of an idle daemon and there's no reason to keep
            # hundreds of them allocated while nobody can see them.
            for child in self.listbox.get_children():
                self.listbox.remove(child)
            self.rows.clear()
            trim_memory()

        # ---- visibility (daemon mode) ----

        def toggle_visible(self):
            if self.get_visible():
                self.hide()
                self._on_hide_cleanup()
            else:
                self._merge_from_dunst()
                self._rebuild_listbox()
                self._position_window()
                self.show_all()
                self.present()
                self.listbox.grab_focus()
                # Some WMs apply their own placement/snapping logic AFTER
                # a window is actually mapped, which can override the
                # move() above and drift the window a few pixels on each
                # toggle. Re-asserting position once more on the next main
                # loop iteration (after the map has actually happened)
                # corrects that instead of letting it accumulate.
                GLib.idle_add(self._reassert_position_once)

        def _reassert_position_once(self):
            self._position_window()
            return False

        # ---- layout ----

        def _label(self, key, default):
            val = self.cfg.get("button_labels", {}).get(key, "")
            return val if val else default

        def _render_button_content(self, button, parts):
            """Sets a button's displayed content from a list of
            text-or-icon-path parts. Uses the small icon+text box only if
            at least one part actually resolves to an existing icon file
            — otherwise (the common case: no icon overrides configured)
            this is just button.set_label(...), identical to how these
            buttons worked before icon support existed. Works for both
            initial construction (button starts as a bare Gtk.Button())
            and later updates (sort/group cycling, pause/resume toggling)."""
            size = self.cfg.get("button_labels", {}).get("icon_size", 14)
            any_icon = any(
                p and p.lower().endswith(_ICON_EXTENSIONS) and os.path.exists(os.path.expanduser(p))
                for p in parts
            )
            if any_icon:
                old_child = button.get_child()
                if old_child is not None:
                    button.remove(old_child)
                button.add(_build_button_box(self, parts, size))
                button.show_all()
            else:
                button.set_label(": ".join(parts))

        def _sort_button_parts(self):
            prefix = self._label("sort", "Sort")
            mode_label = self.cfg.get("sort_labels", {}).get(self.sort_mode, "") or SORT_LABELS[self.sort_mode]
            return [prefix, mode_label]

        def _group_button_parts(self):
            prefix = self._label("group", "Group")
            mode_label = self.cfg.get("group_labels", {}).get(self.group_mode, "") or GROUP_LABELS[self.group_mode]
            return [prefix, mode_label]

        def _build_topbar(self, root):
            cfg = self.cfg
            if not cfg["buttons_top"]["show"]:
                return
            bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            bar.set_name("topbar")
            root.pack_start(bar, False, False, 0)

            if cfg["buttons_top"]["show_search"]:
                self.search_entry = Gtk.SearchEntry()
                self.search_entry.set_name("search-entry")
                self.search_entry.connect("search-changed", self.on_search_changed)
                bar.pack_start(self.search_entry, True, True, 0)
            else:
                bar.pack_start(Gtk.Box(), True, True, 0)

            if cfg["buttons_top"]["show_sort"]:
                self.sort_btn = Gtk.Button()
                self._render_button_content(self.sort_btn, self._sort_button_parts())
                self.sort_btn.get_style_context().add_class("topbar-btn")
                self.sort_btn.connect("clicked", self.on_cycle_sort)
                bar.pack_start(self.sort_btn, False, False, 0)

            if cfg["buttons_top"]["show_group"]:
                self.group_btn = Gtk.Button()
                self._render_button_content(self.group_btn, self._group_button_parts())
                self.group_btn.get_style_context().add_class("topbar-btn")
                self.group_btn.connect("clicked", self.on_cycle_group)
                bar.pack_start(self.group_btn, False, False, 0)

        def _build_bottombar(self, root):
            cfg = self.cfg
            if not cfg["buttons_bottom"]["show"]:
                return
            bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            bar.set_name("bottombar")
            root.pack_start(bar, False, False, 0)

            def btn(label, handler):
                b = Gtk.Button()
                self._render_button_content(b, [label])
                b.get_style_context().add_class("bottombar-btn")
                b.connect("clicked", handler)
                bar.pack_start(b, True, True, 0)
                return b

            if cfg["buttons_bottom"]["show_clear_all"]:
                btn(self._label("clear_all", "Clear all"), lambda *_: self.clear_all())
            if cfg["buttons_bottom"]["show_pause_resume"]:
                paused_now = is_paused()
                label = self._label("resume", "Resume") if paused_now else self._label("pause", "Pause")
                self.pause_btn = btn(label, lambda *_: self.on_toggle_pause())
                if paused_now:
                    self.pause_btn.get_style_context().add_class("checked")
            if cfg["buttons_bottom"]["show_reload"]:
                btn(self._label("reload", "Reload"), lambda *_: self._reload_and_refresh())
            if cfg["buttons_bottom"]["show_kill"]:
                btn(self._label("kill", "Kill"), lambda *_: kill_dunst())
            if cfg["buttons_bottom"]["show_open_history"]:
                btn(self._label("open_log", "Open log"), lambda *_: self.open_history_in_editor())

        def _build_daemon_bar(self, root):
            cfg = self.cfg
            if not cfg["buttons_daemon"]["show"]:
                return
            bar = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=6)
            bar.set_name("daemonbar")
            root.pack_start(bar, False, False, 0)

            def btn(label, handler):
                b = Gtk.Button()
                self._render_button_content(b, [label])
                b.get_style_context().add_class("bottombar-btn")
                b.connect("clicked", handler)
                bar.pack_start(b, True, True, 0)
                return b

            def daemon_action(key, default_fn):
                cmd = self.cfg.get("button_commands", {}).get(key, "")
                if cmd:
                    run_shell(cmd)
                else:
                    default_fn()

            if cfg["buttons_daemon"]["show_start"]:
                btn(self._label("start_d", "Start d"),
                    lambda *_: daemon_action("start_d", lambda: start_daemon_process(self.cfg)))
            if cfg["buttons_daemon"]["show_stop"]:
                btn(self._label("stop_d", "Stop d"),
                    lambda *_: daemon_action("stop_d", lambda: stop_daemon_process(self.cfg)))
            if cfg["buttons_daemon"]["show_reload"]:
                btn(self._label("reload_d", "Reload d"),
                    lambda *_: daemon_action("reload_d", lambda: reload_daemon_process(self.cfg)))
            if cfg["buttons_daemon"]["show_config"]:
                btn(self._label("config_d", "Config d"),
                    lambda *_: daemon_action("config_d", lambda: subprocess.Popen(["xdg-open", str(CONFIG_PATH)])))
            if cfg["buttons_daemon"]["show_save"]:
                btn(self._label("save", "Save"),
                    lambda *_: daemon_action("save", self.save_history_snapshot))
            if cfg["buttons_daemon"]["show_close"]:
                btn(self._label("close", "Close"), lambda *_: self.request_close())

        def save_history_snapshot(self):
            save_dir = expand(self.cfg["general"].get(
                "history_save_dir", "~/.config/dunst-notif-center/history-saves"
            ))
            save_dir.mkdir(parents=True, exist_ok=True)
            ts = datetime.now().strftime("%Y%m%d-%H%M%S")
            path = save_dir / f"history-{ts}.json"
            raw = dunstctl("history").stdout
            path.write_text(raw)

        def on_realize(self, *_):
            self._position_window()

        def _position_window(self):
            cfg = self.cfg["window"]
            display = Gdk.Display.get_default()
            monitor = display.get_primary_monitor() or display.get_monitor(0)
            geo = monitor.get_geometry()
            w, h = cfg["width"], cfg["height"]
            mx, my = cfg["margin_x"], cfg["margin_y"]
            anchor = cfg["anchor"]
            if anchor == "top-right":
                x, y = geo.x + geo.width - w - mx, geo.y + my
            elif anchor == "top-left":
                x, y = geo.x + mx, geo.y + my
            elif anchor == "bottom-right":
                x, y = geo.x + geo.width - w - mx, geo.y + geo.height - h - my
            elif anchor == "bottom-left":
                x, y = geo.x + mx, geo.y + geo.height - h - my
            else:
                x, y = geo.x + (geo.width - w) // 2, geo.y + (geo.height - h) // 2
            self.move(x, y)
            self._cached_x, self._cached_y = x, y
            if cfg["always_on_top"]:
                self.set_keep_above(True)

        # ---- session-local data model ----
        #
        # self.notifications is append-only aside from explicit user-driven
        # removal (clear/clear-all). A periodic dunst fetch is MERGED into
        # it — ids we already know about are never dropped just because a
        # given `dunstctl history` snapshot doesn't include them (e.g. right
        # after a reshow, when dunst is briefly displaying it live instead
        # of holding it in history). This is what makes reshow non-disruptive.

        def _merge_from_dunst(self):
            live = fetch_history()
            for n in live:
                if n.id in self.notifications:
                    existing = self.notifications[n.id]
                    existing.urgency = n.urgency
                    existing.timestamp_us = n.timestamp_us
                    existing.dt = n.dt
                    existing.body = n.body
                    existing.summary = n.summary
                else:
                    self.notifications[n.id] = n
            for nid, pinned_n in self.pins.pins.items():
                if nid in self.notifications:
                    self.notifications[nid].pinned = True
                else:
                    self.notifications[nid] = pinned_n

        def _sort_entries(self, entries):
            if self.sort_mode == "time_desc":
                return sorted(entries, key=lambda n: -n.timestamp_us)
            if self.sort_mode == "time_asc":
                return sorted(entries, key=lambda n: n.timestamp_us)
            if self.sort_mode == "urgency":
                return sorted(entries, key=lambda n: (URGENCY_ORDER.get(n.urgency, 9), -n.timestamp_us))
            if self.sort_mode == "header":
                return sorted(entries, key=lambda n: (n.summary.lower(), -n.timestamp_us))
            return entries

        def _group_key(self, n: Notification) -> str:
            if self.group_mode == "urgency":
                return n.urgency
            if self.group_mode == "extension":
                path = get_detected_path(n, self.cfg["general"].get("path_priority", "body"))
                return classify_path(path) if path else "no path"
            return n.summary or "(no header)"  # "header" mode

        def _rebuild_listbox(self):
            selected_id = None
            row = self.listbox.get_selected_row()
            if row is not None and hasattr(row, "notif"):
                selected_id = row.notif.id

            for child in self.listbox.get_children():
                self.listbox.remove(child)
            self.rows.clear()

            entries = list(self.notifications.values())
            pinned_entries = sorted([n for n in entries if n.pinned], key=lambda n: -n.timestamp_us)
            rest = self._sort_entries([n for n in entries if not n.pinned])

            if self.group_mode == "none":
                for n in pinned_entries + rest:
                    self._add_row(n)
            else:
                for n in pinned_entries:
                    self._add_row(n)
                groups, order = {}, []
                for n in rest:
                    key = self._group_key(n)
                    if key not in groups:
                        groups[key] = []
                        order.append(key)
                    groups[key].append(n)
                order.sort(key=(lambda k: URGENCY_ORDER.get(k, 9)) if self.group_mode == "urgency" else None)
                for key in order:
                    self._add_group_header(key)
                    for n in groups[key]:
                        self._add_row(n)

            if selected_id is not None:
                for r in self.rows:
                    if r.notif.id == selected_id:
                        self.listbox.select_row(r)
                        break

        def _add_row(self, n: Notification):
            row = NotifRow(self, n)
            self.listbox.add(row)
            self.rows.append(row)

        def _add_group_header(self, text: str):
            row = Gtk.ListBoxRow()
            row.set_selectable(False)
            row.set_activatable(False)
            lbl = Gtk.Label(label=text.title())
            lbl.set_xalign(0)
            lbl.set_margin_top(6)
            lbl.set_margin_start(8)
            lbl.get_style_context().add_class("notif-header")
            row.add(lbl)
            self.listbox.add(row)
            row.show_all()

        def _poll_tick(self):
            self._merge_from_dunst()
            self._rebuild_listbox()
            return True

        # ---- filtering / search ----

        def on_search_changed(self, entry):
            self.search_text = entry.get_text().strip().lower()
            self.listbox.invalidate_filter()

        def _filter_func(self, row):
            if not self.search_text:
                return True
            if not hasattr(row, "notif"):
                return True
            n = row.notif
            haystack = f"{n.summary} {n.body} {n.appname}".lower()
            return _fuzzy_match(self.search_text, haystack)

        # ---- sort/group cycling (re-render from memory, no re-fetch) ----

        def on_cycle_sort(self, *_):
            i = (SORT_MODES.index(self.sort_mode) + 1) % len(SORT_MODES)
            self.sort_mode = SORT_MODES[i]
            self._render_button_content(self.sort_btn, self._sort_button_parts())
            self._rebuild_listbox()

        def on_cycle_group(self, *_):
            i = (GROUP_MODES.index(self.group_mode) + 1) % len(GROUP_MODES)
            self.group_mode = GROUP_MODES[i]
            self._render_button_content(self.group_btn, self._group_button_parts())
            self._rebuild_listbox()

        # ---- actions ----

        def reshow(self, n: Notification):
            # Deliberately does NOT touch self.notifications or re-render —
            # see the docstring on history_pop() for why.
            history_pop(n.id)

        def copy_notif(self, n: Notification):
            text = f"{n.summary}\n{n.body}" if n.body else n.summary
            clipboard = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)
            clipboard.set_text(text, -1)
            clipboard.store()

        def clear_notif(self, row: "NotifRow", n: Notification):
            def do_remove():
                history_rm(n.id)
                self.notifications.pop(n.id, None)
                if n.pinned:
                    self.pins.unpin(n.id)
                self._rebuild_listbox()
                return False

            if self.cfg["general"]["animations"]:
                row.revealer.set_reveal_child(False)
                GLib.timeout_add(180, do_remove)
            else:
                do_remove()

        def clear_all(self):
            history_clear()
            self.notifications.clear()
            for nid in list(self.pins.pins.keys()):
                self.pins.unpin(nid)
            self._rebuild_listbox()
            trim_memory()

        def toggle_pin(self, n: Notification):
            if self.pins.is_pinned(n.id):
                self.pins.unpin(n.id)
                n.pinned = False
            else:
                self.pins.pin(n)
                n.pinned = True
            self._rebuild_listbox()

        def on_toggle_pause(self):
            new_state = not is_paused()
            set_paused(new_state)
            label = self._label("resume", "Resume") if new_state else self._label("pause", "Pause")
            self._render_button_content(self.pause_btn, [label])
            ctx = self.pause_btn.get_style_context()
            if new_state:
                ctx.add_class("checked")
            else:
                ctx.remove_class("checked")

        def _reload_and_refresh(self):
            """The bottom bar's 'Reload' button. Previously this only called
            `dunstctl reload` (reloading dunst's OWN config) without ever
            refreshing our displayed list, so nothing visibly changed."""
            reload_dunst()
            self._merge_from_dunst()
            self._rebuild_listbox()

        def open_history_in_editor(self):
            editor = os.path.expandvars(self.cfg["general"]["editor"])
            if not editor or editor == "$EDITOR":
                editor = "xdg-open"
            tmp = Path("/tmp/dunst-history-dump.json")
            r = dunstctl("history")
            tmp.write_text(r.stdout)
            subprocess.Popen([editor, str(tmp)])

        def collapse_all_except(self, keep):
            for r in self.rows:
                if r is not keep:
                    r.collapse()

        # ---- keybinds ----

        def on_key_press(self, widget, event):
            keybinds = self.cfg["keybinds"]
            keyval_name = Gdk.keyval_name(event.keyval) or ""

            def matches(bind_str):
                try:
                    kv, mods = Gtk.accelerator_parse(bind_str)
                except Exception:
                    return False
                state = event.state & ~Gdk.ModifierType.LOCK_MASK
                return event.keyval == kv and (state & mods) == mods and \
                    (mods != 0 or state & (Gdk.ModifierType.SHIFT_MASK | Gdk.ModifierType.CONTROL_MASK) == 0
                     or bind_str.startswith("<"))

            row = self.listbox.get_selected_row()

            if matches(keybinds["close_window"]):
                self.request_close()
                return True
            if matches(keybinds["focus_search"]) and hasattr(self, "search_entry"):
                self.search_entry.grab_focus()
                return True
            if row is None or not hasattr(row, "notif"):
                return False

            if matches(keybinds["clear_all"]):
                self.clear_all()
                return True
            if matches(keybinds["show_all"]):
                for n in list(self.notifications.values()):
                    history_pop(n.id)
                return True
            if matches(keybinds["clear_focused"]):
                self.clear_notif(row, row.notif)
                return True
            if matches(keybinds["copy_focused"]):
                self.copy_notif(row.notif)
                return True
            if matches(keybinds["show_focused"]):
                self.reshow(row.notif)
                return True
            if matches(keybinds["expand_focused"]):
                row.toggle_expand()
                return True
            if matches(keybinds["nav_right"]):
                if not row.expanded:
                    row.toggle_expand()
                return True
            if matches(keybinds["nav_left"]):
                row.collapse()
                return True
            if matches(keybinds["activate"]):
                actions = resolve_actions(
                    row.notif, self.cfg.get("action_rules", []), self.cfg.get("path_actions", []),
                    self.cfg["general"].get("path_priority", "body")
                )
                if actions:
                    run_shell(actions[0][1])
                return True

            if self.cfg["general"]["vim_keys"]:
                if keyval_name == "j":
                    self._move_selection(1)
                    return True
                if keyval_name == "k":
                    self._move_selection(-1)
                    return True
                if keyval_name == "l":
                    if not row.expanded:
                        row.toggle_expand()
                    return True
                if keyval_name == "h":
                    row.collapse()
                    return True
            return False

        def _move_selection(self, direction: int):
            cur = self.listbox.get_selected_row()
            idx = self.rows.index(cur) if cur in self.rows else 0
            idx = max(0, min(len(self.rows) - 1, idx + direction))
            if self.rows:
                self.listbox.select_row(self.rows[idx])

    # ---- CSS (wrapped in a function so 'reload d' can re-apply it) ----

    _css_provider_holder = [None, None]  # [file-based, dynamic-from-config]

    def load_css(active_cfg):
        screen = Gdk.Screen.get_default()
        for i in (0, 1):
            if _css_provider_holder[i] is not None:
                Gtk.StyleContext.remove_provider_for_screen(screen, _css_provider_holder[i])
                _css_provider_holder[i] = None

        provider = Gtk.CssProvider()
        try:
            provider.load_from_path(str(STYLE_PATH))
            Gtk.StyleContext.add_provider_for_screen(
                screen, provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )
            _css_provider_holder[0] = provider
        except GLib.Error as e:
            print(f"Failed to load style.css: {e}", file=sys.stderr)

        # Text-shadow values are configurable (not fixed in style.css), so
        # synthesize a small CSS snippet from config and load it as a
        # second provider at slightly higher priority so it always applies
        # regardless of style.css. Takes active_cfg as an explicit
        # parameter (not a closure over the outer cfg) specifically so
        # 'reload d' — which calls this with a freshly re-read config —
        # actually picks up new values instead of whatever was loaded at
        # daemon startup.
        ecfg = active_cfg.get("entry", {})
        ox = ecfg.get("text_shadow_offset_x", 1)
        oy = ecfg.get("text_shadow_offset_y", 1)
        blur = ecfg.get("text_shadow_blur", 2)
        color = ecfg.get("text_shadow_color", "rgba(0,0,0,0.8)")
        dynamic_css = f".text-shadow-cell label {{ text-shadow: {ox}px {oy}px {blur}px {color}; }}"
        dyn_provider = Gtk.CssProvider()
        try:
            dyn_provider.load_from_data(dynamic_css.encode())
            Gtk.StyleContext.add_provider_for_screen(
                screen, dyn_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION + 1
            )
            _css_provider_holder[1] = dyn_provider
        except GLib.Error as e:
            print(f"Failed to load dynamic text-shadow CSS: {e}", file=sys.stderr)

    load_css(cfg)
    win = NotifCenterWindow(cfg)

    if mode == "daemon":
        win.is_daemon = True
        sock_path = get_socket_path(cfg)
        if os.path.exists(sock_path):
            os.remove(sock_path)
        server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        server.bind(sock_path)
        server.listen(5)
        server.setblocking(False)

        def cleanup(*_a):
            try:
                server.close()
            except OSError:
                pass
            if os.path.exists(sock_path):
                try:
                    os.remove(sock_path)
                except OSError:
                    pass

        atexit.register(cleanup)

        def do_reload():
            # Re-read config.toml/style.css and refresh the list. Deliberately
            # scoped: this does NOT rebuild the topbar/bottombar/daemonbar
            # widget trees, so changes to buttons_top/buttons_bottom/
            # buttons_daemon visibility still need a restart (stop d, start
            # d) to take effect — everything else (behavior, keybinds,
            # action/path_actions rules, colors/fonts/hover states, sort/
            # group defaults for the NEXT window open) picks up live.
            new_cfg = load_config()
            win.cfg = new_cfg
            apply_extension_group_overrides(new_cfg)
            load_css(new_cfg)
            win._merge_from_dunst()
            win._rebuild_listbox()

        def on_socket_ready(source, condition):
            try:
                conn, _addr = server.accept()
                data = conn.recv(1024).decode().strip()
                conn.close()
            except OSError:
                return True
            if data == "quit":
                cleanup()
                Gtk.main_quit()
            elif data == "reload":
                do_reload()
            elif data == "toggle":
                win.toggle_visible()
            # "ping" (liveness check) or anything unrecognized: no-op.
            # Deliberately NOT defaulting to toggle here — a bare connect
            # that closes without sending data would read as an empty
            # message, and silently toggling the window on that would be a
            # confusing side effect for what's meant to be a safe check.
            return True

        GLib.io_add_watch(server, GLib.IO_IN, on_socket_ready)
        win.connect("destroy", lambda *_a: (cleanup(), Gtk.main_quit()))
        # Deliberately NOT showing the window here — `-d` starts the daemon
        # in the background only; a plain (no-flag) invocation is what
        # shows it, via the "toggle" message above.
    else:
        win.is_daemon = False
        win.connect("destroy", Gtk.main_quit)
        win.show_all()

    Gtk.main()


# --------------------------------------------------------------------------- #
# Entry point
# --------------------------------------------------------------------------- #

def main():
    cfg = load_config()
    args = sys.argv[1:]

    if "--quit" in args:
        try_notify_running_daemon(cfg, message="quit")
        return

    if "-d" in args or "--daemon" in args:
        if daemon_is_running(cfg):
            return  # already running; don't double-bind the socket
        run_daemon(cfg, mode="daemon")
        return

    # Plain invocation: toggle an already-running daemon (fast path — never
    # imports gi/GTK), or fall back to a one-shot window if none is running.
    if try_notify_running_daemon(cfg, message="toggle"):
        return
    run_daemon(cfg, mode="one-shot")


if __name__ == "__main__":
    main()
