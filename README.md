# MPV Config for Windows Build.
<p align="center"><img src="https://raw.githubusercontent.com/he2a/mpv-config/master/doc/screen.jpg"></p>

## Overview
Just my config for use in mpv. Contains custom forced keybindings and optimized for anime media. Currently there is a problem with display-resample and interpolation when used with vulkan in AMD and so vulkan is not used. The source of various lua scripts are mentioned in the file source and are in some cases modified a little from original code.

## Usage
Copy all files to the mpv folder. Here mpv is situated in `C:/Program Files/`, for other directory modify the location of shader in `input.conf` and `mpv.conf`.

## Key Bindings
The custom key bindings are located in `input.conf` file. Other than that some other key bindings for activating certain scripts are given below.
* `\` - Toggle Dynamic Range Compression filter for audio.
* `a` - Cycles audio devices.
* `c` - Auto crops black bars.
* `d` - Auto deinterlaces video.
* `I` - Toggles video stats, change page with `1`, `2`, `3`.

## System Requirement
This config was made for Windows 10 with AMD RX580 GPU and AMD Ryzen 7 1700 CPU.
