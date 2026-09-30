// Faster FXAA shader based on the FXAA implementation by Timothy Lottes

//!HOOK SCALED
//!BIND HOOKED
//!DESC Applying FXAA

// FXAA settings
#define FXAA_REDUCE_MIN (1.0/128.0)
#define FXAA_REDUCE_MUL (1.0/8.0)
#define FXAA_SPAN_MAX 8.0

vec4 hook() {
    // Get dimensions and positions
    vec2 inputSize = HOOKED_size;
    vec2 inverseVP = vec2(1.0) / inputSize;
    vec2 fragCoord = HOOKED_pos * inputSize;
    
    // Sample neighboring texels
    vec2 coordNW = HOOKED_pos + vec2(-1.0, -1.0) * inverseVP;
    vec2 coordNE = HOOKED_pos + vec2(1.0, -1.0) * inverseVP;
    vec2 coordSW = HOOKED_pos + vec2(-1.0, 1.0) * inverseVP;
    vec2 coordSE = HOOKED_pos + vec2(1.0, 1.0) * inverseVP;
    
    vec3 rgbNW = HOOKED_tex(coordNW).rgb;
    vec3 rgbNE = HOOKED_tex(coordNE).rgb;
    vec3 rgbSW = HOOKED_tex(coordSW).rgb;
    vec3 rgbSE = HOOKED_tex(coordSE).rgb;
    vec3 rgbM  = HOOKED_texOff(0.0).rgb;
    
    // Calculate luminance with RPN
    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM, luma);
    
    // Calculate min/max luma
    float lumaMin = lumaNW;
    lumaMin = min(lumaMin, lumaNE);
    lumaMin = min(lumaMin, lumaSW);
    lumaMin = min(lumaMin, lumaSE);
    lumaMin = min(lumaMin, lumaM);
    
    float lumaMax = lumaNW;
    lumaMax = max(lumaMax, lumaNE);
    lumaMax = max(lumaMax, lumaSW);
    lumaMax = max(lumaMax, lumaSE);
    lumaMax = max(lumaMax, lumaM);
    
    // Calculate edge direction
    float dirX = lumaNW + lumaNE;
    dirX = dirX - lumaSW - lumaSE;
    dirX = -dirX;
    
    float dirY = lumaNW + lumaSW;
    dirY = dirY - lumaNE - lumaSE;
    
    // Direction reduction
    float sumLuma = lumaNW + lumaNE + lumaSW + lumaSE;
    sumLuma = sumLuma * 0.25;
    sumLuma = sumLuma * FXAA_REDUCE_MUL;
    float dirReduce = max(sumLuma, FXAA_REDUCE_MIN);
    
    // Compute direction scale
    float dirX_abs = abs(dirX);
    float dirY_abs = abs(dirY);
    float rcpDirMin = min(dirX_abs, dirY_abs);
    rcpDirMin = rcpDirMin + dirReduce;
    rcpDirMin = 1.0 / rcpDirMin;
    
    // Scale direction and clamp
    vec2 dir = vec2(dirX, dirY);
    dir = dir * rcpDirMin;
    
    vec2 dirMax = vec2(FXAA_SPAN_MAX);
    vec2 dirMin = vec2(-FXAA_SPAN_MAX);
    dir = max(dirMin, dir);
    dir = min(dirMax, dir);
    dir = dir * inverseVP;
    
    // Sample points along the direction
    vec2 dir13 = dir * (1.0/3.0 - 0.5);
    vec2 dir23 = dir * (2.0/3.0 - 0.5);
    vec2 dirN05 = dir * (-0.5);
    vec2 dirP05 = dir * 0.5;
    
    vec3 rgbA1 = HOOKED_tex(HOOKED_pos + dir13).rgb;
    vec3 rgbA2 = HOOKED_tex(HOOKED_pos + dir23).rgb;
    vec3 rgbA = rgbA1 + rgbA2;
    rgbA = rgbA * 0.5;
    
    vec3 rgbB1 = HOOKED_tex(HOOKED_pos + dirN05).rgb;
    vec3 rgbB2 = HOOKED_tex(HOOKED_pos + dirP05).rgb;
    vec3 rgbB = rgbB1 + rgbB2;
    rgbB = rgbB * 0.25;
    rgbB = rgbB + rgbA * 0.5;
    
    // Calculate luminance of result
    float lumaB = dot(rgbB, luma);
    
    // Conditional selection of output
    bool cond1 = lumaB < lumaMin;
    bool cond2 = lumaB > lumaMax;
    
    // Final output
    if(cond1 || cond2) {
        return vec4(rgbA, 1.0);
    } else {
        return vec4(rgbB, 1.0);
    }
}