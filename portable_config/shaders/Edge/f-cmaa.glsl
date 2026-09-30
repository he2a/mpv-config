//!HOOK LUMA
//!BIND HOOKED
//!DESC Fast CMAA2-style Antialiasing for mpv

float get_luma(vec2 pos) {
    return HOOKED_tex(pos).x;
}

float edge_detect(vec2 pos, vec2 offset) {
    float center = get_luma(pos);
    float neighbor = get_luma(pos + offset * HOOKED_pt);
    return abs(center - neighbor);
}

vec4 hook() {
    vec2 pos = HOOKED_pos;
    float edge_threshold = 0.1;
    
    // Sample current pixel
    float center_luma = get_luma(pos);
    
    // Calculate edge detection in 4 directions
    float edge_left = edge_detect(pos, vec2(-1, 0));
    float edge_right = edge_detect(pos, vec2(1, 0));
    float edge_up = edge_detect(pos, vec2(0, -1));
    float edge_down = edge_detect(pos, vec2(0, 1));
    
    // Determine if this is an edge pixel
    bool is_edge = (edge_left > edge_threshold) || 
                   (edge_right > edge_threshold) || 
                   (edge_up > edge_threshold) || 
                   (edge_down > edge_threshold);
    
    if (is_edge) {
        // Perform antialiasing by blending with neighbors
        float total_weight = 1.0;
        float blended_luma = center_luma;
        float blend_multiplier = 0.75;
        float blend_strength = 0.25 * blend_multiplier;
        
        if (edge_left > edge_threshold) {
            blended_luma += get_luma(pos + vec2(-1, 0) * HOOKED_pt) * blend_strength;
            total_weight += blend_strength;
        }
        if (edge_right > edge_threshold) {
            blended_luma += get_luma(pos + vec2(1, 0) * HOOKED_pt) * blend_strength;
            total_weight += blend_strength;
        }
        if (edge_up > edge_threshold) {
            blended_luma += get_luma(pos + vec2(0, -1) * HOOKED_pt) * blend_strength;
            total_weight += blend_strength;
        }
        if (edge_down > edge_threshold) {
            blended_luma += get_luma(pos + vec2(0, 1) * HOOKED_pt) * blend_strength;
            total_weight += blend_strength;
        }
        
        return vec4(blended_luma / total_weight, 0, 0, 1);
    }
    
    return vec4(center_luma, 0, 0, 1);
}
