--[[

afilter.lua - Simple lua script for toggling different inbuilt audio filters.

Equalizer  : Toggleable versatile equalizer based on ffmpeg equalizer filter which adds
a two-pole peaking equalisation filter.

With this filter, the signal-level at and around a selected frequency can be increased
or decreased, while all other frequencies is unchanged. To produce complex equalisation
curves, it can be used several times, each with a different central frequency. 

Add {freq = <frequency>, width = {'<type>', <value>}, gain = <gain>} to the bands for 
each modification of frequency, separated by comma. 

preamp     : Set preamp to avoid clipping.

bands 
  freq     : Set the filter’s central frequency in Hz.
  width    : Set the bandwidth of filter
  type     : Set type of bandwidth of filter. (h:Hz, q:Q-Factor, o:Octave, s:Slope)
  value    : Set the magnitude of the bandwidth
  gain     : Set the required gain or attenuation in dB.

Acompressor: Toggleable dynamic audio compressor based on ffmpeg acompressor filter which 
is mainly used to reduce the dynamic range of a signal. 

Compression is done by detecting the volume above a chosen level threshold and dividing it 
by the factor set with ratio. So if you set the threshold to -12dB and your signal reaches 
-6dB a ratio of 2:1 will result in a signal at -9dB.

The reduction can be levelled over the time by setting attack which determines how long the 
signal has to rise above the threshold before any reduction will occur and release sets the 
time the signal has to fall below the threshold to reduce the reduction again. 

The overall reduction of the signal can be made up afterwards with the makeup setting. To 
gain a softer entry in the compression the knee flattens the hard edge at the threshold 
in the range of the chosen decibels. 

drc
	ratio    : Ratio by which the signal is changed.
	attack   : Duration in ms the signal has to rise before it triggers.
	release  : Duration in ms the signal has to fall before it is restored.
	makeup   : Amount in dB the signal will be amplified after processing.
	knee     : Curve knee around threshold to enter reduction more softly. 
  threshold: Triggered if signal in dB rises above this level.

dynaudnorm : Toggleable dynamic audio normalizer based on ffmpeg dynaudnorm filter which adds 
a certain amount of gain to the input audio in order to bring its peak magnitude to a target 
level without applying "dynamic range compressing". It will retain 100% of the dynamic range 
within each section of the audio file. 

The Dynamic Audio Normalizer processes the input audio in small chunks, set by frame (in ms). 
The filter’s window size is specified in gauss, which should be an odd number. For example, 
gauss size of 5 takes into account the current frame, as well as the 2 preceding and subsequent
frames and with a frame of 400ms, brings the total analysis time of 2 seconds. 

The ratio determines the maximum gain of the audio while the peak determines the maximum peak 
the filter will try to approach. The minthres specifies the lowest permissible magnitude level 
for the audio input which will be normalized.

dnm
  frame    : Size of audio sample frame in ms.
	gauss    : Number of sample frames to be analyzed. Must be an odd number.
	ratio    : Ratio by which the signal is changed.
	peak     : Maximum peak to be reached.
  minthres : Triggered if signal rises above this level.


eqr_enabled: Start with equalizer enabled.
drc_enabled: Start with compressor enabled.
dnm_enabled: Start with normalizer enabled.

Whitelist  : Whitelists the autostart of the filter to one of the four categories.
'audio' - For audio files
'video' - For video files
'movie' - For video files longer than 15 secs (default)
'blank' - For all files

whitelist_eqr = Set whitelist for equalizer
whitelist_drc = Set whitelist for compressor
whitelist_dnm = Set whitelist for normalizer

--]]

--[[

-- Example settings

-- Equalizer settings for Beyerdynamics DT 990 Pro
preamp = -1.0

bands = {
  {freq =  2300, width = {'q', 4.0}, gain =  1.00},
  {freq =  3000, width = {'q', 4.0}, gain = -1.00},
  {freq =  4390, width = {'q', 7.0}, gain =  1.00},
  {freq =  5840, width = {'q', 4.0}, gain = -8.20},
  {freq =  7300, width = {'q', 7.0}, gain =  2.50},
  {freq =  8220, width = {'q', 5.0}, gain = -11.0},
  {freq = 10420, width = {'q', 2.0}, gain =  1.30}
}

-- Equalizer settings for Blon BL-03
preamp = -1.0

bands = {
  {freq =  262, width = {'q', 0.757}, gain = -2.11},
  {freq =  912, width = {'q', 1.000}, gain =  2.29},
  {freq = 1949, width = {'q', 2.506}, gain = -2.81},
  {freq = 2691, width = {'q', 3.555}, gain = -5.00},
  {freq = 3538, width = {'q', 2.258}, gain =  6.91},
  {freq = 5046, width = {'q', 4.565}, gain = -2.85},
  {freq = 6213, width = {'q', 13.90}, gain =  2.61},
  {freq = 7738, width = {'q', 9.222}, gain = -3.67},
  {freq = 9455, width = {'q', 5.395}, gain =  2.45}
}

-- Equalizer settings for Sennheiser HD 598SE
preamp = -3.1

bands = {
  {freq = 10,    width = {'q', 0.1}, gain =  3.0},
  {freq = 220,   width = {'q', 0.7}, gain = -2.0},
  {freq = 400,   width = {'q', 1.0}, gain = -0.5},
  {freq = 1800,  width = {'q', 2.0}, gain =  1.8},
  {freq = 3600,  width = {'q', 0.4}, gain =  3.0},
  {freq = 9950,  width = {'q', 4.5}, gain = -3.0},
  {freq = 20000, width = {'q', 0.2}, gain =  8.5}
}

drc = {
  knee = 2.8,
  ratio = 2,
  makeup = 8,
  attack = 20,
  release = 250,
  threshold = -20
}

dnm = {
  gauss = 5,
  ratio = 4,
  frame = 400,
  peak = 0.95,
  minthres = 0
}

eqr_enabled = true
drc_enabled = false
dnm_enabled = false

whitelist_eqr = 'audio'
whitelist_drc = 'blank'
whitelist_dnm = 'movie'

--]]

-- User Settings -------------------------------------------------------------------------------------------------------------------------------------

preamp = -1.0

bands = {
  {freq =  262, width = {'q', 0.757}, gain = -2.11},
  {freq =  912, width = {'q', 1.000}, gain =  2.29},
  {freq = 1949, width = {'q', 2.506}, gain = -2.81},
  {freq = 2691, width = {'q', 3.555}, gain = -5.00},
  {freq = 3538, width = {'q', 2.258}, gain =  6.91},
  {freq = 5046, width = {'q', 4.565}, gain = -2.85},
  {freq = 6213, width = {'q', 13.90}, gain =  2.61},
  {freq = 7738, width = {'q', 9.222}, gain = -3.67},
  {freq = 9455, width = {'q', 5.395}, gain =  2.45}
}

drc = {
  knee = 2.8,
  ratio = 2,
  makeup = 8,
  attack = 20,
  release = 250,
  threshold = -20
}

dnm = {
  gauss = 5,
  ratio = 4,
  frame = 400,
  peak = 0.95,
  minthres = 0
}

eqr_enabled = true
whitelist_eqr = 'blank'

drc_enabled = false
whitelist_drc = 'audio'

dnm_enabled = true
whitelist_dnm = 'movie'


-- Variables and general code ------------------------------------------------------------------------------------------------------------------------
local med_type = nil
local eqr_toggle = false
local vid_length = 600
local vid_aratio = 1.2
local auto_delay = 0.5
local eqr_whlist = whitelist_eqr
local drc_whlist = whitelist_drc
local dnm_whlist = whitelist_dnm
local pre_filter = { enabled = false, syntax = 'volume=volume=' .. preamp .. 'dB:precision=fixed' }
local drc_filter = { enabled = false, syntax = 'acompressor=threshold=' .. drc.threshold .. 'dB:ratio=' .. drc.ratio .. ':attack=' .. drc.attack .. ':release=' .. drc.release .. ':makeup=' .. drc.makeup .. 'dB:knee=' .. drc.knee .. 'dB' }
local dnm_filter = { enabled = false, syntax = 'dynaudnorm=f=' .. dnm.frame .. ':g=' .. dnm.gauss .. ':m=' .. dnm.ratio .. ':p=' .. dnm.peak .. ':t=' .. dnm.minthres }

local function type_check()
  local vid = mp.get_property_native("vid") or false
  local aid = mp.get_property_native("aid") or false
  local fps = mp.get_property_native("estimated-vf-fps") or 0
  local ar = mp.get_property_native("video-params/aspect") or 0
  local tt = mp.get_property_native("duration") or 0
  if not aid then
    if not vid then
      return 'avnil'
    else
      return 'anull'
    end
  elseif not vid or (fps <= 1) then
    return 'audio'
  elseif (ar >= vid_aratio) and (tt >= vid_length) then
    return 'movie'
  else
    return 'video'
  end
end

local function type_compare(a, b)
  if (a == 'blank') or (a == b) then
    return true
  elseif (a == 'video') and (b == 'movie') then
    return true
  else
    return false
  end
end

-- Filter push code ----------------------------------------------------------------------------------------------------------------------------------

local function push_filter(filter)
  if filter.enabled then
    return 'no-osd af add ' .. filter.syntax
  else
    return 'no-osd af remove ' .. filter.syntax
  end
end

local function updateEQ()
  if eqr_toggle and pre_filter.enabled then 
    mp.command('no-osd af add ' .. pre_filter.syntax)
  else
    mp.command('no-osd af remove ' .. pre_filter.syntax)
  end
  for i = 1, #bands do
    local f = bands[i]
    if f.gain ~= 0 then
      if eqr_toggle then 
        mp.command('no-osd af add equalizer=f=' .. f.freq .. ':width_type=' .. f.width[1] .. ':w=' .. f.width[2] .. ':g=' .. f.gain)
      else
        mp.command('no-osd af remove equalizer=f=' .. f.freq .. ':width_type=' .. f.width[1] .. ':w=' .. f.width[2] .. ':g=' .. f.gain)
      end
    end
  end
end

-- Filter toggle code --------------------------------------------------------------------------------------------------------------------------------

local function toggle_eqr()
  eqr_toggle = not eqr_toggle
  updateEQ()
  if eqr_toggle then mp.osd_message("Equalizer ON") else mp.osd_message("Equalizer OFF") end
end

local function toggle_drc()
  drc_filter.enabled = not drc_filter.enabled
  mp.command(push_filter(drc_filter))
  if drc_filter.enabled then mp.osd_message("Dynamic Range Compressor ON") else mp.osd_message("Dynamic Range Compressor OFF") end
end

local function toggle_dnm()
  dnm_filter.enabled = not dnm_filter.enabled
  mp.command(push_filter(dnm_filter))
  if dnm_filter.enabled then mp.osd_message("Dynamic Normalizer ON") else mp.osd_message("Dynamic Normalizer OFF") end
end

-- Init/Deinit code ----------------------------------------------------------------------------------------------------------------------------------

local function init_filter()
  if preamp ~= 0 then 
    pre_filter.enabled = true
  else
    pre_filter.enabled = false 
  end
  delay = mp.add_timeout(auto_delay,
    function()
      med_type = type_check()
      if med_type ~= 'anull' then
        if eqr_enabled and type_compare(eqr_whlist, med_type) then
          eqr_toggle = eqr_enabled
          updateEQ()
        end
        if drc_enabled and type_compare(drc_whlist, med_type) then 
          drc_filter.enabled = drc_enabled
          mp.command(push_filter(drc_filter))
        end
        if dnm_enabled and type_compare(dnm_whlist, med_type) then 
          dnm_filter.enabled = dnm_enabled
          mp.command(push_filter(dnm_filter))
        end
      end
      delay:kill()
      delay = nil
    end
  )
end

local function deinit_filter()
  if eqr_toggle then 
    eqr_toggle = false
	  updateEQ()
  end
  if drc_filter.enabled then 
    drc_filter.enabled = false
    mp.command(push_filter(drc_filter))
  end
  if dnm_filter.enabled then 
    dnm_filter.enabled = false
    mp.command(push_filter(dnm_filter))
  end
  med_type = nil
end

-- Events and bindings code --------------------------------------------------------------------------------------------------------------------------

mp.add_key_binding('e', "toggle-eqr", toggle_eqr)
mp.add_key_binding('\\', "toggle-drc", toggle_drc)
mp.add_key_binding('E', "toggle-dnm", toggle_dnm)

mp.register_event("file-loaded", init_filter)
mp.register_event("end-file", deinit_filter)