-- To show multiple shaders in a clean way.

function shader_view()
	shdr = mp.get_property_osd('glsl-shaders')
	if (shdr == "") then
		mp.osd_message("")
	else
		shdr = shdr:gsub(",", "\n• ")
		shdr = shdr:gsub("~~/", "")
		shdr = shdr:gsub("/", " - ")
		mp.osd_message("Shaders Loaded:\n• " .. shdr)
	end
end

mp.observe_property('glsl-shaders', "string", shader_view)
mp.add_key_binding(nil, "shader-view", shader_view)