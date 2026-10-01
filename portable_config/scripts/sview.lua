-- A simple script to show multiple shaders running, in a clean list.
local mp = require 'mp'
local msg = require 'mp.msg'
local opt = require 'mp.options'

local o = {
    show_change = 'yes',
    show_number = 'no',
    show_extension = 'no',
    bullet_symbol = '›',
    flash_timer = 2
}
opt.read_options(o)

local list_sym = o.bullet_symbol
local flash_tm = o.flash_timer
local reactive = (o.show_change == 'yes' or o.show_change == 'true')
local show_num = (o.show_number == 'yes' or o.show_number == 'true')
local show_ext = (o.show_extension == 'yes' or o.show_extension == 'true')

local sview_ov = mp.create_osd_overlay("ass-events")
local persistent_mode = false
local playback_ready = false
local settle_timer = nil
local saved_shaders = nil

-- Timer to hide the reactive overlay
local hide_timer = mp.add_timeout(flash_tm, function()
    if not persistent_mode then
        sview_ov:remove()
    end
end)
hide_timer:kill()

-- Debounce timer to handle multiple rapid shader changes gracefully
local debounce_timer = mp.add_timeout(0.05, function()
    render_slist()
end)
debounce_timer:kill()

function render_slist()
    local input = mp.get_property('glsl-shaders', '')
    local shaderName = {}
    
    if input ~= '' then
        for path in input:gmatch("[^;:]+") do
            local fileName = path:match(".+[\\/](.+)$") or path
            local name = fileName:match("(.+)%.[^.]+$") or fileName
            
            table.insert(shaderName, show_ext and fileName or name)
        end

        local listString = "{\\r\\b1}Shaders Loaded{\\b0\\fscx75\\fscy75}\\N"
        
        for i, sName in ipairs(shaderName) do
            local prefix = show_num and (i .. "\\h" .. list_sym .. "\\h") or (list_sym .. "\\h")
            listString = listString .. prefix .. sName .. "\\N"
        end
        
        sview_ov.data = listString
    else
        sview_ov.data = "{\\b1}No shaders loaded.{\\b0}"
    end
    
    sview_ov:update()
    
    if not persistent_mode then
        hide_timer:kill()
        hide_timer:resume()
    end
end

function toggle_sview()
    persistent_mode = not persistent_mode
    if persistent_mode then
        hide_timer:kill()
        debounce_timer:kill()
        render_slist()
    else
        sview_ov:remove()
    end
end

function on_shader_change(name, value)
    -- Programmatic attempt to clear standard OSD text
    mp.commandv("show-text", "", 0)
    
    if persistent_mode then
        debounce_timer:kill()
        debounce_timer:resume()
    elseif reactive and playback_ready then
        debounce_timer:kill()
        debounce_timer:resume()
    end
end

function clear_shaders()
	if mp.get_property('glsl-shaders') ~= '' then
		mp.command('change-list glsl-shaders clr all')
	end
end

function shader_debug()
    if saved_shaders == nil then
        local current_shaders = mp.get_property('glsl-shaders', '')
        if current_shaders == '' then
            msg.info("No shaders loaded.")
        else
            saved_shaders = current_shaders
            mp.command('no-osd change-list glsl-shaders clr all')
        end
    else
        mp.command('no-osd change-list glsl-shaders clr all')
        mp.set_property('glsl-shaders', saved_shaders)
        saved_shaders = nil
    end
end

mp.add_key_binding(nil, 'shader-view', toggle_sview)
mp.add_key_binding(nil, 'shader-clear', clear_shaders)
mp.add_key_binding(nil, 'shader-debug', shader_debug)

mp.register_event("start-file", function()
    -- Lock reactive UI and clear entirely on new file load
    playback_ready = false
    persistent_mode = false
    
    -- Reset the shader-debug toggle state
    saved_shaders = nil
    
    -- Safely kill the settle timer if files are loaded in rapid succession
    if settle_timer then
        settle_timer:kill()
        settle_timer = nil
    end
    
    hide_timer:kill()
    debounce_timer:kill()
    sview_ov:remove()
end)

mp.register_event("playback-restart", function()
    -- Video output has initialized. Start a 1-second suppression window
    -- to allow all delayed autoprofiles and system lags to finish flushing.
    if not playback_ready and not settle_timer then
        settle_timer = mp.add_timeout(1.0, function()
            playback_ready = true
            settle_timer = nil
        end)
    end
end)

mp.observe_property('glsl-shaders', 'string', on_shader_change)