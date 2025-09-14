//!HOOK MAIN
//!BIND HOOKED
//!DESC Technicolor Effect

vec4 hook() {
    vec4 color = HOOKED_tex(HOOKED_pos);
    
    // Calculate color mattes using RPN operations
    // redmatte = color.r - (color.g + color.b) / 2.0
    float redmatte = color.r - (color.g + color.b) * 0.5;
    
    // greenmatte = color.g - (color.r + color.b) / 2.0  
    float greenmatte = color.g - (color.r + color.b) * 0.5;
    
    // bluematte = color.b - (color.r + color.g) / 2.0
    float bluematte = color.b - (color.r + color.g) * 0.5;
    
    // Invert the mattes
    redmatte = 1.0 - redmatte;
    greenmatte = 1.0 - greenmatte;
    bluematte = 1.0 - bluematte;
    
    // Apply mattes to enhance color channels
    float enhanced_r = greenmatte * bluematte * color.r;
    float enhanced_g = redmatte * bluematte * color.g;
    float enhanced_b = redmatte * greenmatte * color.b;
    
    vec3 enhanced = vec3(enhanced_r, enhanced_g, enhanced_b);
    
    // Blend with original at 50% strength
    vec3 result = color.rgb + 0.5 * (enhanced - color.rgb);
    
    return vec4(result, color.a);
}
