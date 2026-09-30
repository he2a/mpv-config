//!HOOK SCALED
//!BIND HOOKED
//!DESC MartysMods FilmGrain

// --- MartysMods FilmGrain Default Settings ---
// 0 = Analog Film Grain, 1 = Digital ISO Noise
#define GRAIN_TYPE 0

// 0 = Monochrome, 1 = Color
#define FILM_MODE 0

// [Parameters for Analog Film Grain]
#define ANALOG_INTENSITY 0.2
#define ANALOG_DISPERSION 0.5
#define ANALOG_CRYSTAL_SIZE 0.3
#define ANALOG_FILM_SHOULDER 0.0
#define ANALOG_FILM_TOE 0.0

// [Parameters for ISO Noise]
#define ISO_INTENSITY 0.25
#define ISO_SATURATION 1.0
// ---------------------------------------------

#define LUMA_COEFF vec3(0.2126, 0.7152, 0.0722)

// Spatial/temporal PRNG
float hash13(vec3 p3) {
    p3  = fract(p3 * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec3 hash33(vec3 p3) {
    p3 = fract(p3 * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yxz + 33.33);
    return fract((p3.xxy + p3.yxx) * p3.zyx);
}

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    vec3 col = color.rgb;
    float luma = dot(col, LUMA_COEFF);

    // Seed generation using mpv's built-in `random` uniform for per-frame animation
    // gl_FragCoord maps noise pixel-perfect to the frame
    vec3 seed = vec3(gl_FragCoord.xy, random);

    if (GRAIN_TYPE == 0) {
        // --- ANALOG FILM GRAIN ---
        // Halide Crystal Size: Scales the coordinate frequency slightly to simulate larger grain clumps
        float scale = 1.0 + (ANALOG_CRYSTAL_SIZE * 3.0);
        vec3 seed_uv = vec3(gl_FragCoord.xy / scale, random);

        vec3 noise;
        if (FILM_MODE == 0) {
            noise = vec3(hash13(seed_uv));
        } else {
            noise = hash33(seed_uv);
        }

        // Shift uniform noise phase to -1.0 to 1.0
        noise = noise * 2.0 - 1.0;

        // Dispersion: Remaps uniform noise to create realistic organic clumping/spikiness
        vec3 noise_mag = abs(noise);
        vec3 sign_noise = sign(noise);
        noise = sign_noise * pow(noise_mag, vec3(1.0 + ANALOG_DISPERSION * 3.0));

        // Film Shoulder & Toe: Basic Filmic S-Curve Tonemap influence
        col = max(vec3(0.0), col + ANALOG_FILM_TOE * (1.0 - col) * 0.15); 
        col = min(vec3(1.0), col + ANALOG_FILM_SHOULDER * col * 0.15);

        // Analog film grain visibly clusters in the midtones while clearing deep shadows/highlights
        float grain_mask = 1.0 - abs(luma - 0.5) * 1.5; 
        grain_mask = clamp(grain_mask, 0.0, 1.0);
        grain_mask = mix(0.5, 1.0, grain_mask); 

        col += noise * ANALOG_INTENSITY * grain_mask * 0.12;

    } else {
        // --- DIGITAL ISO NOISE ---
        vec3 noise;
        if (FILM_MODE == 0) {
            noise = vec3(hash13(seed));
        } else {
            // ISO Noise saturation un-correlates the channels
            vec3 mono_noise = vec3(hash13(seed));
            vec3 color_noise = hash33(seed);
            noise = mix(mono_noise, color_noise, ISO_SATURATION);
        }

        noise = noise * 2.0 - 1.0;

        // Approximate Bayer matrix weighting (emphasize chroma variance if saturation is high)
        vec3 bayer_weight = mix(vec3(1.0), vec3(0.9, 1.0, 1.1), ISO_SATURATION);
        noise *= bayer_weight;

        // Digital noise is generally far more prominent in lifted shadows
        float shadow_mask = clamp(1.0 - luma * 1.2, 0.0, 1.0); 
        shadow_mask = mix(0.3, 1.0, shadow_mask);

        col += noise * ISO_INTENSITY * shadow_mask * 0.08;
    }

    return vec4(clamp(col, 0.0, 1.0), color.a);
}