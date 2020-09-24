-- Couple of short snipplets for personal use.

function shader_view()
	shdr = mp.get_property_osd('glsl-shaders')
	if (shdr == "")
	then
		mp.osd_message("No Shaders Loaded")
	else
		shdr = shdr:gsub(",", "\n")
		shdr = shdr:gsub("~~/", "• ")
		shdr = shdr:gsub("/", " - ")
		mp.osd_message("Shaders Loaded:\n" .. shdr)
	end
end

mp.add_key_binding(nil, "loaded-shaders", shader_view)