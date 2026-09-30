local mp = require 'mp'
local msg = require 'mp.msg'
local opt = require 'mp.options'

local debug_mode = true 

-- Threshold limits for triggering profiles
local limit_duration = 2400           -- Length threshold in seconds (e.g., 40 mins)
local limit_aspect_ratio = 1.85       -- Aspect ratio threshold (wider/equal to this is considered a movie)
local limit_upscale_ratio = 0.75      -- Video-to-display ratio threshold for upscaling (<=)
local limit_downscale_ratio = 2.0     -- Video-to-display ratio threshold for downscaling (>=)

local o = {
    default     = "", -- 0. Default (Fallback)
    audio       = "",    -- 1. Audio
    image       = "",    -- 2. Image

    -- 3.1 Standard Video
    std_base    = "",       -- 3.1.1 Video - Standard
    std_up      = "",    -- 3.1.2 Video - Standard - Upscale
    std_down    = "",  -- 3.1.3 Video - Standard - Downscale
    std_long    = "",       -- 3.1.4 Video - Standard - Long
    std_short   = "",      -- 3.1.5 Video - Standard - Short
    std_hdr     = "",        -- 3.1.6 Video - Standard - HDR

    -- 3.2 Anime Video
    anime_base  = "",       -- 3.2.1 Video - Anime
    anime_up    = "",    -- 3.2.2 Video - Anime - Upscale
    anime_down  = "",  -- 3.2.3 Video - Anime - Downscale
    anime_long  = "",       -- 3.2.4 Video - Anime - Long
    anime_short = "",      -- 3.2.5 Video - Anime - Short
    anime_hdr   = "",        -- 3.2.6 Video - Anime - HDR

    -- 3.3 Web Video
    web_base    = "",         -- 3.3.1 Video - Web
    web_up      = "",      -- 3.3.2 Video - Web - Upscale
    web_down    = "",    -- 3.3.3 Video - Web - Downscale
    web_long    = "",         -- 3.3.4 Video - Web - Long
    web_short   = "",         -- 3.3.5 Video - Web - Short
    web_hdr     = ""           -- 3.3.6 Video - Web - HDR
}

opt.read_options(o)

local user_profiles = o

local last_evaluated_path = nil
local profiles_cache = nil


function check_web_content(path)
    if path:match("^https?://") then return "y" end
    return "n"
end

function check_media_type(vid, aid, width, filename, tracks, fps)
    local ext = filename:match("^.+%.(.+)$")
    if ext then ext = string.lower(ext) end
    
    local is_audio_ext = (ext == "mp3" or ext == "wav" or ext == "ogm" or ext == "flac" or ext == "m4a" or ext == "wma" or ext == "ogg" or ext == "opus" or ext == "aac" or ext == "alac" or ext == "ape" or ext == "mka")
    local is_img_ext = (ext == "jpg" or ext == "jpeg" or ext == "png" or ext == "webp" or ext == "gif" or ext == "bmp" or ext == "avif" or ext == "jxl" or ext == "tiff")

    local is_cover_art = false
    for _, track in ipairs(tracks) do
        if track.type == "image" and track.image then
			msg.info("Cover art detected")
            break
        end
    end

    local audio_exists = (aid ~= "no" and aid ~= "")
    local video_exists = (vid ~= "no" and vid ~= "")

    if not audio_exists and (is_img_ext or is_cover_art or (video_exists and fps > 0 and fps <= 1)) then
        return "i"
    end
    if is_audio_ext then return "a" end
    if audio_exists then
        if not video_exists then return "a" end
        if video_exists and (is_cover_art and (fps > 0 and fps <= 1)) then return "a" end
    end
    if video_exists and width > 0 then return "v" end
    return "a"
end

function check_video_length(duration, ar, dur_limit, ar_limit)
    if ar >= ar_limit or duration >= dur_limit then return "l" end
    return "s"
end

function check_video_scale(width, height, d_width, d_height, up_limit, down_limit)
    if d_width > 0 and d_height > 0 then
        -- Calculate the ratio of the video to the display bounds
        local w_ratio = width / d_width
        local h_ratio = height / d_height
        
        -- Use the dimension that fits the tightest to determine scaling behavior
        local max_ratio = math.max(w_ratio, h_ratio)

        if max_ratio <= up_limit then 
            return "u" 
        elseif max_ratio >= down_limit then 
            return "d" 
        end
    end
    return "n" -- Native (falls outside thresholds, no scale profile triggered)
end

function check_hdr(gamma, primaries, colormatrix, file_format)
    if gamma == "pq" or gamma == "hlg" or primaries == "bt.2020" or (colormatrix and colormatrix:match("bt%.2020")) or file_format == "exr_pipe" or file_format == "hdr_pipe" then
        return "y"
    end
    return "n"
end

function check_anime(tracks, chapters, media_title)
    local anime_score = 0
    local has_ass = false
    local has_jp_audio = false

    for _, track in ipairs(tracks) do
        if track.type == "audio" and (track.lang == "jpn" or track.lang == "ja") then has_jp_audio = true end
        if track.type == "sub" and track.codec == "ass" then has_ass = true end
    end

    if has_jp_audio then anime_score = anime_score + 2 end
    if has_ass then anime_score = anime_score + 1 end

    for _, chapter in ipairs(chapters) do
        local title = string.lower(chapter.title or "")
        if title:match("part%s*%w+") or title:match("^op$") or title:match("^ed$") or title:match("preview") or title:match("opening") or title:match("ending") or title:match("[\227-\233][\128-\191][\128-\191]") then
            anime_score = anime_score + 2
            break
        end
    end

    if media_title:match("[\227-\233][\128-\191][\128-\191]") then anime_score = anime_score + 2 end
    if media_title:match("^%[.*%]") then anime_score = anime_score + 1 end
    if anime_score >= 3 then return "y" end
    return "n"
end

-- Caches the list of available profiles from mpv.conf so we aren't querying it constantly
function profile_exists(name)
    if not profiles_cache then
        profiles_cache = {}
        local list = mp.get_property_native("profile-list", {})
        for _, p in ipairs(list) do
            profiles_cache[p.name] = true
        end
    end
    return profiles_cache[name] == true
end

-- Tries to apply a profile, falls back to default if it fails
function apply_profile(target_profile, fallback_profile)
    if target_profile == nil or target_profile == "" then return end
    
    if profile_exists(target_profile) then
        mp.commandv("apply-profile", target_profile)
        if debug_mode then
            msg.info(">>> Applied Profile: " .. target_profile)
        end
    else
        if debug_mode then
            msg.error(">>> ERROR: Profile not found in mpv.conf - '" .. target_profile .. "'")
        end
        
        -- Attempt fallback if one is provided and it isn't the same as the target
        if fallback_profile ~= nil and fallback_profile ~= "" and fallback_profile ~= target_profile then
            if debug_mode then
                msg.info(">>> Attempting fallback profile: " .. fallback_profile)
            end
            if profile_exists(fallback_profile) then
                mp.commandv("apply-profile", fallback_profile)
                if debug_mode then
                    msg.info(">>> Applied Fallback Profile: " .. fallback_profile)
                end
            else
                if debug_mode then
                    msg.error(">>> ERROR: Fallback profile not found either - '" .. fallback_profile .. "'")
                end
            end
        end
    end
end

-- DEBUG FUNCTION
function print_debug_info(m_type, m_web, v_length, v_scale, v_hdr, v_anime)
    msg.info("--- Profile Trigger Script Results ---")
    msg.info("Media Type (m_type)  : " .. m_type)
    msg.info("Web Content (m_web)  : " .. m_web)
    
    if m_type == "v" then
        msg.info("Length (v_length)    : " .. v_length)
        msg.info("Scale (v_scale)      : " .. v_scale)
        msg.info("HDR (v_hdr)          : " .. v_hdr)
        msg.info("Anime (v_anime)      : " .. v_anime)
    end
    msg.info("--------------------------------------")
end

function evaluate_media()
    local path = mp.get_property("path", "")
    if path == "" then return end

    local vid = mp.get_property("vid", "no")
    local aid = mp.get_property("aid", "no")
    local tracks = mp.get_property_native("track-list", {})
    
    local fps = mp.get_property_number("container-fps", 0)
    if fps == 0 then fps = mp.get_property_number("estimated-vf-fps", 0) end

    -- Gatekeeper Logic
    if vid ~= "no" and vid ~= "" then
        local width = mp.get_property_number("width", 0)
        local gamma = mp.get_property("video-params/gamma", "")
        
        local is_real_video = true
        for _, track in ipairs(tracks) do
            if track.type == "video" and track.image then is_real_video = false break end
        end
        if fps > 0 and fps <= 1 then is_real_video = false end

        if is_real_video then
            if width == 0 or gamma == "" then return end
        end
    end

    if last_evaluated_path == path then return end
    last_evaluated_path = path

    -- Reset Profile Cache for new file evaluation
    profiles_cache = nil

    -- Data Collection
    local filename = mp.get_property("filename", "")
    local media_title = mp.get_property("media-title", "")
    local chapters = mp.get_property_native("chapter-list", {})
    local width = mp.get_property_number("width", 0)
    local height = mp.get_property_number("height", 0)
    local d_width = mp.get_property_number("display-width", 0)
    local d_height = mp.get_property_number("display-height", 0)
    local duration = mp.get_property_number("duration", 0)
    local ar = mp.get_property_number("video-params/aspect", 0)
    if ar == 0 and height > 0 then ar = width / height end

    local gamma = mp.get_property("video-params/gamma", "")
    local primaries = mp.get_property("video-params/primaries", "")
    local colormatrix = mp.get_property("video-params/colormatrix", "")
    local file_format = mp.get_property("file-format", "")

    -- Execute Checks
    local m_web = check_web_content(path)
    local m_type = check_media_type(vid, aid, width, filename, tracks, fps)
    
    local v_length = "s"
    local v_scale = "n"
    local v_hdr = "n"
    local v_anime = "n"

    if m_type == "v" then
        v_length = check_video_length(duration, ar, limit_duration, limit_aspect_ratio)
        v_scale = check_video_scale(width, height, d_width, d_height, limit_upscale_ratio, limit_downscale_ratio)
        v_hdr = check_hdr(gamma, primaries, colormatrix, file_format)
        v_anime = check_anime(tracks, chapters, media_title)
    end

    if debug_mode then
        print_debug_info(m_type, m_web, v_length, v_scale, v_hdr, v_anime)
    end
    
-- Triggers
    local def = user_profiles.default

    if m_type == "a" then
        apply_profile(user_profiles.audio, def)
        
    elseif m_type == "i" then
        apply_profile(user_profiles.image, def)
        
    elseif m_type == "v" then
        
        -- Branch 1: Web Video
        if m_web == "y" then
            apply_profile(user_profiles.web_base, def)
            
            if v_scale == "u" then apply_profile(user_profiles.web_up, "")
            elseif v_scale == "d" then apply_profile(user_profiles.web_down, "") end
            
            if v_length == "l" then apply_profile(user_profiles.web_long, "")
            else apply_profile(user_profiles.web_short, "") end
            
            if v_hdr == "y" then apply_profile(user_profiles.web_hdr, "") end
            
        -- Branch 2: Anime Video
        elseif v_anime == "y" then
            apply_profile(user_profiles.anime_base, def)
            
            if v_scale == "u" then apply_profile(user_profiles.anime_up, "")
            elseif v_scale == "d" then apply_profile(user_profiles.anime_down, "") end
            
            if v_length == "l" then apply_profile(user_profiles.anime_long, "")
            else apply_profile(user_profiles.anime_short, "") end
            
            if v_hdr == "y" then apply_profile(user_profiles.anime_hdr, "") end
            
        -- Branch 3: Standard Video
        else
            apply_profile(user_profiles.std_base, def)
            
            if v_scale == "u" then apply_profile(user_profiles.std_up, "")
            elseif v_scale == "d" then apply_profile(user_profiles.std_down, "") end
            
            if v_length == "l" then apply_profile(user_profiles.std_long, "")
            else apply_profile(user_profiles.std_short, "") end
            
            if v_hdr == "y" then apply_profile(user_profiles.std_hdr, "") end
        end
    else
        -- Ultimate fallback if type is somehow entirely unknown
        apply_profile(def, "")
    end
end

mp.register_event("file-loaded", function()
    last_evaluated_path = nil
    evaluate_media() 
end)
mp.observe_property("video-params", "native", evaluate_media)