//!HOOK SCALED
//!BIND HOOKED
//!DESC Kurosawa Mode

#define BLACK_LEVEL 0.10     // Deepens the shadows (0.0 to 1.0)
#define WHITE_LEVEL 0.90    // Caps/punches the bright whites (0.0 to 1.0)
#define CONTRAST 0.90      // Contrast curve multiplier (> 1.0 increases contrast)

#define VIG_START 0.55      // Distance from center where vignette begins
#define VIG_END 1.00       // Distance where vignette/blur reaches maximum
#define VIG_DARKEN 0.15   // How dark the edges become (0.0 to 1.0)

#define BLUR_STRENGTH 0.01  // Spread of the radial blur on the edges
#define BLUR_SAMPLES 15    // Quality of the blur (higher = smoother, but heavier on GPU)

#define SMEAR_STRENGTH 0.35  // Intensity of the horizontal time-based smear

#define GRAIN_INTENSITY 0.3
#define GRAIN_DISPERSION 0.5
#define GRAIN_CRYSTAL_SIZE 0.4

// ==========================================
#define LUMA_COEFF vec3(0.2126, 0.7152, 0.0722)
#define iTime (frame / 60.0)

float hash13(vec3 p3) {
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec4 hook() {
    // --- RESOLUTION SCALING ---
    float resFactor = min(HOOKED_size.y / 1080.0, 1.0);

    // --- VIGNETTE MASK ---
    vec2 uv_vig = HOOKED_pos - 0.5;
    uv_vig.x *= (HOOKED_pt.y / HOOKED_pt.x); 
    float dist = length(uv_vig);
    float vig_mask = smoothstep(VIG_START, VIG_END, dist);
    
    // --- SMEAR CALCULATION (Adapted for Grayscale) ---
    // Calculate the time-pulsing base strength of the VHS smear
    float d = 0.1 - ceil(mod(iTime / 3.0, 1.0) + 0.5) * 0.1;
    float smear_base = max(0.0001, 0.002 * d) * SMEAR_STRENGTH;
    
    // Map the original VHS spread algorithm into a single multiplier
    float smear_scale = 35.0 * smear_base * (1.0 + HOOKED_pos.x) * resFactor;
    
    // --- UNIFIED BLUR LOOP (Radial + Smear) ---
    vec3 col = vec3(0.0);
    vec2 dir = vec2(0.5) - HOOKED_pos;
    float total_weight = 0.0;
    
    for (int i = 0; i < BLUR_SAMPLES; i++) {
        // t goes from 0.0 to 1.0 across the samples
        float t = float(i) / float(BLUR_SAMPLES - 1);
        float weight = 1.0 - (t * 0.5); 
        
        // 1. Horizontal VHS smear (applied globally, pulsing with time)
        vec2 smear_offset = vec2(-t * smear_scale, 0.0);
        
        // 2. Radial blur (applied dynamically only on vignette edges)
        vec2 rad_offset = dir * t * BLUR_STRENGTH * vig_mask;
        
        // Combine both vector offsets into a single texture read
        vec2 sample_uv = HOOKED_pos + smear_offset + rad_offset;
        
        col += HOOKED_tex(sample_uv).rgb * weight;
        total_weight += weight;
    }
    col /= total_weight;
    
    // --- HIGH CONTRAST B&W ---
    float luma = dot(col, LUMA_COEFF);
    luma = clamp((luma - BLACK_LEVEL) / (WHITE_LEVEL - BLACK_LEVEL), 0.0, 1.0);
    luma = (luma - 0.5) * CONTRAST + 0.5;
    luma = clamp(luma, 0.0, 1.0);
    luma = luma * (1.0 - (vig_mask * VIG_DARKEN));
    
    // --- ANALOGUE FILM GRAIN ---
    float scale = 1.0 + (GRAIN_CRYSTAL_SIZE * 3.0);
    vec3 seed_uv = vec3(gl_FragCoord.xy / scale, random);
    
    float noise = hash13(seed_uv);
    noise = noise * 2.0 - 1.0;
    
    float noise_mag = abs(noise);
    float sign_noise = sign(noise);
    noise = sign_noise * pow(noise_mag, 1.0 + GRAIN_DISPERSION * 3.0);
    
    float grain_mask = 1.0 - abs(luma - 0.5) * 1.5; 
    grain_mask = clamp(grain_mask, 0.0, 1.0);
    grain_mask = mix(0.5, 1.0, grain_mask); 
    
    luma += noise * GRAIN_INTENSITY * grain_mask * 0.12;
    
    return vec4(vec3(clamp(luma, 0.0, 1.0)), 1.0);
}