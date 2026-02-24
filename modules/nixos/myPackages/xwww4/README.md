# XWWW
Animated wallpaper transitions for X11.

This was inspired by [awww](https://codeberg.org/LGFae/awww) (the wayland wallpaper daemon with animated transitions, formerly known as [swww](https://github.com/LGFae/swww)). It is not a swww/awww replacement. It uses [FFMPEG](https://www.ffmpeg.org/) and hsetroot.

### Demo
[Watch Demo](https://github.com/user-attachments/assets/9c59f6bc-7b02-4ec5-8f88-762e0cc05c00)

### Dependencies
* `bash`
* `ffmpeg`
* `hsetroot`
* `feh`


### Installation

Install dependencies from your distros package manager.

#### AUR
In progress...

#### Automatic

**WARNING: Read any script before running it on your system.**
```bash
curl https://raw.githubusercontent.com/hameedrezafarrokhi/xwww/main/install.sh | bash -;
```

### Manual
```bash
git clone https://github.com/hameedrezafarrokhi/xwww
cd xwww
sudo make install
```



### List of Animations

* fade
* slide-up, slide-down, slide-right, slide-left
* oblique-right, oblique-left
* circle-in, circle-out
* pixelate
* wave
* spin
* open
* close

### Configuration

You can set the total number of frames generated, the frame-time of each frame and the default animation in the `$XDG_CONFIG_DIR/xwww/xwwwrc` (`$HOME/.config/xwww/xwwwrc`) file.

example:
```bash
SLEEP=0.001
FRAMES=14
ANIMATION="fade"
```

FRAMES is the totall amount of frames and SLEEP is the sleep time between frames. If no user config is available the default values will be used, which are: 14 0.001 "fade". 


### Usage

* Run 'xwww' to see general usage
```bash
xwww
```

* Set an image
```bash
xwww "$HOME/Pictures/wallpapers/wallpaper.png"
```

* You can override the default or the config values with flags
```bash
xwww "$HOME/Pictures/wallpapers/wallpaper.png" --frame 20 --speed 0.1 --animation slide-up
```

* more options will be made in the future like using other wallpaper setters, gpu acceleration, more flags etc.

### How it works
It uses ffmpeg to generate transition frames and applies them using hsetroot.


### Limitations & Issues

* At the moment it is a very janky solution, but it kinda sorta works for now. It is not fully optimised yet. Work in progress...
* It is VERY resouce intensive and hardware dependent. Older cpus might struggle a bit. newer cpus should be ok (ish).
* Currently the only fast and optimised animation is "fade" which works well. other animations might take a few seconds to load.
* The speed of the transitions can't be increased, because of how hsetroot works. At the moment there's nothing I can do about that. I'll try other tools in the future.
* For small images i.e. under 1mg, it's good and fast. 5-10mg is hardware dependent (cpu, ram, drive and gpu in the future). Above 20mg would be definitly slow to load. 
* It only works correctly for 1920x1080 images, for now.
* I haven't tested on multi-monitors.


### Please Help Me :)

* If you can give me feedback on how it works on different hardware, it would really help me optimising it.
* If you see any bugs and jank, or any ideas/suggestions on other transitions/effects, please let me know.
* If you want to make your own transition effects see the examples in the repo and create one with ffmpeg.
* Using ffmpeg was really callenging for me. If anyone has experience with ffmpeg and can help me optimise it, I would really appreciate the help.
