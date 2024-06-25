# mpv-config

<p align="center"><img width=100% src="https://raw.githubusercontent.com/he2a/mpv-config/master/images/preview.jpg" alt="mpv screenshot"></p>

## Overview
Just my personal config files for use in mpv. Contains custom keybindings, pseudo GUI menu and various userscripts and shaders optimized for animated media as well as movies for use in high to even low end computer with integrated graphics.

## Usage
Download the latest windows build of mpv from [here](https://mpv.io/installation/) and extract it. Download and copy `portable_config` folder from this repo to the extracted folder and you are good to go. Settings can be temporary changed using player menu and other adjustments can be done by editing `mpv.conf` and `input.conf`. To open youtube links, install yt-dlp from [here](https://github.com/yt-dlp/yt-dlp).

## Key Bindings
Custom key bindings can be added in `input.conf` file. Refer to the [manual](https://mpv.io/manual/master/) for making any changes. Default key bindings can be seen from the `input.conf` file or by pressing <kbd>o</kbd> and then <kbd>6</kbd> button, but most of the player functions can be used through the menu accessed by <kbd>Right Click</kbd>.

## Menu
You can access the menu by right clicking on the video or clicking the menu button above progress bar. The menu provides an easy way to toggle various functionalities without memorizing or adding key bindings. Nevertheless, some of the functionalities have keybindings assigned to them which you can see on the right side of the same entry. While the settings apply to the current session of mpv, they are not saved, so next time you open the player, it will have the default settings. To make things permanent you are encouraged to make the changes in `mpv.conf` itself. There are various functionalities added to the menu, some of which are as follows:

### File
Contains options regarding file or the player itself. You can select file, subtitle, entries in playlist, chapters, clip part of the video as WebM or if you have installed yt-dlp, download the youtube video you are watching in mpv.

### Window
Allows scaling, rotating and cropping the window, fill the video to max height of window, toggle window borders, keep player on top or freeze the frame to its current position.

### Video
Allows various operations on the video driver. The sub-options are detailed below: 

#### Video Output
By default it is gpu-next which uses vulkan, but older gpu might have problems with it so you can switch to gpu or in worst case scenario, Direct3D.

#### Hardware Decoder
By default, its set to auto-copy which should choose the best decoder for the video. If you are using an Nvidia GPU, you might choose nvdec-copy. Difference between hardware decoder and its copy variant is that copy, as the name suggests, copies the video from VRAM back to RAM which allows certain post-processing to be done on the video at the cost of marginal performance hit. If you use the non copy variant, cropping or video thumbnails might not work, but in low end systems you may choose to go for it. You may choose to disable it altogether but I don't see any benefits to it as hardware decoding quality has improved substantially over the years.

#### Quality 
By default it is set to High, but if you feel like frames are dropping, you may chose medium or low. Other two options are situational and not for videos. They are used by auto-profiles for audio files or GIFs.

#### Toggle Interpolation
Helps reduce video stutter due to mismatch of video fps and screen refresh rate. By default it is set to no as it sometimes causes problem with certain shaders, but you may chose to enable it in case of noticeable video stuttering. As an added bonus, enabling it makes the menu animations smoother.

#### Toggle Deband
Helps reduce banding in video. By default, it is set to no as by default I have included hdeband which does a better job in debanding. But if you do not use shaders or are using the medium or low quality, you might enable it.

#### HDR Tonemapping
Helps convert HDR videos to SDR so that videos do not look washed out. While each of them has its own perks, BT.2446a and ST2094-40 will not work if you chose gpu instead of gpu-next in video output. For HDR displays, you might select Auto. You can use a shader variant for HDR to SDR conversion by choosing HDR-Toys in `Shaders` `→` `Miscellaneous` `→` `HDR-Toys`.

#### Deinterlace
Automatically selects the best deinterlacing algorithm by analyzing a part of the video. Mainly useful for old interlaced content.

### Shaders
Allows you to apply various shaders to video. All shaders should work out of box, but if you use gpu intead of gpu-next, some might not. If you don't wish to experiment with it, presets allow you to easily apply bunch of shaders. Do note that some of the shaders are especially taxing to GPU and for mid to low end systems, you might use a lower quality variant, which are not present in presets. 

### Subtitles
Allows you to choose subtitle in video, hide it or customize the looks of subtitle. You can either select one from presets or play around with font, color and size. Override ASS Style allows you to use the custom styles in ASS subtitles, which is applicable in Anime where subtitles are prestyled.

### Audio
Allows you to select audio stream, change audio device, mute audio or apply filters. Currently you can apply DRC or Normalization to dynamically increase volume of audio. You can apply equalizer, but out of box it will not do anything. You have to customize the equalizer by editing `equalizer.csv` and `equalizer.conf` in `script-opts`. The equalizer format is similar to the format used by EqualizerAPO. itch Correction helps maintain pitch when speeding up or slowing down the playback. It is disabled by default in case of audio files.

### Miscellaneous

#### Open Current Directory
Opens the folder where the current file is stored. 

#### Screenshot 
Saves the current screenshot in your desktop. 

#### Benchmark 
Allows you to check the performance of the GPU in current settings by showing the FPS counter. To stop benchmark, either close the player or choose `Stop` in `Benchmark` although sometimes the player becomes a bit buggy. 

#### Console
Console opens a portable console in player where you can check errors or apply commands in real time. 

#### Stats
Stats show various metrics about the current video. You can choose different pages in stats by pressing <kbd>1</kbd> to <kbd>6</kbd>. 

#### Settings
Settings open the directory where portable_config is located. 

#### Bookmark & Quit
It allows you to save the current location in video and quit so the player resumes playback from the same location next time you open that video.

## System Requirement
This config was made for my current PC setup with RTX 4070 and 1080p 165Hz SDR screen, but can be used with low end integrated GPU like Intel HD Graphics 620 with limited functionality. You can improve performance by changing the quality of video from High to Medium or Low.