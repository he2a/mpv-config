-- A simple script to show multiple shaders running, in a clean list.

sview_ov = mp.create_osd_overlay("ass-events")
shader_t = false
reactive_sview = false

delay_time = 1
flash_time = 2

function slist(input)
    local fileNames = {}
    local paths = {}
	if input ~= '' then
		for path in input:gmatch("[^;]+") do
			table.insert(paths, path)
		end

		for _, path in ipairs(paths) do
			local fileName = path:match(".+/(.+)$") or path:match(".+\\(.+)$")
			if fileName then
				table.insert(fileNames, fileName)
			end
		end
		
		local listString = "{\\b1}Shaders loaded:{\\b0}"
		for i, fileName in ipairs(fileNames) do
			listString = listString .. "\n" .. i .. "❯ " .. fileName
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

delay_start = mp.add_periodic_timer(delay_time, 
	function()
		reactive_sview = true
		delay_start:kill()
	end, true)

delay_update = mp.add_periodic_timer(flash_time, 
	function()
		sview_ov:remove()
		delay_update:kill()
	end, true)

function update_list()
	mp.osd_message('')
	if shader_t then
		slist(mp.get_property('glsl-shaders'))
		sview_ov:update()
	elseif reactive_sview then
		slist(mp.get_property('glsl-shaders'))
		sview_ov:update()
		delay_update:resume()
	end
end

function clear_shaders()
	if mp.get_property('glsl-shaders') ~= '' then
		mp.command('change-list glsl-shaders clr all')
	end
end

mp.add_key_binding(nil, 'shader-view', toggle_sview)
mp.add_key_binding(nil, 'shader-clear', clear_shaders)

mp.register_event("start-file", 
	function()
		reactive_sview = false
		sview_ov:remove()
	end)

mp.register_event("file-loaded", 
	function()
		if not delay_start:is_enabled() then 
			delay_start:resume() 
		end
	end)

mp.observe_property('glsl-shaders', nil, update_list)