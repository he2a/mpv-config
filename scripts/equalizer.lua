--[[
A simple lua script for togglable equalizer in mpv inspired from the 5 band visual equalizer by avih, https://gist.github.com/avih/41acff712abd32e1f436235388c8b523

Options:
eq_enabled: Set to true to start mpv with equalizer enabled.
preamp: Set preamp to avoid clipping.
bands: Add {freq = '<frequency>', width = {'<type>', '<value>'}, gain = '<gain>'} to the bands for each modification of frequency, separated by comma. The bands accepts the following options:
       freq: Set the filter’s central frequency in Hz.
       width: Set the band-width of filter
       type: Set method to specify band-width of filter.
              h  Hz
              q  Q-Factor 
              o  octave 
              s  slope
       value: Set the magnitude of the band-width
       gain: Set the required gain or attenuation in dB.
toggle_key: Keybinding to toggle equalizer.
--]]

--[[ 
-- Personal settings for Beyerdynamic DT990
local bands = {
  {freq = '20', width = {'q', '1.0'}, gain = '3.0'},
  {freq = '74', width = {'q', '1.8'}, gain = '8.3'},
  {freq = '97', width = {'q', '0.4'}, gain = '-4.8'},
  {freq = '145', width = {'q', '0.6'}, gain = '-2.8'},
  {freq = '206', width = {'q', '1.7'}, gain = '5.4'},
  {freq = '360', width = {'q', '4.0'}, gain = '1.2'},
  {freq = '650', width = {'q', '1.3'}, gain = '2.5'},
  {freq = '2300', width = {'q', '4.0'}, gain = '1.0'},
  {freq = '3000', width = {'q', '4.0'}, gain = '-1.0'},
  {freq = '4390', width = {'q', '7.0'}, gain = '1.0'},
  {freq = '5840', width = {'q', '4.0'}, gain = '-8.2'},
  {freq = '7300', width = {'q', '7.0'}, gain = '2.5'},
  {freq = '8220', width = {'q', '5.0'}, gain = '-11.0'},
  {freq = '10420', width = {'q', '2.0'}, gain = '1.3'}
}
--]]

-- Options
local eq_enabled = true
local preamp = 0

local bands = {
  {freq = '64', width = {'o', '3.3'}, gain = '0'}, -- 20-200
  {freq = '400', width = {'o', '2.0'}, gain = '0'}, -- 200-800
  {freq = '1250', width = {'o', '1.3'}, gain = '0'}, -- 800-2k
  {freq = '2830', width = {'o', '1.0'}, gain = '0'}, -- 2k-4k
  {freq = '5600', width = {'o', '1.0'}, gain = '0'}, -- 4k-8k
  {freq = '12500', width = {'o', '1.3'}, gain = '0'} -- 8k-20k
}
local toggle_key = 'e'

local function push_preamp()
  if eq_enabled then 
    return 'no-osd af add lavfi=[volume=volume=' .. preamp .. 'dB:precision=fixed]'
  else
    return 'no-osd af remove lavfi=[volume=volume=' .. preamp .. 'dB:precision=fixed]'
  end
end

local function push_eq(filter)
  if eq_enabled then 
    return 'no-osd af add lavfi=[equalizer=f=' .. filter.freq .. ':width_type=' .. filter.width[1] .. ':w=' .. filter.width[2] .. ':g=' .. filter.gain .. ']'
  else
    return 'no-osd af remove lavfi=[equalizer=f=' .. filter.freq .. ':width_type=' .. filter.width[1] .. ':w=' .. filter.width[2] .. ':g=' .. filter.gain .. ']'
  end
end

local function updateEQ()
  if preamp ~= 0 then mp.command(push_preamp()) end
  for i = 1, #bands do
    local f = bands[i]
    if f.gain ~= '0' then
	  mp.command(push_eq(f))
    end
  end
end

local function toggle_eq()
  eq_enabled = not eq_enabled
  updateEQ()
end

for i = 1, #bands do
    if bands[i].gain ~= '0' then
        updateEQ()
        break
    end
end

mp.add_key_binding(toggle_key, "toggle-eq", toggle_eq)
