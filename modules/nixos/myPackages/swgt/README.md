# SWGT - Simple Widget

A lightweight X11 widget that displays multiple pages of toggleable buttons with custom icons and appears when the mouse cursor reaches the right edge of the screen.

![image](https://github.com/user-attachments/assets/2973bafc-6a92-48c4-b0b6-b7f9e6bd8e17)

## Features

- **Multi-page support** with configurable navigation
- **Smart input handling** - only captures keyboard input when mouse is over widget
- **Arrow key navigation** between pages (Up/Down or Left/Right)
- **Mouse wheel scrolling** support
- **Configurable default page** that opens first
- Slide-in animation from screen edge
- Multiple toggleable buttons with custom icons and text
- Each button executes different commands for on/off states
- Visual feedback with active/inactive states
- High-quality text rendering with Xft
- Configurable colors and fonts
- Low resource usage
- Customizable through config.h

## Navigation

### Keyboard Controls (only when mouse is over widget)
- **Vertical mode (default)**: Up/Down arrows, W/S, K/J
- **Horizontal mode**: Left/Right arrows, A/D, H/L
- **Page Up/Down**: Navigate pages
- **Home/End**: Jump to first/last page
- **Number keys (1-9)**: Jump directly to specific pages
- **Escape**: Close widget

### Mouse Controls
- **Click**: Toggle buttons
- **Mouse wheel**: Scroll between pages
- **Hover**: Show/hide widget

## Input Handling

The widget uses smart input handling that only captures keyboard events when your mouse cursor is over the widget window. This prevents it from interfering with other applications and ensures normal system behavior when the widget is not in use.

## Dependencies

- X11 development libraries
- Xft development libraries
- FontConfig development libraries
- GCC compiler

On Debian/Ubuntu:
```bash
sudo apt install libx11-dev libxext-dev libxft-dev libfontconfig1-dev build-essential
```

On Arch Linux:
```bash
sudo pacman -S libx11 libxext libxft fontconfig base-devel
```

## Building

- **dev**: Fast compilation with debug symbols (`-g -O0`)
- **release**: Maximum optimization (`-O3 -march=native -flto`)

```bash
# Development
make dev

# Release
make release

# Clean
make clean
```

## Configuration

Edit `config.h` to customize:

### Page Settings
- `DEFAULT_PAGE`: Which page shows first (0-based)
- `SCROLL_DIRECTION`: Set to `SCROLL_VERTICAL` or `SCROLL_HORIZONTAL`
- `MAX_PAGES`: Number of pages
- `BUTTONS_PER_PAGE`: Buttons per page

### Appearance
- Widget dimensions and colors (hex format)
- Animation settings
- Font preferences (Xft fonts)
- Page indicator styling

### Button Configuration
- Icons, text, and commands for each page
- Toggle/untoggle commands per button
- Click-only vs toggle behavior

## Installation

```bash
# Build and install to /usr/local/bin
make release install

# Uninstall
make uninstall
```

## Usage

Simply run the executable:
```bash
./swgt
```
Or if installed use:
```bash
swgt
```

The widget will appear when you move your mouse to the right edge of the screen. Navigate between pages using arrow keys, WASD/HJKL, or mouse wheel. The widget starts on the configured default page and supports both vertical and horizontal navigation modes.
