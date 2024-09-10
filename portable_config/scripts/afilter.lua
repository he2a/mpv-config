local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local opt = require 'mp.options'

local o = {
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
	
	lnm_enabled = 'yes',
	lnm_target = -16,
	lnm_range = 8,
	lnm_peak = -2,
	lnm_whitelist = 'movie',
	
	sofa_enabled = 'yes',
	sofa_file = '~~/script-opts/sofa/ClubFritz4.sofa',
	sofa_type = 'time',
	sofa_gain = 10,
	sofa_lfe = 2,
	sofa_whitelist = 'vidmc',
	
	vid_threshold = 600,
	vid_arlimit = 1.2
}
-- Local Variables --------------------------------------------------------------------------------------

local function txt2bool(txt)
	if (txt == 'yes') or (txt == 'true') then
		return true
	else
		return false
	end
end

opt.read_options(o)

local first_run  = true
local med_type   = nil
local vid_length = o.vid_threshold
local vid_aratio = o.vid_arlimit
local auto_delay = 0.2

local drc_whlist = o.drc_whitelist
local dnm_whlist = o.dnm_whitelist
local lnm_whlist = o.lnm_whitelist
local sfa_whlist = o.sofa_whitelist

local drc_enable = txt2bool(o.drc_enabled)
local dnm_enable = txt2bool(o.dnm_enabled)
local lnm_enable = txt2bool(o.lnm_enabled)
local sfa_enable = txt2bool(o.sofa_enabled)

local drc_filter = { enabled = false, syntax = 'acompressor=threshold=' .. o.drc_threshold .. 'dB:ratio=' .. o.drc_ratio .. ':attack=' .. o.drc_attack .. ':release=' .. o.drc_release .. ':makeup=' .. o.drc_makeup .. 'dB:knee=' .. o.drc_knee .. 'dB' }
local dnm_filter = { enabled = false, syntax = 'dynaudnorm=f=' .. o.dnm_frame .. ':g=' .. o.dnm_gauss .. ':m=' .. o.dnm_ratio .. ':p=' .. o.dnm_peak .. ':t=' .. o.dnm_minthres }
local lnm_filter = { enabled = false, syntax = 'loudnorm=i=' .. o.lnm_target .. ':lra=' .. o.lnm_range .. ':tp=' .. o.lnm_peak }
local sfa_filter = { enabled = false, syntax = 'sofalizer=sofa="' .. mp.command_native({"expand-path", o.sofa_file}) .. '":type='.. o.sofa_type .. ':gain=' .. o.sofa_gain .. ':lfegain=' .. o.sofa_lfe }

-- Misc Functions --------------------------------------------------------------------------------------

local function type_check()
  local vid = mp.get_property_native("vid") or false
  local aid = mp.get_property_native("aid") or false
  local fps = mp.get_property_native("estimated-vf-fps") or 0
  local ar = mp.get_property_native("video-params/aspect") or 0
  local tt = mp.get_property_native("duration") or 0
  local ch = mp.get_property_native("audio-params/channel-count") or 2
  local type_return = 'anull'
  if not aid then
    type_return = 'anull'
  elseif (ch > 2) then
	if not vid or (fps <= 1) then
	  type_return = 'audmc'
    elseif (ar >= vid_aratio) and (tt >= vid_length) then
      type_return = 'movmc'
    else
      type_return = 'vidmc'
    end
  else
	if not vid or (fps <= 1) then
	  type_return = 'audio'
    elseif (ar >= vid_aratio) and (tt >= vid_length) then
      type_return = 'movie'
    else
      type_return = 'video'
    end
  end
  return type_return
end

local function type_compare(w_list, m_type)
  if (w_list == 'allav') or (w_list == m_type) then
    return true
  elseif (w_list == 'audio') and (m_type == 'audmc') then
    return true
  elseif (w_list == 'video') and ((m_type == 'vidmc') or (m_type == 'movie') or (m_type == 'movmc')) then
    return true
  elseif ((w_list == 'movie') or (w_list == 'vidmc')) and (m_type == 'movmc') then
    return true
  elseif (w_list == 'allmc') and ((m_type == 'audmc') or (m_type == 'vidmc') or (m_type == 'movmc')) then
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

local function toggle_drc()
  drc_filter.enabled = not drc_filter.enabled
  mp.command(push_filter(drc_filter))
  if drc_filter.enabled then mp.osd_message("Dynamic Range Compressor ON") else mp.osd_message("Dynamic Range Compressor OFF") end
end

local function toggle_dnm()
  dnm_filter.enabled = not dnm_filter.enabled
  mp.command(push_filter(dnm_filter))
  if dnm_filter.enabled then mp.osd_message("Dynamic Audio Normalizer ON") else mp.osd_message("Dynamic Normalizer OFF") end
end

local function toggle_lnm()
  lnm_filter.enabled = not lnm_filter.enabled
  mp.command(push_filter(lnm_filter))
  if lnm_filter.enabled then mp.osd_message("Loudness Normalizer ON") else mp.osd_message("Loudness Normalizer OFF") end
end

local function toggle_sfa()
  sfa_filter.enabled = not sfa_filter.enabled
  mp.command(push_filter(sfa_filter))
  if sfa_filter.enabled then mp.osd_message("Sofalizer ON") else mp.osd_message("Sofalizer OFF") end
end

-- Script init/deinit --------------------------------------------------------------------------------------

local function init_filter()
  if first_run then
    mp.command('no-osd af clr ""')
    first_run = false
  else
    if drc_filter.enabled then 
      drc_filter.enabled = false
      mp.command(push_filter(drc_filter))
    end
    if dnm_filter.enabled then 
      dnm_filter.enabled = false
      mp.command(push_filter(dnm_filter))
    end
    if lnm_filter.enabled then 
      lnm_filter.enabled = false
      mp.command(push_filter(lnm_filter))
    end
    if sfa_filter.enabled then 
      sfa_filter.enabled = false
      mp.command(push_filter(sfa_filter))
    end
    med_type = nil
  end

  delay = mp.add_timeout(auto_delay,
    function()
      med_type = type_check()
      if med_type ~= 'anull' then
        if sfa_enable and type_compare(sfa_whlist, med_type) then 
          sfa_filter.enabled = true
          mp.command(push_filter(sfa_filter))
        end
        if lnm_enable and type_compare(lnm_whlist, med_type) then 
          lnm_filter.enabled = true
          mp.command(push_filter(lnm_filter))
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

-- Events and bindings code --------------------------------------------------------------------------------------------------------------------------

mp.add_key_binding('k', "toggle-drc", toggle_drc)
mp.add_key_binding('e', "toggle-lnm", toggle_lnm)
mp.add_key_binding('E', "toggle-dnm", toggle_dnm)
mp.add_key_binding('S', "toggle-sfa", toggle_sfa)

mp.register_event("file-loaded", init_filter)
