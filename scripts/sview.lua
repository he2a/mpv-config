-- To show multiple shaders in a clean way.

local function osd_f(shdr)
  if shdr ~= '' then
    shdr = shdr:gsub(',', '\n• ')
    shdr = shdr:gsub('~~/', '')
    shdr = shdr:gsub('/', ' - ')
  end
  mp.osd_message('Shader:\n• ' .. shdr)
end 

local function shader_watch()
  s = mp.get_property_osd('glsl-shaders')
  if s ~= '' then
    osd_f(s)
  else
    mp.osd_message('')
  end
end

local function shader_view()
  if mp.get_property_osd('glsl-shaders') ~= '' then
    osd_f(s)
  else
    mp.osd_message('No shaders loaded.')
  end
end

mp.observe_property('glsl-shaders', nil, shader_watch)
mp.add_key_binding(nil, 'shader-view', shader_view)