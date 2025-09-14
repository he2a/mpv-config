-- A simple mpv benchmark script. If you see fps getting capped at refresh rate, disable any vsync related options or force disable vsync from your GPU control panel.

local mp = require 'mp'
local msg = require 'mp.msg'
local opt = require 'mp.options'
local utils = require 'mp.utils'

local o = {
	duration = 3,
	poll_rate = 50,
	bullet_symbol = '›',
	flash_timer = 10,
	key_bind = 'B',
	write_log = 'yes',
	log_filename = 'benchmark',
	log_title = 'yes'
}

opt.read_options(o)

local benchmark_started = false
local benchmark_running = false
local fps_array = {}
local timeri = nil
local timero = nil
local timerd = nil
local timerp = nil

local function txt2bool(txt)
	if (txt == 'yes') or (txt == 'true') then
		return true
	else
		return false
	end
end

local BENCHMARK_DURATION = o.duration
local POLLING_RATE = o.poll_rate
local BULLET = o.bullet_symbol
local FLASHT = o.flash_timer
local TRIGGER_KEY = o.key_bind
local LOGOUT = txt2bool(o.write_log)
local LOGNAM = o.log_filename
local LOGTIT = txt2bool(o.log_title)

local oval = {
	mouse = nil,
    aid = nil,
    untimed = nil,
    framedrop = nil,
    video_sync = nil,
	loop = nil,
    gpu_property1 = nil,
    gpu_property2 = nil,
    gpu_property3 = nil
}

bview = mp.create_osd_overlay("ass-events")
bview.data = nil

local function writelog(out)
	local filename = mp.get_property("filename")
	local title = LOGNAM
	
	if LOGTIT then
		title = title .. "." .. filename .. ".log"
	else
		title = title .. ".log"
	end
	
	title:gsub('[\\/:*?"<>|]', '_')
	title:gsub('^[%.%s]+', ''):gsub('[%.%s]+$', '')
	
	local logtime = os.date("%y-%m-%d %H:%M:%S")
	local path = mp.command_native({"expand-path", "~~desktop/" .. title})
	local ltxt = "Benchmark - " .. logtime .. "\n\nFilename: " .. filename .. "\n\n" .. out
	local divider = "-----------------------------"
	local file = io.open(path, "a")
	file:write(ltxt .. "\n\n" .. divider .. "\n\n")
	file:close()
end

local function round(num)
    return math.floor(num * 100 + 0.5) / 100
end

local function calculate_percentile(array)
    if #array == 0 then return 0 end
    local index = math.ceil(#array / 100)
    return array[index]
end

local function calculate_median(array)
    if #array == 0 then return 0 end
    local mid = math.ceil(#array / 2)
    if #array % 2 == 0 then
        return (array[mid] + array[mid + 1]) / 2
    else
        return array[mid]
    end
end

local function calculate_average(array)
    if #array == 0 then return 0 end
    local sum = 0
    for _, value in ipairs(array) do
        sum = sum + value
    end
    return sum / #array
end

local function store_oval()
	msg.info("Storing original values")
    oval.aid = mp.get_property("aid")
    oval.untimed = mp.get_property("untimed")
    oval.framedrop = mp.get_property("framedrop")
    oval.video_sync = mp.get_property("video-sync")
    oval.mouse = mp.get_property("input-cursor")
    oval.loop = mp.get_property("loop-file")
    oval.gpu_property1 = mp.get_property("vulkan-swap-mode")
    oval.gpu_property2 = mp.get_property("opengl-swapinterval")
    oval.gpu_property3 = mp.get_property("d3d11-sync-interval")
end

local function set_value(arg)
    local gpu_api = mp.get_property("gpu-api")
	if arg then
		mp.set_property("aid", "no")
		mp.set_property("untimed", "yes")
		mp.set_property("framedrop", "no")
		mp.set_property("video-sync", "display-desync")
		mp.set_property("input-cursor", "no")
		mp.set_property("loop-file", "inf")
		if gpu_api then
			msg.info("GPU API detected - " .. gpu_api)
			gpu_api = gpu_api:lower()
			if gpu_api == "vulkan" then
				mp.set_property("vulkan-swap-mode", "immediate")
			elseif gpu_api == "opengl" then
				mp.set_property("opengl-swapinterval", "0")
			elseif gpu_api == "d3d11" then
				mp.set_property("d3d11-sync-interval", "0")
			elseif gpu_api == "auto" then
				mp.set_property("vulkan-swap-mode", "immediate")
				mp.set_property("opengl-swapinterval", "0")
				mp.set_property("d3d11-sync-interval", "0")
			else
				msg.warn("Unknown GPU API detected. Unable to fully turn off vsync.")
			end
		else
			msg.warn("GPU API detection failed. Unable to fully turn off vsync.")
		end
	else
		msg.info("Restoring changed settings.")
		mp.set_property("aid", oval.aid)
		mp.set_property("untimed", oval.untimed)
		mp.set_property("framedrop", oval.framedrop)
		mp.set_property("video-sync", oval.video_sync)
		mp.set_property("input-cursor", oval.mouse)
		mp.set_property("loop-file", oval.loop)
		if gpu_api then
			gpu_api = gpu_api:lower()
			if gpu_api == "vulkan" then
				mp.set_property("vulkan-swap-mode", oval.gpu_property1)
			elseif gpu_api == "opengl" then
				mp.set_property("opengl-swapinterval", oval.gpu_property2)
			elseif gpu_api == "d3d11" then
				mp.set_property("d3d11-sync-interval", oval.gpu_property3)
			elseif gpu_api == "auto" then
				mp.set_property("vulkan-swap-mode", oval.gpu_property1)
				mp.set_property("opengl-swapinterval", oval.gpu_property2)
				mp.set_property("d3d11-sync-interval", oval.gpu_property3)
			end
		end
	end
end

local function poll_fps()
    local fps = mp.get_property_number("estimated-display-fps")
    if fps and fps > 0 then
        table.insert(fps_array, fps)
    end
end

local function display_results()
	local fps_samples = fps_array
	if #fps_samples == 0 then
		msg.error("Benchmark failed: No samples collected.")
		bview.data = "{\\r\\b100}Benchmark Result{\\b0\\fscx75\\fscy75}\\N\\NTotal Samples: " .. #fps_samples
    else
		local sorted_fps = {}
		for i, v in ipairs(fps_samples) do
			sorted_fps[i] = v
		end
		table.sort(sorted_fps)
		
		local avg_fps = round(calculate_average(sorted_fps))
		local median_fps = round(calculate_median(sorted_fps))
		local low_fps = round(calculate_percentile(sorted_fps))
		local strout = "Average: " .. avg_fps .. " FPS\nMedian: " .. median_fps .. " FPS\n1% Low: " .. low_fps .. " FPS\n\nSamples: " .. #fps_samples .. "\nLost: " .. (BENCHMARK_DURATION * 1000 / POLLING_RATE) - #fps_samples
		bview.data = "{\\r\\b100}Benchmark Result{\\b0\\fscx75\\fscy75}\\N\\N" .. BULLET .. "\\hAverage:\\h" .. avg_fps .. "\\hFPS\\N" .. BULLET .. "\\hMedian:\\h" .. median_fps .. "\\hFPS\\N" .. BULLET .. "\\h1% Low:\\h" .. low_fps .. "\\hFPS\\N\\NSamples: " .. #fps_samples .. "\\NLost: " .. (BENCHMARK_DURATION * 1000 / POLLING_RATE) - #fps_samples
		
		if LOGOUT then
			writelog(strout)
		else
			msg.info("Benchmark completed.\n" .. strout)
		end
	end
	bview:update()		
	timero = mp.add_timeout(FLASHT, function()
		bview:remove()
		bview.data = nil
		if timero then
			timero:kill()
			timero = nil
		end
	end)
end

local function stop_benchmark(silent)
	if timerp then
		timerp:kill()
		timerp = nil
	end
	if benchmark_running then
		msg.info("Stopping Benchmark")
		set_value(false)
		benchmark_running = false
		benchmark_started = false
		if not silent then
			display_results()
		end
	elseif benchmark_started then
		benchmark_started = false
		bview:update()
		bview:remove()
		bview.data = nil
	end
	if timerd then
		timerd:kill()
		timerd = nil
	end
	if timeri then
		timeri:kill()
		timeri = nil
	end
end

local function start_benchmark()
	local vframe = mp.get_property_number("container-fps")
	if vframe == nil or (vframe <= 1) then
		msg.warn("Video not detected. Stopping benchmark.")
		return
	end
    if benchmark_running or benchmark_started then
        stop_benchmark()
		bview.data = "{\\r\\b100}Benchmark restarting in 3 seconds{\\b0\\fscx75\\fscy75}\\N\\N"
	else
		bview.data = "{\\r\\b100}Benchmark starting in 3 seconds{\\b0\\fscx75\\fscy75}\\N\\N"
    end	
	bview.data = bview.data .. BULLET .. "\\hDuration:\\h" .. BENCHMARK_DURATION .. "\\hseconds\\N" .. BULLET .. "\\hPoll Rate:\\h" .. POLLING_RATE .. "\\hms\\N\\NPause at any time to stop the benchmark." 
	benchmark_started = true
	fps_array = {}
	store_oval()
	
	bview:update()
	timeri = mp.add_timeout("3", function()
		benchmark_started = false
		benchmark_running = true
		bview:remove()
		msg.info("Starting benchmark for " .. BENCHMARK_DURATION .. " seconds with " .. POLLING_RATE .. "ms polling rate")
		set_value(true)
		if mp.get_property("pause") == "yes" then
			mp.set_property("pause", "no")
		end
		timerd = mp.add_timeout(BENCHMARK_DURATION, stop_benchmark)
		timerp = mp.add_periodic_timer(POLLING_RATE / 1000.0, poll_fps)
	end)
end

mp.add_key_binding(TRIGGER_KEY, "benchmark", start_benchmark)

mp.observe_property("pause", "bool", function(name, value)
	if value and (benchmark_running or benchmark_started) then
		stop_benchmark()
		msg.warn("Benchmark interrupted: User action.")
	end
end)

mp.register_event("end-file", function()
    if benchmark_running or benchmark_started then
		msg.warn("Benchmark interrupted: End of file.")
        stop_benchmark(true)
	end
	bview:remove()
end)