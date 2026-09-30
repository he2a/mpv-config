//!HOOK SCALED
//!BIND HOOKED
//!DESC Kurosawa Mode

// ==========================================
// 1. HIGH CONTRAST B&W SETTINGS
// ==========================================
#define BLACK_LEVEL 0.05    // Deepens the shadows (0.0 to 1.0)
#define WHITE_LEVEL 0.95    // Caps/punches the bright whites (0.0 to 1.0)
#define CONTRAST 1.30       // Contrast curve multiplier (> 1.0 increases contrast)

// ==========================================
// 2. VIGNETTE & RADIAL BLUR SETTINGS
// ==========================================
#define VIG_START 0.55      // Distance from center where vignette begins
#define VIG_END 1.00       // Distance where vignette/blur reaches maximum
#define VIG_DARKEN 0.15     // How dark the edges become (0.0 to 1.0)

#define BLUR_STRENGTH 0.01  // Spread of the radial blur on the edges
#define BLUR_SAMPLES 8     // Quality of the blur (higher = smoother, but heavier on GPU)

// ==========================================
// 3. ANALOGUE FILM GRAIN SETTINGS
// ==========================================
#define GRAIN_INTENSITY 0.45
#define GRAIN_DISPERSION 0.5
#define GRAIN_CRYSTAL_SIZE 0.3

#define LUMA_COEFF vec3(0.2126, 0.7152, 0.0722)

// 1D spatial/temporal PRNG for monochrome grain
float hash13(vec3 p3) {
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec4 hook() {
    // --- VIGNETTE MASK CALCULATION ---
    vec2 uv = HOOKED_pos - 0.5;
    // Correct aspect ratio so the vignette is a perfect circle, not stretched by the screen shape
    uv.x *= (HOOKED_pt.y / HOOKED_pt.x); 
    float dist = length(uv);
    
    // Calculate intensity of vignette at current pixel (0.0 at center, 1.0 at edges)
    float vig_mask = smoothstep(VIG_START, VIG_END, dist);
    
    // --- RADIAL BLUR (Applied only to edges) ---
    vec3 col = vec3(0.0);
    if (vig_mask > 0.0 && BLUR_STRENGTH > 0.0) {
        vec2 dir = vec2(0.5) - HOOKED_pos; // Vector pointing back to center
        float total_weight = 0.0;
        
        for (int i = 0; i < BLUR_SAMPLES; i++) {
            // t goes from 0.0 to 1.0 across the samples
            float t = float(i) / float(BLUR_SAMPLES - 1);
            
            // Outer samples are weighted slightly less for a smoother fade
            float weight = 1.0 - (t * 0.5); 
            
            // Blur distance scales with the vignette mask (sharp center, blurry edges)
            vec2 sample_uv = HOOKED_pos + (dir * t * BLUR_STRENGTH * vig_mask);
            col += HOOKED_tex(sample_uv).rgb * weight;
            total_weight += weight;
        }
        col /= total_weight;
    } else {
        // Skip blur loop for the center of the image to save GPU resources
        col = HOOKED_tex(HOOKED_pos).rgb;
    }
    
    // --- HIGH CONTRAST B&W ---
    // Convert to grayscale
    float luma = dot(col, LUMA_COEFF);
    
    // Apply Levels (Deep Blacks, Punchy Whites)
    luma = clamp((luma - BLACK_LEVEL) / (WHITE_LEVEL - BLACK_LEVEL), 0.0, 1.0);
    
    // Apply Contrast Curve (Pivoted around middle gray)
    luma = (luma - 0.5) * CONTRAST + 0.5;
    luma = clamp(luma, 0.0, 1.0);
    
    // Apply Vignette Darkening
    luma = luma * (1.0 - (vig_mask * VIG_DARKEN));
    
    // --- ANALOGUE FILM GRAIN ---
    // Scale coordinate frequency to simulate larger halide crystals
    float scale = 1.0 + (GRAIN_CRYSTAL_SIZE * 3.0);
    
    // Seed uses mpv's random uniform for native 60fps noise animation
    vec3 seed_uv = vec3(gl_FragCoord.xy / scale, random);
    
    float noise = hash13(seed_uv);
    noise = noise * 2.0 - 1.0;
    
    // Remap noise for realistic organic clumping
    float noise_mag = abs(noise);
    float sign_noise = sign(noise);
    noise = sign_noise * pow(noise_mag, 1.0 + GRAIN_DISPERSION * 3.0);
    
    // Mask grain so it clusters in midtones and clears out of deep blacks/pure whites
    float grain_mask = 1.0 - abs(luma - 0.5) * 1.5; 
    grain_mask = clamp(grain_mask, 0.0, 1.0);
    grain_mask = mix(0.5, 1.0, grain_mask); 
    
    luma += noise * GRAIN_INTENSITY * grain_mask * 0.12;
    
    // Output final monochromatic image
    return vec4(vec3(clamp(luma, 0.0, 1.0)), 1.0);
}