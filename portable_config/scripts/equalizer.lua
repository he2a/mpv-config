local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local opt = require 'mp.options'

local o = {
	preamp = 0,
	
	eqr_enabled = 'no',
	eqr_file = '~~/script-opts/equalizer/default.csv',
	eqr_whitelist = 'audio',
	
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

local function parseLine(line)
  local element = {}
  for value in line:gmatch("[^,]+") do
    table.insert(element, value)
  end
  return element
end

local function readEQFile(file_path)
  local skipFirstRow = true
  local file = io.open(file_path, 'r')
  
  if not file then
    mp.msg.error("Failed to load equalizer file: " .. file_path)
    return nil
  end
  
  local eq_array = {}
  
  for line in file:lines() do
    if skipFirstRow then
        skipFirstRow = false
    else
        local band = parseLine(line)
		if band[4] ~= 0 then
			local entry = {
				filter_type = band[1],
				frequency = band[2],
				width_type = band[3],
				width = band[4],
				gain = band[5]
			}
			table.insert(eq_array, entry)
		end
    end
  end
  file:close()
  return eq_array
end

opt.read_options(o)

local first_run  = true
local med_type   = nil
local vid_length = o.vid_threshold
local vid_aratio = o.vid_arlimit
local auto_delay = 0.2

local eqr_whlist = o.eqr_whitelist
local eqr_enable = txt2bool(o.eqr_enabled)

local eqr_filter = { enabled = false, bands = readEQFile(mp.command_native({"expand-path", o.eqr_file})) }
local pre_filter = { enabled = false, syntax = 'volume=volume=' .. o.preamp .. 'dB:precision=fixed' }

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
  if (a == 'allav') or (a == b) then
    return true
  elseif (a == 'video') and (b == 'movie') then
    return true
  else
    return false
  end
end


-- Filter Push --------------------------------------------------------------------------------------

local function eq_syntax(f_type)
  if (f_type == 'p') then
    return 'equalizer'
  elseif (f_type == 'l') then
    return 'lowshelf'
  elseif (f_type == 'h') then
    return 'highshelf'
  else
    mp.msg.error("Error in eq_syntax function. Unknown argument " .. f_type .. ". Defaulting to peaking filter.")
    return 'equalizer'
  end
end

local function updateEQ()
  if eqr_filter.enabled and pre_filter.enabled then 
    mp.command('no-osd af add ' .. pre_filter.syntax)
  else
    mp.command('no-osd af remove ' .. pre_filter.syntax)
  end
  if eqr_filter.bands then
    for i = 1, #eqr_filter.bands do
      local f = eqr_filter.bands[i]
      if f.gain ~= 0 then
        if eqr_filter.enabled then 
          mp.command('no-osd af add ' .. eq_syntax(f.filter_type) .. '=f=' .. f.frequency .. ':t=' .. f.width_type .. ':w=' .. f.width .. ':g=' .. f.gain)
        else
          mp.command('no-osd af remove ' .. eq_syntax(f.filter_type) .. '=f=' .. f.frequency .. ':t=' .. f.width_type .. ':w=' .. f.width .. ':g=' .. f.gain)
        end
      end
    end
  end
end

local function toggle_eqr()
  eqr_filter.enabled = not eqr_filter.enabled
  updateEQ()
  if eqr_filter.enabled then mp.osd_message("Equalizer ON") else mp.osd_message("Equalizer OFF") end
end

-- Script init/deinit --------------------------------------------------------------------------------------

local function init_filter()
  if first_run then
    mp.command('no-osd af clr ""')
    first_run = false
  else
    if eqr_filter.enabled then 
      eqr_filter.enabled = false
      updateEQ()
    end
    med_type = nil
  end

  if preamp ~= 0 then 
    pre_filter.enabled = true
  else
    pre_filter.enabled = false 
  end
  delay = mp.add_timeout(auto_delay,
    function()
      med_type = type_check()
      if med_type ~= 'anull' and eqr_enable and type_compare(eqr_whlist, med_type) then
        eqr_filter.enabled = true
        updateEQ()
      end
      delay:kill()
      delay = nil
    end
  )
end

-- Events and bindings code --------------------------------------------------------------------------------------------------------------------------

mp.add_key_binding('E', "toggle-eqr", toggle_eqr)
mp.register_event("file-loaded", init_filter)