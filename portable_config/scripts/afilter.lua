local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local opt = require 'mp.options'

local o = {
	preamp = -3.1,
	bands = {
	  {freq = 10,    width = {'q', 0.1}, gain =  3.0},
	  {freq = 220,   width = {'q', 0.7}, gain = -2.0},
	  {freq = 400,   width = {'q', 1.0}, gain = -0.5},
	  {freq = 1800,  width = {'q', 2.0}, gain =  1.8},
	  {freq = 3600,  width = {'q', 0.4}, gain =  3.0},
	  {freq = 9950,  width = {'q', 4.5}, gain = -3.0},
	  {freq = 20000, width = {'q', 0.2}, gain =  8.5}
	},

	drc_enabled = 'no',	
	drc_knee = 2.8,
	drc_ratio = 2,
	drc_makeup = 8,
	drc_attack = 20,
	drc_release = 250,
	drc_threshold = -20,
	drc_whitelist = 'audio',

	dnm_enabled = 'yes',
	dnm_gauss = 5,
	dnm_ratio = 4,
	dnm_frame = 400,
	dnm_peak = 0.95,
	dnm_minthres = 0,
	dnm_whitelist = 'movie',
	
	eqr_enabled = 'no',
	eqr_whitelist = 'audio',
	
	vid_threshold = 600,
	vid_arlimit = 1.2
}
-- Local Variables --------------------------------------------------------------------------------------

opt.read_options(o, 'afilter')

local function txt2bool(txt)
	if (txt == 'yes') or (txt == 'true') then
		return true
	else
		return false
	end
end

local med_type   = nil
local vid_length = o.vid_threshold
local vid_aratio = o.vid_arlimit
local auto_delay = 0.5

local eqr_whlist = o.eqr_whitelist
local drc_whlist = o.drc_whitelist
local dnm_whlist = o.dnm_whitelist
local eqr_enable = txt2bool(o.eqr_enabled)
local drc_enable = txt2bool(o.drc_enabled)
local dnm_enable = txt2bool(o.dnm_enabled)

local eqr_filter = { enabled = false, bands = o.bands }
local pre_filter = { enabled = false, syntax = 'volume=volume=' .. o.preamp .. 'dB:precision=fixed' }
local drc_filter = { enabled = false, syntax = 'acompressor=threshold=' .. o.drc_threshold .. 'dB:ratio=' .. o.drc_ratio .. ':attack=' .. o.drc_attack .. ':release=' .. o.drc_release .. ':makeup=' .. o.drc_makeup .. 'dB:knee=' .. o.drc_knee .. 'dB' }
local dnm_filter = { enabled = false, syntax = 'dynaudnorm=f=' .. o.dnm_frame .. ':g=' .. o.dnm_gauss .. ':m=' .. o.dnm_ratio .. ':p=' .. o.dnm_peak .. ':t=' .. o.dnm_minthres }

-- Misc Functions --------------------------------------------------------------------------------------

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


-- Filter Push --------------------------------------------------------------------------------------

local function push_filter(filter)
  if filter.enabled then
    return 'no-osd af add ' .. filter.syntax
  else
    return 'no-osd af remove ' .. filter.syntax
  end
end

local function updateEQ()
  if eqr_filter.enabled and pre_filter.enabled then 
    mp.command('no-osd af add ' .. pre_filter.syntax)
  else
    mp.command('no-osd af remove ' .. pre_filter.syntax)
  end
  for i = 1, #eqr_filter.bands do
    local f = eqr_filter.bands[i]
    if f.gain ~= 0 then
      if eqr_filter.enabled then 
        mp.command('no-osd af add equalizer=f=' .. f.freq .. ':width_type=' .. f.width[1] .. ':w=' .. f.width[2] .. ':g=' .. f.gain)
      else
        mp.command('no-osd af remove equalizer=f=' .. f.freq .. ':width_type=' .. f.width[1] .. ':w=' .. f.width[2] .. ':g=' .. f.gain)
      end
    end
  end
end

-- Filter Toggle --------------------------------------------------------------------------------------

local function toggle_eqr()
  eqr_filter.enabled = not eqr_filter.enabled
  updateEQ()
  if eqr_filter.enabled then mp.osd_message("Equalizer ON") else mp.osd_message("Equalizer OFF") end
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

-- Script init/deinit --------------------------------------------------------------------------------------

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
        if eqr_enable and type_compare(eqr_whlist, med_type) then
          eqr_filter.enabled = true
          updateEQ()
        end
        if drc_enable and type_compare(drc_whlist, med_type) then 
          drc_filter.enabled = true
          mp.command(push_filter(drc_filter))
        end
        if dnm_enable and type_compare(dnm_whlist, med_type) then 
          dnm_filter.enabled = true
          mp.command(push_filter(dnm_filter))
        end
      end
      delay:kill()
      delay = nil
    end
  )
end

local function deinit_filter()
  if eqr_filter.enabled then 
    eqr_filter.enabled = false
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
mp.add_key_binding('k', "toggle-drc", toggle_drc)
mp.add_key_binding('E', "toggle-dnm", toggle_dnm)

mp.register_event("file-loaded", init_filter)
mp.register_event("end-file", deinit_filter)