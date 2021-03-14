--[[

A simple lua script for togglable equalizer, dynamic range compressor, stereo downmix and 
other filters yet to come.

Options:
preamp: Set preamp to avoid clipping.
bands : Add {freq = <frequency>, width = {'<type>', <value>}, gain = <gain>}
        to the bands for each modification of frequency, separated by comma.
	   
        freq : Set the filter’s central frequency in Hz.
        width: Set the bandwidth of filter
        type : Set method to specify bandwidth of filter.
               h  Hz
               q  Q-Factor 
               o  octave 
               s  slope
        value: Set the magnitude of the bandwidth
        gain : Set the required gain or attenuation in dB.

drc: Enable to compress the dynamic range of audio resulting in quieter parts 
     getting louder.

	 ratio    : Ratio by which the signal is changed.
	 attack   : Amount of ms the signal has to rise above the threshold before 
	            it triggers.
	 release  : Amount of ms the signal has to fall below the threshold before 
	            it is restored.
	 makeup   : Amount in dB the signal will be amplified after processing.
	 knee     : Curve the sharp knee around threshold dB to enter gain reduction
	            more softly. 
     threshold: Triggered if signal in dB rises above this level.
	 
eq_enabled : Start with equalizer enabled.
dc_enabled: Start with compressor enabled.

--]]

--[[ 

Personal settings for reducing treble sharpness in Beyerdynamic DT990 Pro

local preamp = -2.7
local bands = {
  {freq = 2300, width = {'q', 4.0}, gain = 1.0},
  {freq = 3000, width = {'q', 4.0}, gain = -1.0},
  {freq = 4390, width = {'q', 7.0}, gain = 1.0},
  {freq = 5840, width = {'q', 4.0}, gain = -8.2},
  {freq = 7300, width = {'q', 7.0}, gain = 2.5},
  {freq = 8220, width = {'q', 5.0}, gain = -11.0},
  {freq = 10420, width = {'q', 2.0}, gain = 1.3}
}

--]]

-- Settings --

preamp = 0
bands = {
  {freq = 64, width = {'o', 3.3}, gain = 0},   -- 20Hz - 200Hz
  {freq = 400, width = {'o', 2.0}, gain = 0},  -- 200Hz - 800Hz
  {freq = 1250, width = {'o', 1.3}, gain = 0}, -- 800Hz - 2kHz
  {freq = 2830, width = {'o', 1.0}, gain = 0}, -- 2kHz - 4kHz
  {freq = 5600, width = {'o', 1.0}, gain = 0}, -- 4kHz - 8kHz
  {freq = 12500, width = {'o', 1.3}, gain = 0} -- 8kHz - 20kHz
}

drc = {
  threshold = -20,
  ratio = 4,
  attack = 20,
  release = 250,
  makeup = 8,
  knee = 3
}

eq_enabled = false
dc_enabled = false
dm_enabled = false

-- Code --

local init_done = false
local eq_tog = false
local dc_tog = false
local dm_tog = false

local function check_channel()
  local c = mp.get_property_number('audio-params/channel-count')
  if not c then 
	return 0
  else
    return c
  end
end

local function push_preamp()
  if eq_tog then 
    return 'no-osd af add lavfi=[volume=volume=' .. preamp .. 'dB:precision=fixed]'
  else
    return 'no-osd af remove lavfi=[volume=volume=' .. preamp .. 'dB:precision=fixed]'
  end
end

local function push_eq(filter)
  if eq_tog then 
    return 'no-osd af add lavfi=[equalizer=f=' .. filter.freq .. ':width_type=' .. filter.width[1] .. ':w=' .. filter.width[2] .. ':g=' .. filter.gain .. ']'
  else
    return 'no-osd af remove lavfi=[equalizer=f=' .. filter.freq .. ':width_type=' .. filter.width[1] .. ':w=' .. filter.width[2] .. ':g=' .. filter.gain .. ']'
  end
end

local function push_drc()
  if dc_tog then
    return 'no-osd af add acompressor=threshold=' .. drc.threshold .. 'dB:ratio=' .. drc.ratio .. ':attack=' .. drc.attack .. ':release=' .. drc.release .. ':makeup=' .. drc.makeup .. 'dB:knee=' .. drc.knee .. 'dB'
  else
    return 'no-osd af remove acompressor=threshold=' .. drc.threshold .. 'dB:ratio=' .. drc.ratio .. ':attack=' .. drc.attack .. ':release=' .. drc.release .. ':makeup=' .. drc.makeup .. 'dB:knee=' .. drc.knee .. 'dB'
  end
end

local function push_dm(chn)
  local filter
  if chn < 7 then
    filter = 'pan=stereo|FL=0.5*FC+0.707*FL+0.707*BL+0.5*LFE|FR=0.5*FC+0.707*FR+0.707*BR+0.5*LFE,dynaudnorm=f=300:g=31:p=0.95:m=3'
  else
	filter = 'pan=stereo|FL<0.5*FC+0.3*FLC+0.3*FL+0.3*BL+0.3*SL+0.5*LFE|FR<0.5*FC+0.3*FRC+0.3*FR+0.3*BR+0.3*SR+0.5*LFE,dynaudnorm=f=300:g=31:p=0.95:m=3'
  end
  
  if dm_tog then 
    return 'no-osd af add lavfi=[' .. filter .. ']'
  else
    return 'no-osd af remove lavfi=[' .. filter .. ']'
  end
end

local function updateEQ()
  if preamp ~= 0 then mp.command(push_preamp()) end
  for i = 1, #bands do
    local f = bands[i]
    if f.gain ~= 0 then
	  mp.command(push_eq(f))
    end
  end
end

local function toggle_drc()
  dc_tog = not dc_tog
  mp.command(push_drc())
  if dc_tog then mp.osd_message("Dynamic Range Compressor ON") else mp.osd_message("Dynamic Range Compressor OFF") end
end

local function toggle_eq()
  eq_tog = not eq_tog
  updateEQ()
  if eq_tog then mp.osd_message("Equalizer ON") else mp.osd_message("Equalizer OFF") end
end

local function toggle_downmix()
  local c = check_channel()
  if c > 2 then 
    dm_tog = not dm_tog
    mp.command(push_dm(c))
    if dm_tog then mp.osd_message("Downmixing " .. c .. " Channels to Stereo") else mp.osd_message("Downmixing OFF") end
  else 
    mp.osd_message("Downmixing Disabled")
  end
end

local function start_filters()
  local c = check_channel()
  if eq_tog then updateEQ() end
  if dc_tog then mp.command(push_drc()) end
  if dm_tog and c > 2 then mp.command(push_dm(c)) end
end

function init_filters()
  if not init_done then
	init_done = not init_done
	eq_tog = eq_enabled
	dc_tog = dc_enabled
	dm_tog = dm_enabled
	start_filters()
  end
end

function deinit_filters()
  init_done = false
  eq_tog = true
  dc_tog = true
  dm_tog = true
  toggle_eq()
  toggle_drc()
  toggle_downmix()
end

mp.add_key_binding('e', "toggle-eq", toggle_eq)
mp.add_key_binding('\\', "toggle-drc", toggle_drc)
mp.add_key_binding('E', "toggle-dm", toggle_downmix)

-- mp.register_event('file-loaded', init_filters())
-- mp.register_event('end-file', deinit_filters())

init_filters() -- Initializes the filter at start