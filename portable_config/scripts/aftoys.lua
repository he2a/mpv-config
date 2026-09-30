local mp = require 'mp'
local msg = require 'mp.msg'
local opt = require 'mp.options'

-- Debug toggle (set to true to enable console logging)
local DEBUG = false

local o = {
	sfa_file = '~~/script-opts/sofa/ClubFritz6.sofa',
	sfa_type = 'time',
	sfa_gain = 10,
	sfa_lfe = 2,
	sfa_rad = 1,
	
	drc_knee = 2.8,
	drc_ratio = 2,
	drc_makeup = 8,
	drc_attack = 20,
	drc_release = 250,
	drc_threshold = -20,
	
	dnm_gauss = 5,
	dnm_ratio = 4,
	dnm_frame = 400,
	dnm_peak = 0.95,
	dnm_minthres = 0,
	
	lnm_target = -16,
	lnm_range = 8,
	lnm_peak = -2,
	
	snm_peak = 0.9,
	snm_expand = 4,
	snm_compress = 2,
	snm_threshold = 0.2,
	snm_raise = 0.0001,
	snm_fall = 0.0005,
	snm_invert = 1,
	
	eqr_preamp = 0,
	eqr_file = '~~/script-opts/equalizers/default.csv',
	
	sfa_whitelist = 'ma|ms|ml',
	drc_whitelist = 'a|ma',
	dnm_whitelist = 'n',
	lnm_whitelist = 's|l',
	snm_whitelist = 'ms|ml',
	eqr_whitelist = 'l|ml',
	
	vid_threshold = 600,
	vid_arlimit = 1.2
}

opt.read_options(o)

-- Auxilliary Functions --

local function dprint(text)
	if DEBUG then mp.msg.info("[AF-Toys] " .. text) end
end

local function filechk(path)
	if not path or path == "" then 
		mp.msg.error("[AF-Toys] filechk: Path is empty!")
		return false 
	end
	
	dprint("Checking file: " .. path)
	local file = io.open(path, 'r')
	if not file then
		mp.msg.warn("[AF-Toys] Failed to load file: " .. path)
        return false
	else
        file:close()
		dprint("File found successfully: " .. path)
        return true
	end
end

local function parseln(line)
	local element = {}
	for value in line:gmatch("[^,]+") do table.insert(element, value) end
	return element
end

local function readEQFile(file_path)
	if not file_path then return nil end
	local skipFirstRow = true
	local file = io.open(file_path, 'r')
	if not file then return nil end
	local eq_array = {}

	for line in file:lines() do
		if skipFirstRow then
			skipFirstRow = false
		else
			local band = parseln(line)
			if band[4] ~= 0 then
				table.insert(eq_array, {
					filter_type = band[1], frequency = band[2],
					width_type = band[3], width = band[4], gain = band[5]
				})
			end
		end
	end
	file:close()
	return eq_array
end

local function eq_syntax(f_type)
  if (f_type == 'p') then return 'equalizer'
  elseif (f_type == 'l') then return 'lowshelf'
  elseif (f_type == 'h') then return 'highshelf'
  else return 'equalizer' end
end

local function wlcheck(key,wl)
	if key ~= nil and wl ~= nil then
		local media_type = '|' .. key .. '|'
		local media_whtl = '|' .. wl .. '|'
		local match = string.find(media_whtl, media_type, 1, true) ~= nil
		dprint(string.format("wlcheck - Key: '%s', Whitelist: '%s' -> Match: %s", key, wl, tostring(match)))
		return match
	end
	return false
end

-- Resolve Paths Cleanly --
local sfa_path = mp.command_native({"expand-path", o.sfa_file}) or ""
sfa_path = sfa_path:gsub('\\', '/') -- Standardize slashes for FFmpeg

local eqr_path = mp.command_native({"expand-path", o.eqr_file}) or ""

-- Main Functions --

local drc_filter = { name = "drc", active = false, syntax = 'acompressor=threshold=' .. o.drc_threshold .. 'dB:ratio=' .. o.drc_ratio .. ':attack=' .. o.drc_attack .. ':release=' .. o.drc_release .. ':makeup=' .. o.drc_makeup .. 'dB:knee=' .. o.drc_knee .. 'dB' }
local dnm_filter = { name = "dnm", active = false, syntax = 'dynaudnorm=f=' .. o.dnm_frame .. ':g=' .. o.dnm_gauss .. ':m=' .. o.dnm_ratio .. ':p=' .. o.dnm_peak .. ':t=' .. o.dnm_minthres }
local snm_filter = { name = "snm", active = false, syntax = 'speechnorm=p=' .. o.snm_peak .. ':e=' .. o.snm_expand .. ':c=' .. o.snm_compress .. ':t=' .. o.snm_threshold .. ':r=' .. o.snm_raise .. ':f=' .. o.snm_fall .. ':i=' .. o.snm_invert }
local lnm_filter = { name = "lnm", active = false, syntax = 'loudnorm=i=' .. o.lnm_target .. ':lra=' .. o.lnm_range .. ':tp=' .. o.lnm_peak }
local sfa_filter = { name = "sfa", active = false, enabled = filechk(sfa_path), syntax = string.format('sofalizer=sofa="%s":type=%s:radius=%s:gain=%s:lfegain=%s', sfa_path, o.sfa_type, o.sfa_rad, o.sfa_gain, o.sfa_lfe) }
local eqr_filter = { name = "eqr", active = false, enabled = filechk(eqr_path), syntax = 'volume=volume=' .. o.eqr_preamp .. 'dB:precision=fixed', bands = readEQFile(eqr_path) }

local function apply_filter(filter)
	local action = filter.active and "add" or "remove"
	dprint(string.format("Action: %s | Filter: %s | Syntax: %s", action:upper(), filter.name, filter.syntax))
	
	-- Execute command and catch any potential Lua errors
	local success, err = pcall(function()
		mp.command_native({"no-osd", "af", action, filter.syntax})
	end)
	
	if not success then
		mp.msg.error(string.format("[AF-Toys] Command execution failed for %s: %s", filter.name, tostring(err)))
	end
end

local function push_eq()
	if eqr_filter.enabled and eqr_filter.bands then
		for i = 1, #eqr_filter.bands do
			local f = eqr_filter.bands[i]
			if f.gain ~= 0 then
				local syntax = eq_syntax(f.filter_type) .. '=f=' .. f.frequency .. ':t=' .. f.width_type .. ':w=' .. f.width .. ':g=' .. f.gain
				local action = eqr_filter.active and "add" or "remove"
				mp.command_native({"no-osd", "af", action, syntax})
			end
		end
	end
end

local function toggle_drc(flag)
	drc_filter.active = not drc_filter.active
	apply_filter(drc_filter)
	if flag ~= 1 then mp.osd_message("Dynamic Range Compressor " .. (drc_filter.active and "ON" or "OFF")) end
end

local function toggle_dnm(flag)
	dnm_filter.active = not dnm_filter.active
	apply_filter(dnm_filter)
	if flag ~= 1 then mp.osd_message("Dynamic Audio Normalizer " .. (dnm_filter.active and "ON" or "OFF")) end
end

local function toggle_snm(flag)
	snm_filter.active = not snm_filter.active
	apply_filter(snm_filter)
	if flag ~= 1 then mp.osd_message("Speech Normalizer " .. (snm_filter.active and "ON" or "OFF")) end
end

local function toggle_lnm(flag)
	lnm_filter.active = not lnm_filter.active
	apply_filter(lnm_filter)
	if flag ~= 1 then mp.osd_message("Loudness Normalizer " .. (lnm_filter.active and "ON" or "OFF")) end
end

local function toggle_sfa(flag)
	if not sfa_filter.enabled then
		mp.msg.warn("[AF-Toys] Sofalizer toggle attempted, but filter is not enabled. Check if file exists.")
	end
	sfa_filter.active = not sfa_filter.active
	apply_filter(sfa_filter)
	if flag ~= 1 then mp.osd_message("Sofalizer " .. (sfa_filter.active and "ON" or "OFF")) end
end

local function toggle_eqr(flag)
	eqr_filter.active = not eqr_filter.active
	if (o.eqr_preamp < 0 or o.eqr_preamp > 0) then apply_filter(eqr_filter) end
	push_eq()
	if flag ~= 1 then mp.osd_message("Equalizer " .. (eqr_filter.active and "ON" or "OFF")) end
end

local function mdcheck()
	local aid = mp.get_property_native("aid") or false
	local mkey = ''
	
	if not aid then
		mkey = 'n'
	else	
		local ch = mp.get_property_native("audio-params/channel-count") or 2
		local vid = mp.get_property_native("vid") or false
		local fps = mp.get_property_native("estimated-vf-fps") or 0
		local ar = mp.get_property_native("video-params/aspect") or 0
		local tt = mp.get_property_native("duration") or 0
		local vt = o.vid_threshold
		local vr = o.vid_arlimit
		
		dprint(string.format("mdcheck stats - Channels: %s, fps: %s, ar: %s, duration: %s", tostring(ch), tostring(fps), tostring(ar), tostring(tt)))
		
		if not vid or (fps <= 1) then
			mkey = 'a'
		elseif (ar >= vr) and (tt >= vt) then
			mkey = 'l'
		elseif (tt < vt) then
			mkey = 's'
		else
			mkey = 'n'
		end
		
		if (ch > 2) then
			mkey = 'm' .. mkey
		end
	end
	dprint("Calculated media key (mkey): " .. mkey)
	return mkey or 'n'
end

-- Script init --

local first_run = true

local function init()
	dprint("---------- SCRIPT INIT TRIGGERED ----------")
	if first_run then
		mp.command_native({"no-osd", "af", "clr", ""})
		first_run = false
	else
		if drc_filter.active then drc_filter.active = false; apply_filter(drc_filter) end
		if dnm_filter.active then dnm_filter.active = false; apply_filter(dnm_filter) end
		if snm_filter.active then snm_filter.active = false; apply_filter(snm_filter) end
		if lnm_filter.active then lnm_filter.active = false; apply_filter(lnm_filter) end
		if sfa_filter.enabled and sfa_filter.active then sfa_filter.active = false; apply_filter(sfa_filter) end
		if eqr_filter.enabled and eqr_filter.active then 
			eqr_filter.active = false
			if (o.eqr_preamp < 0 or o.eqr_preamp > 0) then apply_filter(eqr_filter) end
			push_eq()
		end
	end
		
	local med_type = mdcheck()
	
	if med_type ~= 'n' then
		if wlcheck(med_type,o.sfa_whitelist) then toggle_sfa(1) end
		if wlcheck(med_type,o.snm_whitelist) then toggle_snm(1) end
		if wlcheck(med_type,o.lnm_whitelist) then toggle_lnm(1) end
		if wlcheck(med_type,o.dnm_whitelist) then toggle_dnm(1) end
		if wlcheck(med_type,o.drc_whitelist) then toggle_drc(1) end
		if wlcheck(med_type,o.eqr_whitelist) then toggle_eqr(1) end
	end
	dprint("---------- INIT COMPLETE ----------")
end

mp.add_key_binding('c', "toggle-drc", toggle_drc)
mp.add_key_binding('n', "toggle-snm", toggle_snm)
mp.add_key_binding('l', "toggle-lnm", toggle_lnm)
mp.add_key_binding('d', "toggle-dnm", toggle_dnm)
mp.add_key_binding('S', "toggle-sfa", toggle_sfa)
mp.add_key_binding('E', "toggle-eqr", toggle_eqr)

-- Safe Init Handling --

local init_timer = nil

local function try_init()
	local aid = mp.get_property_native("aid")
	local vid = mp.get_property_native("vid")
	
	if aid and not mp.get_property_native("audio-params/channel-count") then 
		dprint("Delaying init: Waiting for audio channel count")
		return false 
	end
	if vid and (not mp.get_property_native("estimated-vf-fps") or not mp.get_property_native("video-params/aspect")) then 
		dprint("Delaying init: Waiting for video aspect/fps")
		return false 
	end
	
	return true
end

mp.register_event("start-file", function()
	if init_timer then
		init_timer:kill()
		init_timer = nil
		dprint("start-file event: Killed pending init timer.")
	end
end)

mp.register_event("file-loaded", function()
	if init_timer then init_timer:kill() end
	local attempts = 0
	
	init_timer = mp.add_periodic_timer(0.1, function()
		attempts = attempts + 1
		
		if try_init() or attempts > 30 then
			if attempts > 30 then mp.msg.warn("[AF-Toys] Init timed out after 3 seconds, forcing run.") end
			init_timer:kill()
			init_timer = nil
			init()
		end
	end)
end)