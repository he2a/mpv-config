-- A simple script to show multiple shaders running, in a clean list. Also hides osd messages of shader changes.

local function osd_f(shdr)
  if shdr ~= '' then
    shdr = shdr:gsub(',', '\n> ')
    shdr = shdr:gsub('~~/', '')
    shdr = shdr:gsub('/', ' - ')
    mp.osd_message('Shader:\n> ' .. shdr, 2)
  else
    mp.osd_message('')
  end
end 

local function shader_watch()
  s = mp.get_property('glsl-shaders')
  if s ~= '' then
      osd_f(s)
  else
    mp.osd_message('')
  end
end

local function hide_msg()
  mp.osd_message('')
--  shader_watch()
end

mp.add_key_binding(nil, 'shader-view', shader_watch)
mp.observe_property('glsl-shaders', nil, hide_msg)