local mp = require 'mp'
local utils = require 'mp.utils'
local msg = require 'mp.msg'
local opt = require 'mp.options'

local o = {
	vendor = 'nvidia',
	auto_scale = 'no',
	scale_max_factor = 2,
	scale_limit_to_native = 'no',
	scale_max_size = 1.125,
	over_scale = 'yes',
	auto_hdr = 'no',
	hdr_peak = 1000
}

opt.read_options(o)

local mpvs = { dwidth = 1, dheight = 1, vwidth = 1, vheight = 1, inv = false, hdrpass = false, prim = '', tpeak = 0, ipeak = 0, speak = 0, dither = '', gapi = '', hwdec = '' }
local firstrun = true
local scaler_active = false
local hdr_active = false
local filter_s = ''
local filter_h = ''
local gls = ''

local function txt2bool(txt)
	if (txt == 'yes') or (txt == 'true') then
		return true
	else
		return false
	end
end

local function qdceil(num)
	local low = math.floor(num)
	local high = math.ceil(num)
	if low == high then
		return num
	end
	local qd2 = (high + low)/2
	local qd1 = (qd2 + low)/2
	local qd3 = (high + qd2)/2

	if num <= qd1 then
		return qd1
	elseif num <= qd2 then
		return qd2
	elseif num <= qd3 then
		return qd3
	else
		return high
	end
end

local scale_auto = txt2bool(o.auto_scale)
local scale_factor = o.scale_max_factor
local vendor = o.vendor
local scale_limit = o.scale_max_size
local scale_native = txt2bool(o.scale_limit_to_native)
local scale_over = txt2bool(o.over_scale)
if scale_native then
	scale_limit = 1
end

local hdr_auto = txt2bool(o.auto_hdr)
local peak = o.hdr_peak

local function getproperty(fl)
	if fl then
		mpvs.dwidth = 1
		mpvs.dheight = 1
		mpvs.vwidth = 1
		mpvs.vheight = 1
		mpvs.inv = false
		mpvs.hdrpass = false
		mpvs.prim = ''
		mpvs.tpeak = 0
		mpvs.ipeak = 0
		mpvs.speak = 0
		mpvs.dither = ''
		mpvs.gapi = ''
		mpvs.hwdec = ''
	else
		mpvs.dwidth = mp.get_property_native("display-width")
		mpvs.dheight = mp.get_property_native("display-height")
		mpvs.vwidth = mp.get_property_native("width")
		mpvs.vheight = mp.get_property_native("height")
		mpvs.inv = mp.get_property_native("inverse-tone-mapping")
		mpvs.hdrpass = mp.get_property_native("target-colorspace-hint")
		mpvs.prim = mp.get_property_native("video-params/primaries")
		mpvs.tpeak = mp.get_property_native("target-peak")
		mpvs.ipeak = mp.get_property_native("image-subs-hdr-peak")
		mpvs.speak = mp.get_property_native("sub-hdr-peak")
		mpvs.dither = mp.get_property_native("dither")
		mpvs.gapi = mp.get_property_native("gpu-api")
		mpvs.hwdec = mp.get_property_native("hwdec")
	end
end

local function scaler()
	local dw = mpvs.dwidth
	local dh = mpvs.dheight
	local vw = mpvs.vwidth
	local vh = mpvs.vheight
	
	if not (dw and dh and vw and vh) then
        return 1
    end
	local factor_diff
	if vw >= vh then
		factor_diff = math.max((dw*scale_limit)/vw,1)
	else
		factor_diff = math.max((dh*scale_limit)/vh,1)
	end
	-- local factor_diff = math.max((dw*scale_limit)/vw,(dh*scale_limit)/vh,1)
	local factor
	
	if factor_diff == 1 then
		factor =  1
	elseif factor_diff < scale_factor then
		if scale_native or not over_scale then
			factor = factor_diff
		else
			factor = qdceil(factor_diff)
		end
	else
		factor = scale_factor
	end
	return factor
end

local function toggle_scaler()
	if vendor ~= 'nvidia' then
		mp.msg.info("GPU not supported.")
		return
	end
	if not scaler_active then
		if not hdr_active then
			gls = mp.get_property_native("glsl-shaders")
			getproperty(false)
		end
		local sf = scaler()
		
		if sf <= 1 then
			mp.msg.info("No scaling required.")
			return
		end
		
		filter_s = 'scale=' .. sf .. ':scaling-mode=' .. vendor
		
		if hdr_active then
			mp.command('no-osd vf remove @gpufun')
			mp.command('no-osd vf remove @hdrhelper')
			mp.command('no-osd vf add @gpufun:d3d11vpp=' .. filter_s .. ':' .. filter_h)
		else
			mp.command('no-osd change-list glsl-shaders clr all')
			if mpvs.gapi ~= 'auto' then
				mp.set_property_native("gpu-api", 'auto')
			end
			if mpvs.hwdec ~= 'd3d11va' then
				mp.set_property_native("hwdec", 'd3d11va')
			end
			mp.command('no-osd vf add @gpufun:d3d11vpp=' .. filter_s)
		end
		
		scaler_active = true
	else
		mp.command('no-osd vf remove @gpufun')
		if hdr_active then
			mp.command('no-osd vf remove @hdrhelper')
			mp.command('no-osd vf add @gpufun:d3d11vpp=' .. filter_h)
		else
			mp.set_property_native("gpu-api", mpvs.gapi)
			mp.set_property_native("hwdec", mpvs.hwdec)
			
			if mp.get_property("glsl-shaders") == '' then
				mp.set_property_native("glsl-shaders", gls)
			end
		end
		filter_s = ''
		scaler_active = false
	end
end

local function toggle_hdr()
	if vendor ~= 'nvidia' then
		mp.msg.info("GPU not supported.")
		return
	end
	if not hdr_active then
		if not scaler_active then
			gls = mp.get_property_native("glsl-shaders")
			getproperty(false)
		end
		if mpvs.prim == 'bt.2020' then
			mp.msg.info("HDR content detected. Filter not applied")
			return
		end
		if not mpvs.hdrpass then
			mp.set_property_native("target-colorspace-hint",true)
		end
		
		if mpvs.inv then
			mp.set_property_native("inverse-tone-mapping",false)
		end
		
		mp.set_property_native("dither",'error-diffusion')
		mp.set_property_native("target-peak",peak)
		mp.set_property_native("image-subs-hdr-peak",peak)
		mp.set_property_native("sub-hdr-peak",peak)
		
		filter_h = 'format=x2bgr10:nvidia-true-hdr,@hdrhelper:format=x2bgr10:transfer=pq:primaries=bt.2020:max-luma=' .. peak
		
		if scaler_active then
			mp.command('no-osd vf remove @gpufun')
			mp.command('no-osd vf add @gpufun:d3d11vpp=' .. filter_s .. ':' .. filter_h)
		else
			mp.command('no-osd change-list glsl-shaders clr all')
			if mpvs.gapi ~= 'auto' then
				mp.set_property_native("gpu-api", 'auto')
			end
			if mpvs.hwdec ~= 'd3d11va' then
				mp.set_property_native("hwdec", 'd3d11va')
			end
			mp.command('no-osd vf add @gpufun:d3d11vpp=' .. filter_h)
		end
		hdr_active = true
	else
		mp.command('no-osd vf remove @gpufun')
		mp.command('no-osd vf remove @hdrhelper')
		mp.set_property_native("target-colorspace-hint",mpvs.hdrpass)
		mp.set_property_native("inverse-tone-mapping",mpvs.inv)
		mp.set_property_native("dither",mpvs.dither)
		mp.set_property_native("target-peak",mpvs.tpeak)
		mp.set_property_native("image-subs-hdr-peak",mpvs.ipeak)
		mp.set_property_native("sub-hdr-peak",mpvs.speak)
		
		if scaler_active then
			mp.command('no-osd vf add @gpufun:d3d11vpp=' .. filter_s)
		else
			mp.set_property_native("gpu-api", mpvs.gapi)
			mp.set_property_native("hwdec", mpvs.hwdec)
			
			if mp.get_property("glsl-shaders") == '' then
				mp.set_property_native("glsl-shaders", gls)
			end
		end
		filter_h = ''
		hdr_active = false
	end
end

local function toggle_clear()
	if hdr_active then toggle_hdr() end
	if scaler_active then toggle_scaler() end
end

local function init()
	if firstrun then
		firstrun = false
		getproperty(true)
		if scale_auto then
			mp.add_timeout(0.5, toggle_scaler)
		end
		if hdr_auto then
			mp.add_timeout(0.5, toggle_hdr)
		end
	else
		toggle_clear()
		getproperty(true)
		
		if scale_auto then
			mp.add_timeout(0.5, toggle_scaler)
		end
		
		if hdr_auto then
			mp.add_timeout(0.5, toggle_hdr)
		end
	end
end

mp.register_event("file-loaded", init)
mp.add_key_binding('F1', "gpu-scale", toggle_scaler)
mp.add_key_binding('F2', "gpu-hdr", toggle_hdr)
mp.add_key_binding('F3', "gpu-clear", toggle_clear)