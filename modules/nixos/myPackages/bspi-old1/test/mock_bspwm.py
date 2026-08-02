#!/usr/bin/env python3
"""Minimal stand-in for bspwm's socket server, just enough to exercise
bspi's IPC/JSON/rename code paths without a real X session."""
import socket, os, sys, threading, time, json, signal

SOCK_PATH = sys.argv[1] if len(sys.argv) > 1 else "/tmp/bspi_test_bspwm-socket"
if os.path.exists(SOCK_PATH):
    os.remove(SOCK_PATH)

FAILURE = b"\x07"

state = {
    "monitors": [
        {
            "name": "eDP-1",
            "desktops": [
                {
                    "id": 100,
                    "name": "WRONG-NAME",
                    "root": {
                        "id": 200,
                        "sticky": False,
                        "client": None,
                        "firstChild": {
                            "id": 201,
                            "sticky": False,
                            "client": {"className": "firefox"},
                            "firstChild": None,
                            "secondChild": None,
                        },
                        "secondChild": {
                            "id": 202,
                            "sticky": False,
                            # deliberately empty className to exercise the
                            # WM_CLASS-via-XCB fallback path (which will
                            # just fail gracefully here, no real X server)
                            "client": {"className": ""},
                            "firstChild": None,
                            "secondChild": None,
                        },
                    },
                },
                {
                    "id": 101,
                    "name": "",
                    "root": None,  # empty desktop -> should become "_other" icon
                },
                {
                    "id": 102,
                    # already correct - alacritty's icon from bspi.ini
                    "name": "\uf120",
                    "root": {
                        "id": 210,
                        "sticky": False,
                        "client": {"className": "Alacritty"},
                        "firstChild": None,
                        "secondChild": None,
                    },
                },
                {
                    # THE BUG CASE: this desktop has no windows of its own,
                    # but a sticky window has been transferred into it (as
                    # bspwm does when it's the focused desktop on its
                    # monitor). Should resolve to "_other", NOT "".
                    "id": 103,
                    "name": "some-stale-name",
                    "root": {
                        "id": 220,
                        "sticky": True,
                        "client": {"className": "Kitty", "instanceName": "kitty"},
                        "firstChild": None,
                        "secondChild": None,
                    },
                },
                {
                    # An ignored-by-class window with nothing else on the
                    # desktop should also resolve to "_other".
                    "id": 104,
                    "name": "another-stale-name",
                    "root": {
                        "id": 230,
                        "sticky": False,
                        "client": {"className": "Zoom", "instanceName": "zoom"},
                        "firstChild": None,
                        "secondChild": None,
                    },
                },
            ],
        }
    ]
}

renames = []


def handle(conn):
    data = b""
    conn.settimeout(1.0)
    try:
        while True:
            chunk = conn.recv(4096)
            if not chunk:
                break
            data += chunk
            # crude "did we get at least one full message" heuristic for
            # this test server: bspc-style messages are NUL separated and
            # we just wait a tiny bit for more, then process.
            break
    except socket.timeout:
        pass

    args = [a for a in data.split(b"\x00") if a != b""]
    if not args:
        conn.close()
        return
    cmd = [a.decode() for a in args]
    print("mock bspwm received:", cmd, file=sys.stderr)

    if cmd[:2] == ["wm", "-d"]:
        conn.sendall(json.dumps(state).encode())
        conn.close()
        return

    if cmd[0] == "subscribe":
        # Stream one dummy report line every 200ms forever, to trigger
        # bspi's debounce+rescan loop.
        try:
            while True:
                conn.sendall(b"dummy-report-line\n")
                time.sleep(0.2)
        except (BrokenPipeError, OSError):
            pass
        return

    if cmd[0] == "desktop" and "--rename" in cmd:
        desk_id = int(cmd[1])
        name = cmd[3]
        renames.append((desk_id, name))
        for mon in state["monitors"]:
            for d in mon["desktops"]:
                if d["id"] == desk_id:
                    d["name"] = name
        conn.sendall(b"")
        conn.close()
        return

    conn.sendall(FAILURE + b"unknown command in mock server\n")
    conn.close()


def main():
    srv = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    srv.bind(SOCK_PATH)
    srv.listen(16)
    print(f"mock bspwm listening on {SOCK_PATH}", file=sys.stderr)

    def cleanup(*_):
        try:
            os.remove(SOCK_PATH)
        except OSError:
            pass
        sys.exit(0)

    signal.signal(signal.SIGTERM, cleanup)
    signal.signal(signal.SIGINT, cleanup)

    try:
        while True:
            conn, _ = srv.accept()
            t = threading.Thread(target=handle, args=(conn,), daemon=True)
            t.start()
    finally:
        cleanup()


if __name__ == "__main__":
    main()
