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
	log_title = 'yes',

	-- Graph options
	show_graph = 'yes',                -- show a line chart after the benchmark
	graph_width = 600,                 -- compact graph width  (in 720p-scaled OSD units)
	graph_height = 300,                -- compact graph height (in 720p-scaled OSD units)
	graph_position = 'top-right',      -- compact graph position: top-right, bottom-left, bottom-right
	graph_compact_minimal = 'no',      -- yes = compact graph shows only the line (no axes, grid or labels)
	graph_margin = 20,                 -- distance from the screen edges (compact and expanded)
	graph_label_scale = 50,            -- expanded label size in % of osd-font-size (font itself is inherited)
	graph_line_width = 1.5,            -- FPS line thickness in the compact graph
	graph_expanded_line_width = 2,     -- FPS line thickness in the expanded graph
	graph_border_width = 1,            -- thickness of the box border
	graph_grid = 'yes',                -- draw faint grid lines at major ticks (expanded only)
	graph_avg_width = 1.5,             -- thickness of the dotted average line (expanded only)
	-- Colors use the mpv format #AARRGGBB (or #RRGGBB for opaque), FF = opaque, 00 = transparent
	graph_bg_color = '#99000000',      -- translucent black box
	graph_border_color = '#FFFFFFFF',  -- white border
	graph_line_color = '#FFFFFFFF',    -- white FPS line
	graph_axis_color = '#FFFFFFFF',    -- axes and tick marks
	graph_grid_color = '#33FFFFFF',    -- grid lines
	graph_avg_color = '#FFFFD700',     -- dotted average FPS line
	graph_label_color = ''             -- empty = inherit osd-color
}

opt.read_options(o)

local benchmark_started = false
local benchmark_running = false
local fps_array = {}
local fps_times = {}
local bench_t0 = 0
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

local SHOWGRAPH = txt2bool(o.show_graph)
local GRAPH_W = o.graph_width
local GRAPH_H = o.graph_height
local GRAPH_POS = o.graph_position:lower()
local GRAPH_MARGIN = o.graph_margin
local GRAPH_LABEL_SCALE = o.graph_label_scale
local GRAPH_LINE_W = o.graph_line_width
local GRAPH_XLINE_W = o.graph_expanded_line_width
local GRAPH_BORDER_W = o.graph_border_width
local GRAPH_GRID = txt2bool(o.graph_grid)
local GRAPH_AVG_W = o.graph_avg_width
local GRAPH_MINIMAL = txt2bool(o.graph_compact_minimal)

if GRAPH_POS ~= 'top-right' and GRAPH_POS ~= 'bottom-left' and GRAPH_POS ~= 'bottom-right' then
	msg.warn("Invalid graph_position '" .. GRAPH_POS .. "', using top-right.")
	GRAPH_POS = 'top-right'
end

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

local gview = mp.create_osd_overlay("ass-events")
gview.data = nil
local graph_data = nil
local graph_visible = false
local graph_expanded = false

-- Converts an mpv color (#AARRGGBB or #RRGGBB) to ASS color (&HBBGGRR&) and alpha (&HAA&, inverted)
local function parse_color(str, fallback)
	local s = tostring(str or ''):gsub('^#', '')
	if #s == 6 then
		s = 'FF' .. s
	end
	if not s:match('^%x%x%x%x%x%x%x%x$') then
		if fallback then
			msg.warn("Invalid color '" .. tostring(str) .. "', using default " .. fallback)
			return parse_color(fallback)
		end
		return nil
	end
	local a = tonumber(s:sub(1, 2), 16)
	local r, g, b = s:sub(3, 4), s:sub(5, 6), s:sub(7, 8)
	return {
		c = string.format('&H%s%s%s&', b, g, r),
		a = string.format('&H%02X&', 255 - a)
	}
end

local COL_BG = parse_color(o.graph_bg_color, '#99000000')
local COL_BORDER = parse_color(o.graph_border_color, '#FFFFFFFF')
local COL_LINE = parse_color(o.graph_line_color, '#FFFFFFFF')
local COL_AXIS = parse_color(o.graph_axis_color, '#FFFFFFFF')
local COL_GRID = parse_color(o.graph_grid_color, '#33FFFFFF')
local COL_AVG = parse_color(o.graph_avg_color, '#FFFFD700')
local COL_LABEL = nil
if o.graph_label_color ~= '' then
	COL_LABEL = parse_color(o.graph_label_color, nil)
	if not COL_LABEL then
		msg.warn("Invalid graph_label_color, inheriting osd-color instead.")
	end
end

local function ass_escape(str)
	return (tostring(str):gsub('\\', '\\\\'):gsub('{', '\\{'):gsub('}', '\\}'))
end

local function writelog(out)
	local filename = mp.get_property("filename")
	local title = LOGNAM
	
	if LOGTIT then
		title = title .. "." .. filename .. ".log"
	else
		title = title .. ".log"
	end
	
	title = title:gsub('[\\/:*?"<>|]', '_')
	title = title:gsub('^[%.%s]+', ''):gsub('[%.%s]+$', '')
	
	local logtime = os.date("%y-%m-%d %H:%M:%S")
	local path = mp.command_native({"expand-path", "~~desktop/" .. title})
	local ltxt = "Benchmark - " .. logtime .. "\n\nFilename: " .. filename .. "\n\n" .. out
	local divider = "-----------------------------"
	local file = io.open(path, "a")
	if not file then
		msg.error("Unable to write log file: " .. path)
		return
	end
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

---------------------------------------------------------------------------
-- Graph rendering
---------------------------------------------------------------------------

-- Picks a "nice" step (1, 2, 5 x 10^n) giving roughly `target` divisions
local function nice_step(range, target)
	local raw = range / target
	local mag = 10 ^ math.floor(math.log(raw) / math.log(10))
	local norm = raw / mag
	local n
	if norm <= 1 then n = 1
	elseif norm <= 2 then n = 2
	elseif norm <= 5 then n = 5
	else n = 10 end
	return n * mag
end

-- Returns the major tick step and the top of the scale. The top is the highest
-- value rounded up to a multiple of the step, so the peak always sits on or just
-- below the highest major tick.
local function compute_scale(vmax, target)
	if vmax <= 0 then vmax = 1 end
	local step = nice_step(vmax, target)
	local top = math.ceil(vmax / step - 1e-9) * step
	if top <= 0 then top = step end
	return step, top
end

local function fmt_num(v, step)
	if step >= 1 then
		return string.format("%d", math.floor(v + 0.5))
	end
	return string.format("%.1f", v)
end

local function rect(x0, y0, x1, y1)
	return string.format("m %.2f %.2f l %.2f %.2f l %.2f %.2f l %.2f %.2f ",
		x0, y0, x1, y0, x1, y1, x0, y1)
end

local function border_path(bx, by, W, H, b)
	return rect(bx, by, bx + W, by + b) ..
		rect(bx, by + H - b, bx + W, by + H) ..
		rect(bx, by + b, bx + b, by + H - b) ..
		rect(bx + W - b, by + b, bx + W, by + H - b)
end

local function fill_event(col, path)
	return "{\\an7\\pos(0,0)\\bord0\\shad0\\blur0\\1c" .. col.c .. "\\1a" .. col.a .. "\\p1}" .. path .. "{\\p0}"
end

-- FPS line: path drawn forward and back so it has zero area, then stroked with \bord
local function line_event(X, Y, width, col)
	local pts = {}
	for i, v in ipairs(graph_data.v) do
		local t = math.min(math.max(graph_data.t[i], 0), BENCHMARK_DURATION)
		pts[#pts + 1] = string.format("%.2f %.2f", X(t), Y(v))
	end
	local path = {"m " .. pts[1]}
	for i = 2, #pts do
		path[#path + 1] = "l " .. pts[i]
	end
	for i = #pts - 1, 1, -1 do
		path[#path + 1] = "l " .. pts[i]
	end
	return string.format("{\\an7\\pos(0,0)\\bord%.2f\\shad0\\blur0\\1a&HFF&\\3c%s\\3a%s\\p1}%s{\\p0}",
		width / 2, col.c, col.a, table.concat(path, " "))
end

local function label_event(an, x, y, text)
	local tags = string.format("{\\an%d\\pos(%.2f,%.2f)\\fscx%d\\fscy%d", an, x, y, GRAPH_LABEL_SCALE, GRAPH_LABEL_SCALE)
	if COL_LABEL then
		tags = tags .. "\\1c" .. COL_LABEL.c .. "\\1a" .. COL_LABEL.a
	end
	return tags .. "}" .. text
end

local function get_canvas()
	-- Fixed 720-high canvas so the graph scales like the rest of the OSD
	local osd_w, osd_h = mp.get_osd_size()
	local cw, ch = 1280, 720
	if osd_w and osd_h and osd_w > 0 and osd_h > 0 then
		cw = math.floor(720 * osd_w / osd_h + 0.5)
	end
	return cw, ch
end

local function hide_graph()
	gview:remove()
	gview.data = nil
	graph_visible = false
	graph_expanded = false
end

local build_detailed -- defined below

-- Compact graph: minimal (box, border and FPS line only) or detailed with axes
local function build_compact(cw, ch)
	local W, H = GRAPH_W, GRAPH_H
	local m = GRAPH_MARGIN
	local bx, by
	if GRAPH_POS == 'top-right' then
		bx, by = cw - W - m, m
	elseif GRAPH_POS == 'bottom-left' then
		bx, by = m, ch - H - m
	else
		bx, by = cw - W - m, ch - H - m
	end

	if not GRAPH_MINIMAL then
		return build_detailed(bx, by, W, H, false)
	end

	local inset = GRAPH_BORDER_W + 6
	local px0, py0 = bx + inset, by + inset
	local px1, py1 = bx + W - inset, by + H - inset
	if px1 - px0 < 10 or py1 - py0 < 10 then
		msg.warn("Graph size too small to render. Increase graph_width/graph_height.")
		return nil
	end

	local _, ymax = compute_scale(graph_data.vmax, 5)
	local function X(t) return px0 + (t / BENCHMARK_DURATION) * (px1 - px0) end
	local function Y(v) return py1 - (v / ymax) * (py1 - py0) end

	local events = {}
	table.insert(events, fill_event(COL_BG, rect(bx, by, bx + W, by + H)))
	table.insert(events, line_event(X, Y, GRAPH_LINE_W, COL_LINE))
	if GRAPH_BORDER_W > 0 then
		table.insert(events, fill_event(COL_BORDER, border_path(bx, by, W, H, GRAPH_BORDER_W)))
	end
	return events
end

-- Detailed graph with axes, ticks, labels and grid.
-- full = true (expanded view) also adds the dotted average line and the stats row.
build_detailed = function(bx, by, W, H, full)
	local fs = mp.get_property_number("osd-font-size", 55) * GRAPH_LABEL_SCALE / 100
	local char_w = fs * 0.6
	local tick_major, tick_minor = 8, 4
	local pad = 12 + GRAPH_BORDER_W
	if not full then
		tick_major, tick_minor = 6, 3
		pad = 8 + GRAPH_BORDER_W
	end
	local xmax = BENCHMARK_DURATION

	-- Vertical layout: top pad | plot | ticks + x labels | (gap | stats row) | bottom pad
	local top = pad + fs * 0.5
	local bottom = pad + fs + tick_major + 4
	if full then
		bottom = bottom + fs * 0.8 + fs
	end
	local plot_h = H - top - bottom

	local ystep, ymax = compute_scale(graph_data.vmax, math.max(2, math.floor(plot_h / (fs * 1.8))))
	local yticks = {}
	local maxlen = 1
	for i = 0, math.floor(ymax / ystep + 0.5) do
		local v = i * ystep
		local s = fmt_num(v, ystep)
		table.insert(yticks, {v = v, s = s})
		if #s > maxlen then maxlen = #s end
	end

	local left = pad + maxlen * char_w + tick_major + 4
	local right = pad + char_w * #string.format("%d", math.floor(xmax)) * 0.5
	local plot_w = W - left - right

	if plot_w < 20 or plot_h < 20 then
		msg.warn("Graph area too small to render with axes. Increase its size or enlarge the window.")
		return nil
	end

	local px0, py0 = bx + left, by + top
	local px1, py1 = px0 + plot_w, py0 + plot_h

	local function X(t) return px0 + (t / xmax) * plot_w end
	local function Y(v) return py1 - (v / ymax) * plot_h end

	local events = {}
	local axis_path, grid_path, avg_path = {}, {}, {}
	local labels = {}

	table.insert(events, fill_event(COL_BG, rect(bx, by, bx + W, by + H)))

	-- Y axis ticks, labels, grid (highest tick is the top of the scale)
	for _, tk in ipairs(yticks) do
		local y = Y(tk.v)
		table.insert(axis_path, rect(px0 - tick_major, y - 0.5, px0, y + 0.5))
		table.insert(labels, label_event(6, px0 - tick_major - 3, y, tk.s))
		if GRAPH_GRID and tk.v > 0 then
			table.insert(grid_path, rect(px0, y - 0.5, px1, y + 0.5))
		end
	end

	-- X axis ticks (major each second, minor each half second), labels, grid
	local px_per_s = plot_w / xmax
	local label_every = math.max(1, math.ceil(char_w * (#string.format("%d", math.floor(xmax)) + 1) / px_per_s))
	for k = 0, math.floor(xmax * 2 + 1e-9) do
		local t = k / 2
		local x = X(t)
		if k % 2 == 0 then
			table.insert(axis_path, rect(x - 0.5, py1, x + 0.5, py1 + tick_major))
			if t % label_every == 0 then
				table.insert(labels, label_event(8, x, py1 + tick_major + 2, string.format("%d", t)))
			end
			if GRAPH_GRID and t > 0 then
				table.insert(grid_path, rect(x - 0.5, py0, x + 0.5, py1))
			end
		else
			table.insert(axis_path, rect(x - 0.5, py1, x + 0.5, py1 + tick_minor))
		end
	end

	-- Axis lines
	table.insert(axis_path, rect(px0 - 0.5, py0, px0 + 0.5, py1 + 0.5))
	table.insert(axis_path, rect(px0 - 0.5, py1 - 0.5, px1, py1 + 0.5))

	if GRAPH_GRID and #grid_path > 0 then
		table.insert(events, fill_event(COL_GRID, table.concat(grid_path)))
	end

	table.insert(events, line_event(X, Y, full and GRAPH_XLINE_W or GRAPH_LINE_W, COL_LINE))

	-- Dotted average line (expanded only)
	if full then
		local ya = Y(graph_data.avg)
		local dot, gap = 3, 4
		local hw = GRAPH_AVG_W / 2
		local x = px0
		while x < px1 do
			table.insert(avg_path, rect(x, ya - hw, math.min(x + dot, px1), ya + hw))
			x = x + dot + gap
		end
		table.insert(events, fill_event(COL_AVG, table.concat(avg_path)))
	end

	table.insert(events, fill_event(COL_AXIS, table.concat(axis_path)))

	if GRAPH_BORDER_W > 0 then
		table.insert(events, fill_event(COL_BORDER, border_path(bx, by, W, H, GRAPH_BORDER_W)))
	end

	-- Stats row under the x axis (expanded only)
	if full then
		local sy = by + H - pad - fs * 0.5
		table.insert(labels, label_event(4, px0, sy, "Average:\\h" .. graph_data.avg_r .. "\\hFPS"))
		table.insert(labels, label_event(5, (px0 + px1) / 2, sy, "Median:\\h" .. graph_data.median .. "\\hFPS"))
		table.insert(labels, label_event(6, px1, sy, "1%\\hLow:\\h" .. graph_data.low .. "\\hFPS"))
	end

	for _, l in ipairs(labels) do
		table.insert(events, l)
	end
	return events
end

-- Expanded graph: full screen minus margins
local function build_expanded(cw, ch)
	local m = GRAPH_MARGIN
	return build_detailed(m, m, cw - 2 * m, ch - 2 * m, true)
end

local function render_graph()
	if not graph_data or #graph_data.v < 2 then return end
	local cw, ch = get_canvas()
	gview.res_x = cw
	gview.res_y = ch

	local events
	if graph_expanded then
		events = build_expanded(cw, ch)
	else
		events = build_compact(cw, ch)
	end
	if not events then return end

	gview.data = table.concat(events, "\n")
	gview:update()
	graph_visible = true
end

local function expand_graph()
	if timero then
		timero:kill()
		timero = nil
	end
	bview:remove()
	bview.data = nil
	graph_expanded = true
	render_graph()
end

local function close_graph()
	hide_graph()
	graph_data = nil
end

---------------------------------------------------------------------------

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
        table.insert(fps_times, mp.get_time() - bench_t0)
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
		
		local avg_raw = calculate_average(sorted_fps)
		local avg_fps = round(avg_raw)
		local median_fps = round(calculate_median(sorted_fps))
		local low_fps = round(calculate_percentile(sorted_fps))
		local strout = "Average: " .. avg_fps .. " FPS\nMedian: " .. median_fps .. " FPS\n1% Low: " .. low_fps .. " FPS\n\nSamples: " .. #fps_samples .. "\nLost: " .. (BENCHMARK_DURATION * 1000 / POLLING_RATE) - #fps_samples
		bview.data = "{\\r\\b100}Benchmark Result{\\b0\\fscx75\\fscy75}\\N\\N" .. BULLET .. "\\hAverage:\\h" .. avg_fps .. "\\hFPS\\N" .. BULLET .. "\\hMedian:\\h" .. median_fps .. "\\hFPS\\N" .. BULLET .. "\\h1% Low:\\h" .. low_fps .. "\\hFPS\\N\\NSamples: " .. #fps_samples .. "\\NLost: " .. (BENCHMARK_DURATION * 1000 / POLLING_RATE) - #fps_samples
		
		if LOGOUT then
			writelog(strout)
		else
			msg.info("Benchmark completed.\n" .. strout)
		end

		if SHOWGRAPH and #fps_samples >= 2 then
			graph_data = {
				t = fps_times,
				v = fps_samples,
				vmax = sorted_fps[#sorted_fps],
				avg = avg_raw,
				avg_r = avg_fps,
				median = median_fps,
				low = low_fps
			}
			graph_expanded = false
			render_graph()
			if graph_visible then
				bview.data = bview.data .. "\\N\\NPress\\h" .. ass_escape(TRIGGER_KEY) .. "\\hto\\hexpand\\hgraph"
			end
		end
	end
	bview:update()		
	timero = mp.add_timeout(FLASHT, function()
		bview:remove()
		bview.data = nil
		if not graph_expanded then
			close_graph()
		end
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
	-- Clear any previous result/graph still on screen
	if timero then
		timero:kill()
		timero = nil
	end
	close_graph()
    if benchmark_running or benchmark_started then
        stop_benchmark()
		bview.data = "{\\r\\b100}Benchmark restarting in 3 seconds{\\b0\\fscx75\\fscy75}\\N\\N"
	else
		bview.data = "{\\r\\b100}Benchmark starting in 3 seconds{\\b0\\fscx75\\fscy75}\\N\\N"
    end	
	bview.data = bview.data .. BULLET .. "\\hDuration:\\h" .. BENCHMARK_DURATION .. "\\hseconds\\N" .. BULLET .. "\\hPoll Rate:\\h" .. POLLING_RATE .. "\\hms\\N\\NPause at any time to stop the benchmark." 
	benchmark_started = true
	fps_array = {}
	fps_times = {}
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
		bench_t0 = mp.get_time()
		timerp = mp.add_periodic_timer(POLLING_RATE / 1000.0, poll_fps)
	end)
end

-- Key handler:
--   results + compact graph on screen -> expand the graph
--   expanded graph on screen          -> close it
--   otherwise                         -> start (or restart) the benchmark
local function on_key()
	if graph_expanded then
		close_graph()
		return
	end
	if timero and graph_visible and not benchmark_running and not benchmark_started then
		expand_graph()
		return
	end
	start_benchmark()
end

mp.add_key_binding(TRIGGER_KEY, "benchmark", on_key)

mp.observe_property("pause", "bool", function(name, value)
	if value and (benchmark_running or benchmark_started) then
		stop_benchmark()
		msg.warn("Benchmark interrupted: User action.")
	end
end)

-- Redraw the graph live when the window is resized
mp.observe_property("osd-dimensions", "native", function()
	if graph_visible then
		render_graph()
	end
end)

mp.register_event("end-file", function()
    if benchmark_running or benchmark_started then
		msg.warn("Benchmark interrupted: End of file.")
        stop_benchmark(true)
	end
	bview:remove()
	close_graph()
end)
