# Personal mpv Configuration for Windows Build
<p align="center"><img src="https://raw.githubusercontent.com/he2a/mpv-config/master/images/screenshot.png"></p>

## Overview
Just my personal config files for use in mpv. Contains custom keybindings, GUI menu and various shaders optimized for anime media .

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

### Script / Shader specific key bindings:
* `\` - Toggle Dynamic Range Compression filter for audio.
* `a` - Cycle audio devices.
* `c` - Auto crops black bars.
* `d` - Auto deinterlaces video.
* `I` - Toggles video stats, change page with `1`, `2`, `3`.

### Mouse Bindings:
* `Double Click` - Toggle fullscreen.
* `Middle Click` - A/B loop.
* `Right Click` - Open Menu
* `Forward / Back Button` - Increase / Decrease speed by 5%
* `Scroll` - Seek + / - 10 seconds.
* `Ctrl + Scroll` - Seek + / - 2 seconds.

## Shaders
Various shaders are included with it which can be used to increase the video quality or to upscale by 2X. All shaders can be used in any video but the shaders in Anime4X are specially designed with anime in mind and should be used with each other. The functionality of each shader is described below.

### General purpose shaders:
* `FSRCNNX.glsl` - Fast Super-Resolution Convolutional Neural Network based pre scaler which is best used in relatively noise free content. It has significant performance hit and use it only with powerful GPU. More information can be found <a href="https://github.com/igv/FSRCNN-TensorFlow">here</a>.
* `AdaSharp.glsl` - Adaptive Sharpen similar to the one in Reshade. More information <a href="https://gist.github.com/igv/8a77e4eb8276753b54bb94c1c50c317e">here</a>.
* `SSimSuperRes.glsl` - Another super resolution pre scaler with lower performance cost than FSRCNNX. More information <a href="https://gist.github.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b">here</a>.
* `SSimDownscale.glsl` - Perceptually based downscaler tuned with Mitchell parameters. More information <a href="https://gist.github.com/igv/36508af3ffc84410fe39761d6969be10">here</a>.
* `KrigBilateral.glsl` - Chroma upscaler which uses luma information to better upscale chroma information. More information <a href="https://gist.github.com/igv/a015fc885d5c22e6891820ad89555637">here</a>.

### Anime4K shaders (More information can be found <a href="https://github.com/bloc97/Anime4K">here</a>):
* `DarkLines.glsl + ThinLines.glsl` - Should be used together to darken and thin the black borders to give a perceptually better look.
* `Deblur.glsl` - Applies deblur filter assuming gaussian blur. A lower performance shader than `AdaSharp.glsl`.
* `Denoise.glsl` - Denoise the video. Should be used if video is noisy prior to applying `UpscaleCNN.glsl`.
* `RA.glsl` - Reduces resampling artifacts caused by non-linear resampling. Not to be used with good quality video source.
* `UpscaleCNN.glsl` - CNN based 2x pre scaler tuned for anime source.

## System Requirement
This config was tested in Windows 10 with two builds, with high performance AMD Ryzen 7 1700 CPU + AMD RX580 GPU and low performance Intel i5 7200U + integrated Intel HD Graphics 620. It works well with the hardware acceleration enabled in Intel HD graphics but may result in frame drops in some extreme scenario for which you can disable the following from menu.
* Debanding (Default: On with slight decrease in performance for very low end GPU)
* Interpolation (Default: Off with moderate to high hit in performance for very low end GPU)
* Shaders (Default: Off with high to very high hit in performance. Only to be used with powerful GPU)
