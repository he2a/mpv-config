//!HOOK OUTPUT
//!BIND HOOKED
//!DESC 8x8 Ordered Dithering

// =========================================================================
// USER CONFIGURATION
// =========================================================================

#define DITHER_MODE 1

// --- MODE 0 SETTINGS: LUMA STYLIZATION -----------------------------------

#define LUMA_COMPRESSION_MULT 0.8
#define LUMA_COMPRESSION_OFFSET 0.1
#define LUMA_DARK_MULT 0.4
#define LUMA_LIGHT_MULT 1.1

// --- MODE 1 SETTINGS: RGB QUANTIZATION -----------------------------------

#define RGB_COLOR_BITS 3.0
#define RGB_DITHER_SPREAD 1.0

// Pre-quantization adjustments to combat the flattening effect of low bit-depths.
// 1.0 is neutral. >1.0 increases punch and vibrancy.
#define RGB_CONTRAST 1.2
#define RGB_SATURATION 1.0

// =========================================================================

const float dither_matrix[64] = float[64](
    0.015625, 0.515625, 0.140625, 0.640625, 0.046875, 0.546875, 0.171875, 0.671875,
    0.765625, 0.265625, 0.890625, 0.390625, 0.796875, 0.296875, 0.921875, 0.421875,
    0.203125, 0.703125, 0.078125, 0.578125, 0.234375, 0.734375, 0.109375, 0.609375,
    0.953125, 0.453125, 0.828125, 0.328125, 0.984375, 0.484375, 0.859375, 0.359375,
    0.0625,   0.5625,   0.1875,   0.6875,   0.03125,  0.53125,  0.15625,  0.65625,
    0.8125,   0.3125,   0.9375,   0.4375,   0.78125,  0.28125,  0.90625,  0.40625,
    0.25,     0.75,     0.125,    0.625,    0.21875,  0.71875,  0.09375,  0.59375,
    1.0,      0.5,      0.875,    0.375,    0.96875,  0.46875,  0.84375,  0.34375
);

float getDither(vec2 position) {
    int x = int(mod(position.x, 8.0));
    int y = int(mod(position.y, 8.0));
    return dither_matrix[x + y * 8];
}

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    float dither_val = getDither(gl_FragCoord.xy);
    
#if DITHER_MODE == 0
    
    float brightness = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    float adjusted_brightness = brightness * LUMA_COMPRESSION_MULT + LUMA_COMPRESSION_OFFSET;
    float dither_mask = step(dither_val, adjusted_brightness);
    
    color.rgb *= mix(LUMA_DARK_MULT, LUMA_LIGHT_MULT, dither_mask);

#elif DITHER_MODE == 1
    
    // 1. Apply pre-quantization Contrast
    color.rgb = (color.rgb - 0.5) * RGB_CONTRAST + 0.5;
    
    // 2. Apply pre-quantization Saturation
    float luma = dot(color.rgb, vec3(0.2126, 0.7152, 0.0722));
    color.rgb = mix(vec3(luma), color.rgb, RGB_SATURATION);
    
    // Clamp before quantization to prevent inverted colors from pushed contrast
    color.rgb = clamp(color.rgb, 0.0, 1.0);
    
    // 3. Center the dither value (-0.5 to +0.5) to preserve absolute black/white floors
    float centered_dither = dither_val - 0.5;
    
    float steps = exp2(RGB_COLOR_BITS) - 1.0;
    
    // Apply centered dither with standard +0.5 rounding to snap to exact bands
    color.rgb = floor(color.rgb * steps + 0.5 + (centered_dither * RGB_DITHER_SPREAD)) / steps;
    
    color.rgb = clamp(color.rgb, 0.0, 1.0);

#endif

    return color;
}