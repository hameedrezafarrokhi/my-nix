# NAME

xpymon - A versatile WiFi/network/battery/CPU/video system monitor on Linux

![screenshot](https://raw.githubusercontent.com/h-ohsaki/xpymon/master/screenshot/xpymon.png)

# SYNOPSIS

xpywm

# DESCRIPTION

This manual page documents **xpymon**, a minimal but versatile system monitor
on Linux.  **xpymon** is designed to work with **xpywm**, a simple but
extensible X11 window manager written in Python
(https://pypi.org/project/xpywm/).  However, **xpymon** can be used
independently and be combined with other window managers.

**xpymon** consumes the minimum amount of the desktop; i.e., the height of the
statsu monitor window is just eight pixels.

# OPTIONS

- -T

  Run in test mode.

# CUSTOMIZATION

On startup, **xpymon** loads per-user RC script (`~/.xpymonrc`) if it exists.
The RC script is any valid Python script.  You can change the behavior of
**xpymon** using the RC file.

An example `~/.xpymonrc` file is as follows.

```python
# blink status monitor when the remaining battery capacity is less than 10%
global BATTERY_WARN_THRESH
BATTERY_WARN_THRESH = .1
```

# REQUIREMENTS

The implementation of **xpymon** heavily depends on the Linux kernel (/proc
and /sys pseudo filesystems) and its standard utilities such as ip (iproute2),
ifconfig (net-tools), and iwconfig (wireless-tools).

# INSTALLATION

```sh
$ sudo apt install iproute2 net-tools wireless-tools 
$ pip3 install xpymon
```

# AVAILABILITY

The latest version of **xpymon** is available at PyPI
(https://pypi.org/project/xpymon/) .

# SEE ALSO

xpywm(1), ip(8), iwconfig(8), ifconfig(8), xrandr(1), zdump(8), proc(5)

# AUTHOR

Hiroyuki Ohsaki <code[atmark]lsnl.jp>
