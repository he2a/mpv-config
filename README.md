# MPV Configuration for Windows Build

<p align="center"><img width=100% src="https://raw.githubusercontent.com/he2a/mpv-config/master/images/preview.jpg" alt="MPV Screenshot"></p>

## Overview
Just my personal config files for use in mpv. Contains custom keybindings, pseudo GUI menu and various shaders optimized for animated media.

## Usage
Download the latest windows build of mpv from [here](https://mpv.io/installation/) and extract it. Download and copy all files from this repo to the extracted folder and you are good to go.

## Key Bindings
Custom key bindings can be added from `input.conf` file. Refer to the [manual](https://mpv.io/manual/master/) for making any changes. Please note that by default it is set to ignore default key bindings which includes key bindings of any script you install, so in that case , replace `add_key_binding` with `add_forced_key_binding` in the script for key bindings of the script to work.

### Keyboard Bindings:

- `RIGHT or LEFT` - Next or Previous file in playlist.
- `UP or DOWN` - Next or Previous chapter.
- `PGUP or PGDN` - Frame step up or down.
- `HOME or END` - Increase or Decrease speed by 5%.
- `+ or -` - Increase or Decrease volume.
- `* or /` - Increase or Decrease audio delay.
- `0 to 9` - Seek video to n% absolute position.
- `SPACE` - Play or Pause.
- `INS` - Cycle subtitle.
- `DEL` - Cycle audio.
- `\` - Toggle Dynamic Range Compression filter for audio.
- `q` - Quit.
- `Q` - Save position and quit.
- `s` - Screenshot.
- `l` - Loop file.
- `a` - Cycle audio devices.
- `A` - Toggle audio pitch correction.
- `S` - Keep aspect ratio of video on resize.
- `m` - Mute.
- `c` - Auto crop black bars.
- `d` - Auto deinterlace video.
- `u` - Override subtitle style.
- `v` - Toggle subtitle visibility.
- `w` - Resize window.
- `n` - Keep window on top.
- `b` - Toggle border.
- `r` - Rotate video.
- `i` - Toggle video stats, change page with `1`, `2`, `3`.

### Mouse Bindings:
- `Double Click` - Toggle fullscreen.
- `Middle Click` - A/B loop.
- `Right Click` - Open Menu
- `Forward or Back Button` - Increase or Decrease speed by 5%
- `Scroll` - Seek 10 seconds.
- `Ctrl + Scroll` - Seek 2 seconds.

## Shaders
Various GLSL shaders can be toggled from menu. Note that these shaders require sufficiently powerful GPU and will result in frame skips if used in a low power GPU. Check video stats by pressing `i` and see if it results in frame skips or worse A-V desynchronization. The shaders are divided into four groups.
- Denoise shaders help reduce noise or grains from poor source. Mean and Mode are general purpose and does light denoising. The DenoiseCNN is best used for animated work and does heavy denoising.
- Sharpen shaders increase the overall sharpness of video. The adaptive sharpen is general purpose whereas DeblurCNN is best for animated work.
- Prescaler shaders upscales luma plane by 2X using neural network for better upscaling than conventional scaler. Note that these won't work if video is more than half the screen resolution. FSRCNNX 2X and SSIMSuperres are suited for general video whereas Anime4K variants and FSRCNNX 2X Line Art version is suited for animated content.
- Other shaders include Darken and Thin Lines which when combined perceptually improves quality of animated scenes, ResidualCNN shader fixes resize related artifacts, KrigBilateral is a decent chroma upscaler and SSIMDownscale is a decent downscaler.

## System Requirement
This config was tested in Windows 10 build 2004 and works well with low end integrated GPU like Intel HD Graphics 620 (without any shaders or interpolation) and works fully with AMD RX 580 with resonable combination of shaders.
