# Personal mpv Configuration for Windows

<p align="center"><img width=100% src="https://raw.githubusercontent.com/he2a/mpv-config/master/images/preview.jpg" alt="MPV Screenshot"></p>

## Overview
Just my personal config files for use in mpv. Contains custom keybindings, pseudo GUI menu and various shaders optimized for animated media.

## Usage
Download the latest windows build of mpv from [here](https://mpv.io/installation/) and extract it. Download and copy all files from this repo to the extracted folder and you are good to go.

## Key Bindings
Custom key bindings can be added from `input.conf` file. Refer to the [manual](https://mpv.io/manual/master/) for making any changes. Please note that by default it is set to ignore default key bindings which includes key bindings of any script you install, so in that case , replace `add_key_binding` with `add_forced_key_binding` in the script for key bindings of the script to work.

### Keyboard Bindings:

- <kbd>RIGHT</kbd> or <kbd>LEFT</kbd> - Next or Previous file in playlist.
- <kbd>UP</kbd> or <kbd>DOWN</kbd> - Next or Previous chapter.
- <kbd>PGUP</kbd> or <kbd>PGDN</kbd> - Frame step up or down.
- <kbd>HOME</kbd> or <kbd>END</kbd> - Increase or Decrease speed by 5%.
- <kbd>+</kbd> or <kbd>-</kbd> - Increase or Decrease volume.
- <kbd>*</kbd> or <kbd>/</kbd> - Increase or Decrease audio delay.
- <kbd>0</kbd> to <kbd>9</kbd> - Seek video to n% absolute position.
- <kbd>SPACE</kbd> - Play or Pause.
- <kbd>INS</kbd> - Cycle subtitle.
- <kbd>DEL</kbd> - Cycle audio.
- <kbd> \ </kbd> - Toggle Dynamic Range Compression filter for audio.
- <kbd>q</kbd> - Quit.
- <kbd>Q</kbd> - Save position and quit.
- <kbd>s</kbd> - Screenshot.
- <kbd>l</kbd> - Loop file.
- <kbd>a</kbd> - Cycle audio devices.
- <kbd>A</kbd> - Toggle audio pitch correction.
- <kbd>S</kbd> - Keep aspect ratio of video on resize.
- <kbd>m</kbd> - Mute.
- <kbd>c</kbd> - Auto crop black bars.
- <kbd>d</kbd> - Auto deinterlace video.
- <kbd>u</kbd> - Override subtitle style.
- <kbd>v</kbd> - Toggle subtitle visibility.
- <kbd>w</kbd> - Resize window.
- <kbd>n</kbd> - Keep window on top.
- <kbd>b</kbd> - Toggle border.
- <kbd>r</kbd> - Rotate video.
- <kbd>i</kbd> - Toggle video stats, change page with <kbd>1</kbd>, <kbd>2</kbd>, <kbd>3</kbd>.

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
- Prescaler shaders upscales luma plane by 2X using neural network for better upscaling than conventional scaler. Note that these won't work if video is more than half the screen resolution. FSRCNNX 2X and SSIMSuperres are suited for general video whereas Anime4K variants and FSRCNNX 2X Line Art version is suited for animated content. On the other hand, KrigBilateral is a decent chroma upscaler 
- Other shaders include Darken and Thin Lines which when combined perceptually improves quality of animated scenes, Residual shaders which fixes resize related artifacts, SSIMDownscale which is a decent downscaler and Acme fast 0.5X downscale which halves video size fast.

## System Requirement
This config was tested in Windows 10 build 20H2 and works well with low end integrated GPU like Intel HD Graphics 620 (without any shaders or interpolation) and works fully with AMD RX 580 with resonable combination of shaders.
