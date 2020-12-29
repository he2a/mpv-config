-- settings
-- denoisers: specify names of denoise libavfilter filters
--     from `mpv --vf=lavfi=help` command
--     where the last 3 filters (dctdnoiz, owdenoise, nlmeans)
--     are too slow to be used in playback
local denoisers = {
    "removegrain"
    ,"atadenoise"
    ,"hqdn3d"
--    ,"vaguedenoiser"
--    ,"dctdnoiz"
--    ,"owdenoise"
--    ,"nlmeans"
}

local denoiser_count = #denoisers
local filter_index = 1
local script_name = mp.get_script_name()
local denoise_label = string.format("%s-denoise", script_name)

-- from https://github.com/mpv-player/mpv/blob/39e04e929483847a3e0722d86d53f69837ed99db/TOOLS/lua/autocrop.lua
function del_filter_if_present(label)
    -- necessary because mp.command('vf del @label:filter') raises an
    -- error if the filter doesn't exist
    local vfs = mp.get_property_native("vf")
    for i,vf in pairs(vfs) do
        if vf["label"] == label then
            table.remove(vfs, i)
            mp.set_property_native("vf", vfs)
            return true
        end
    end
    return false
end

function cycle_denoise()
    if not del_filter_if_present(denoise_label) then
        filter_index = 1
    end

    if filter_index > denoiser_count then
        mp.osd_message("Denoise filters removed.", osd_time)
        return
    end

    -- insert the filter
    ret=mp.command(
        string.format(
            'vf add @%s:lavfi=graph="%s"',
            denoise_label, denoisers[filter_index]
        )
    )

    filter_index = filter_index + 1
end

mp.add_key_binding("x", "denoise", cycle_denoise)