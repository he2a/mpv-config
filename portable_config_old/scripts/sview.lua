-- A simple script to show multiple shaders running, in a clean list.
local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local opt = require 'mp.options'
local o = {
	show_change = 'yes',
	show_number = 'no',
	show_extension = 'no',
	bullet_symbol = '›',
	flash_timer = 2
}
local function txt2bool(txt)
	if (txt == 'yes') or (txt == 'true') then
		return true
	else
		return false
	end
end
opt.read_options(o)
local delay_tm = 1
local list_sym = o.bullet_symbol
local flash_tm = o.flash_timer
local reactive = txt2bool(o.show_change)
local show_num = txt2bool(o.show_number)
local show_ext = txt2bool(o.show_extension)
sview_ov = mp.create_osd_overlay("ass-events")
shader_t = false
reactive_sview = false
function inlnCond ( cond , yes , no )
    if cond then return yes else return no end
end
function slist(input)
    local shaderName = {}
    local shaderPath = {}
    
    if not input or input == '' then
        sview_ov.data = "{\\b1}No shaders loaded.{\\b0}"
        return
    end
    
    pcall(function()
        for path in input:gmatch("[^;:]+") do
            table.insert(shaderPath, path)
        end
    end)
    
    if #shaderPath > 0 then
        for _, path in ipairs(shaderPath) do
            local fileName = path:match(".+[\\/](.+)$")
            
            if fileName then
                local name = fileName:match("(.+)%.[^.]+$") or fileName
                table.insert(shaderName, inlnCond((not show_ext) and name, name, fileName))
            else
                table.insert(shaderName, path)
            end
        end
        
        local listString = "{\\r\\b1}Shaders Loaded{\\b0\\fscx75\\fscy75}\\N"
        for i, fileName in ipairs(shaderName) do
            listString = listString .. inlnCond(show_num,i .. "\\h",'') .. list_sym .. "\\h" .. fileName .. "\\N"
        end
        sview_ov.data = listString
    else
        sview_ov.data = "{\\b1}No shaders loaded.{\\b0}"
    end
end

function toggle_sview()
	if shader_t then
		shader_t = false
		sview_ov:remove()
	else
		shader_t = true
		update_list()
	end
end

delay_start = mp.add_periodic_timer(delay_tm, 
	function()
		reactive_sview = true
		delay_start:kill()
	end, true)
	
delay_update = mp.add_periodic_timer(flash_tm, 
	function()
		sview_ov:remove()
		delay_update:kill()
	end, true)
	
function update_list()
    local shader_property = ""
    pcall(function()
        shader_property = mp.get_property('glsl-shaders') or ""
    end)
    
	mp.osd_message("", 0)
	if shader_t then
		slist(shader_property)
		sview_ov:update()
	elseif reactive_sview and reactive then
		slist(shader_property)
		sview_ov:update()
		delay_update:resume()
	end
end

function clear_shaders()
    local shader_property = ""
    pcall(function()
        shader_property = mp.get_property('glsl-shaders') or ""
    end)
    
	if shader_property ~= '' then
		mp.command('change-list glsl-shaders clr all')
	end
end

mp.add_key_binding(nil, 'shader-view', toggle_sview)
mp.add_key_binding(nil, 'shader-clear', clear_shaders)

mp.register_event("end-file", 
	function()
		if delay_start:is_enabled() then 
			delay_start:kill()
		end
	end)
	
mp.register_event("start-file", 
	function()
		reactive_sview = false
		sview_ov:remove()
	end)
	
mp.register_event("file-loaded", 
	function()
		if not delay_start:is_enabled() then 
			delay_start:resume() 
		else
			delay_start:kill()
			delay_start:resume() 
		end
	end)
	
mp.observe_property('glsl-shaders', nil, function(name, value)
    update_list()
end)