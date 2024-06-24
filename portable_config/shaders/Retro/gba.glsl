// Port of the gba-color shader from hunterk
// The original shader is in the public domain.
//
// Copyright (c) 2022, The mpv-retro-shaders Contributors
//
// Permission to use, copy, modify, and/or distribute this software for any
// purpose with or without fee is hereby granted, provided that the above
// copyright notice and this permission notice appear in all copies.
//
// THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
// WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
// ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
// WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
// ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
// OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

//!HOOK MAIN
//!BIND MAIN
//!DESC Gameboy Advance

// Parameters
#define CONTRAST 1.0
#define SATURATION 1.0
#define BRIGHTNESS 0.94

#ifndef linearize
// Implementation from mpv's gpu-next
vec4 linearize(vec4 color) {
	const float _const_0_1 = 0.05958483740687370300;
	const float _const_1_1 = 0.87031054496765136718;
	color.rgb = max(color.rgb, 0.0);
	color.rgb = _const_1_1 * pow(color.rgb + vec3(_const_0_1), vec3(2.4));
	return color;
}
#endif

#ifndef delinearize
// Implementation from mpv's gpu-next
vec4 delinearize(vec4 color) {
	const float _const_0_2 = 0.05958483740687370300;
	const float _const_1_2 = 1.14901518821716308593;
	color.rgb = max(color.rgb, 0.0);
	color.rgb = pow(_const_1_2 * color.rgb, vec3(1.0/2.4)) - vec3(_const_0_2);
	return color;
}
#endif

vec4 hook() {
	vec4 color = linearize(MAIN_tex(MAIN_pos));

	const vec4 average_lum = vec4(0.5);
	color = mix(color, average_lum, 1.0 - CONTRAST);

	color = clamp(BRIGHTNESS * color, 0.0, 1.0);

	mat4 adjust1 = mat4(
		 0.82, 0.125, 0.195, 0.0,
		 0.24, 0.665, 0.075, 0.0,
		-0.06,  0.21,  0.73, 0.0,
		 0.0,    0.0,   0.0, 0.0
	);

	const float s = SATURATION;
	mat4 adjust2 = mat4(
		(1.0 - s) * 0.3086 + s, (1.0 - s) * 0.3086,     (1.0 - s) * 0.3086,    1.0,
		(1.0 - s) * 0.6094,     (1.0 - s) * 0.6094 + s, (1.0 - s) * 0.6094,    1.0,
		(1.0 - s) * 0.082,      (1.0 - s) * 0.082,      (1.0 - s) * 0.082 + s, 1.0,
		0.0, 0.0, 0.0, 1.0
	);

	color = adjust1 * adjust2 * color;

	return delinearize(color);
}
