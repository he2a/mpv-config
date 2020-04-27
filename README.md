# MPV Config for Windows Build (No Vulkan)
<p align="center"><img src="https://raw.githubusercontent.com/he2a/mpv-config/master/images/screen.jpg"></p>

## Overview
Just my personal config files for use in mpv. Contains custom forced keybindings and optimized for anime media. Currently there is a problem with display-resample and interpolation when used with vulkan in AMD and so vulkan is not used. The source of various lua scripts are mentioned in the file source and are in some cases modified a little from original code.

## Usage
Copy all files to the mpv folder. Here mpv is situated in `C:/Program Files/`, for other directory modify the location of shader in `input.conf` and `mpv.conf`.

## Key Bindings
The custom key bindings can be modified from `input.conf` file. Refer to the manual for making any changes. Note that it ignores default key bindings, so in case you install any new script, replace add_key_binding with add_forced_key_binding in the script for key bindings to work.

### Keyboard Bindings:
* `RIGHT / LEFT` - Next / Previous file in playlist.
* `UP / DOWN` - Next / Previous chapter.
* `SPACE` - Play / Pause.
* `+ / -` - Increase / Decrease volume.
* `* / ^` - Add / Subtract audio delay by 0.1 second.
* `Page Up / Page Down` - Frame step up / down.
* `HOME / END` - Increase / Decrease speed by 5%.
* `Delete` - Cycle subtitle.
* `Key Pad 7 / Key Pad 1` - Increase / Decrease speed by 1%.
* `Key Pad 9 / Key Pad 3` - Frame step up / down.
* `Key Pad 8` - Cycle audio.
* `Key Pad 2` - Toggle interpolation.
* `l` - Loop file.
* `q` - Quit.
* `Q` - Save position and quit.
* `A` - Toggle audio pitch correction.
* `s` - Screenshot.
* `S` - Keep aspect ratio of video on resize.
* `m` - Mute.
* `u` - Override subtitle style.
* `v` - Toggle subtitle visibility.
* `w` - Resize window.
* `b` - Keep window on top.
* `r` - Rotate video.
* `0 - 9` - Seek video to n% absolute position.

### Mouse Bindings:
* `Double Click` - Toggle fullscreen.
* `Middle Click` - A/B loop.
* `Right Click` - Reset Speed
* `Forward / Back Button` - Increase / Decrease speed by 5%
* `Scroll` - Seek + / - 10 seconds.
* `Ctrl + Scroll` - Seek + / - 2 seconds.

### Script / Shader specific key bindings:
* `\` - Toggle Dynamic Range Compression filter for audio.
* `a` - Cycle audio devices.
* `c` - Auto crops black bars.
* `d` - Auto deinterlaces video.
* `n` - Toggle Adaptive Sharpen.
* `N` - Toggle Raavu pre scaler.
* `I` - Toggles video stats, change page with `1`, `2`, `3`.

## System Requirement
This config was made for Windows 10 with AMD RX580 GPU and AMD Ryzen 7 1700 CPU. Should run at decent speed in lower specification too. To increase performance you can do the following:
* Disable Raavu pre scaler.
* Remove cscale entry.
* Set interpolation to no.
* Disable debanding.
