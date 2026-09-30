// CRT-Aperture-DSAA by EasyMode and He2A
// Shader converted from libretro shader to mpv, then added downscaling and fxaa.

//!PARAM FXAA_STRENGTH
//!DESC FXAA Strength
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0.5

//!PARAM RESIZE_FACTOR
//!DESC Downscale factor
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM BRIGHTNESS
//!DESC Brightness
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 2
1.5

//!PARAM GAMMA_INPUT
//!DESC Gamma Input
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 5
2.4

//!PARAM GAMMA_OUTPUT
//!DESC Gamma Output
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 5
2.2

//!PARAM GLOW_DIFFUSION
//!DESC Glow Diffusion
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0.25

//!PARAM GLOW_HALATION
//!DESC Glow Halation
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0.5

//!PARAM GLOW_HEIGHT
//!DESC Glow Height
//!TYPE CONSTANT float
//!MINIMUM 0.05
//!MAXIMUM 0.65
0.5

//!PARAM GLOW_WIDTH
//!DESC Glow Width
//!TYPE CONSTANT float
//!MINIMUM 0.05
//!MAXIMUM 0.65
0.5

//!PARAM MASK_COLORS
//!DESC Mask Colors
//!TYPE CONSTANT float
//!MINIMUM 2
//!MAXIMUM 3
2

//!PARAM MASK_SIZE
//!DESC Mask Size
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 9
1

//!PARAM MASK_STRENGTH
//!DESC Mask Strength
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
0.7

//!PARAM SCANLINE_OFFSET
//!DESC Scanline Offset
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM SCANLINE_SHAPE
//!DESC Scanline Shape
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 100
5

//!PARAM SCANLINE_SIZE_MAX
//!DESC Scanline Size Max.
//!TYPE CONSTANT float
//!MINIMUM 0.5
//!MAXIMUM 1.5
1.5

//!PARAM SCANLINE_SIZE_MIN
//!DESC Scanline Size Min.
//!TYPE CONSTANT float
//!MINIMUM 0.5
//!MAXIMUM 1.5
0.5

//!PARAM SCANLINE_STRENGTH
//!DESC Scanline Strength 
//!TYPE CONSTANT float
//!MINIMUM 0
//!MAXIMUM 1
1

//!PARAM SHARPNESS_EDGES
//!DESC Sharpness Edges
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 5
1

//!PARAM SHARPNESS_IMAGE
//!DESC Sharpness Image
//!TYPE CONSTANT float
//!MINIMUM 1
//!MAXIMUM 5
5

//!HOOK MAIN
//!COMPONENTS 4
//!DESC sRGB to linear RGB
//!SAVE MAIN_RGB
//!BIND HOOKED

vec4 hook() {
	return linearize(HOOKED_tex(HOOKED_pos));
}

//!HOOK MAIN
//!COMPONENTS 4
//!DESC Downscale Input
//!SAVE DOWNSCALED
//!BIND MAIN_RGB
//!WIDTH OUTPUT.width 1.0 RESIZE_FACTOR 0.5 * - *
//!HEIGHT OUTPUT.height 1.0 RESIZE_FACTOR 0.5 * - *

vec4 hook() {
    // Simple downscaling - just sample directly
    return MAIN_RGB_tex(MAIN_RGB_pos);
}

//!HOOK MAIN
//!COMPONENTS 4
//!DESC Apply FXAA
//!SAVE FXAA_PROCESSED
//!BIND DOWNSCALED
//!WIDTH DOWNSCALED.width
//!HEIGHT DOWNSCALED.height

// FXAA settings
#define FXAA_REDUCE_MIN (1.0/128.0)
#define FXAA_REDUCE_MUL (1.0/8.0)
#define FXAA_SPAN_MAX 8.0

vec4 hook() {
    // Get dimensions and positions
    vec2 inputSize = DOWNSCALED_size;
    vec2 inverseVP = vec2(1.0) / inputSize;
    vec2 fragCoord = DOWNSCALED_pos * inputSize;
    
    // Sample neighboring texels using RPN
    vec2 coordNW = DOWNSCALED_pos + vec2(-1.0, -1.0) * inverseVP;
    vec2 coordNE = DOWNSCALED_pos + vec2(1.0, -1.0) * inverseVP;
    vec2 coordSW = DOWNSCALED_pos + vec2(-1.0, 1.0) * inverseVP;
    vec2 coordSE = DOWNSCALED_pos + vec2(1.0, 1.0) * inverseVP;
    
    vec3 rgbNW = DOWNSCALED_tex(coordNW).rgb;
    vec3 rgbNE = DOWNSCALED_tex(coordNE).rgb;
    vec3 rgbSW = DOWNSCALED_tex(coordSW).rgb;
    vec3 rgbSE = DOWNSCALED_tex(coordSE).rgb;
    vec3 rgbM  = DOWNSCALED_texOff(0.0).rgb;
    
    // Calculate luminance with RPN
    vec3 luma = vec3(0.299, 0.587, 0.114);
    float lumaNW = dot(rgbNW, luma);
    float lumaNE = dot(rgbNE, luma);
    float lumaSW = dot(rgbSW, luma);
    float lumaSE = dot(rgbSE, luma);
    float lumaM  = dot(rgbM, luma);
    
    // Calculate min/max luma using RPN
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
    
    // Calculate edge direction using RPN
    float dirX = lumaNW + lumaNE;
    dirX = dirX - lumaSW - lumaSE;
    dirX = -dirX;
    
    float dirY = lumaNW + lumaSW;
    dirY = dirY - lumaNE - lumaSE;
    
    // Direction reduction using RPN
    float sumLuma = lumaNW + lumaNE + lumaSW + lumaSE;
    sumLuma = sumLuma * 0.25;
    sumLuma = sumLuma * FXAA_REDUCE_MUL;
    float dirReduce = max(sumLuma, FXAA_REDUCE_MIN);
    
    // Compute direction scale using RPN
    float dirX_abs = abs(dirX);
    float dirY_abs = abs(dirY);
    float rcpDirMin = min(dirX_abs, dirY_abs);
    rcpDirMin = rcpDirMin + dirReduce;
    rcpDirMin = 1.0 / rcpDirMin;
    
    // Scale direction and clamp using RPN
    vec2 dir = vec2(dirX, dirY);
    dir = dir * rcpDirMin;
    
    vec2 dirMax = vec2(FXAA_SPAN_MAX);
    vec2 dirMin = vec2(-FXAA_SPAN_MAX);
    dir = max(dirMin, dir);
    dir = min(dirMax, dir);
    dir = dir * inverseVP;
    
    // Sample points along the direction using RPN
    vec2 dir13 = dir * (1.0/3.0 - 0.5);
    vec2 dir23 = dir * (2.0/3.0 - 0.5);
    vec2 dirN05 = dir * (-0.5);
    vec2 dirP05 = dir * 0.5;
    
    vec3 rgbA1 = DOWNSCALED_tex(DOWNSCALED_pos + dir13).rgb;
    vec3 rgbA2 = DOWNSCALED_tex(DOWNSCALED_pos + dir23).rgb;
    vec3 rgbA = rgbA1 + rgbA2;
    rgbA = rgbA * 0.5;
    
    vec3 rgbB1 = DOWNSCALED_tex(DOWNSCALED_pos + dirN05).rgb;
    vec3 rgbB2 = DOWNSCALED_tex(DOWNSCALED_pos + dirP05).rgb;
    vec3 rgbB = rgbB1 + rgbB2;
    rgbB = rgbB * 0.25;
    rgbB = rgbB + rgbA * 0.5;
    
    // Calculate luminance of result using RPN
    float lumaB = dot(rgbB, luma);
    
    // Conditional selection of output using RPN
    bool cond1 = lumaB < lumaMin;
    bool cond2 = lumaB > lumaMax;
    
    // Allow adjustable FXAA strength with blend
    vec3 result;
    if(cond1 || cond2) {
        result = mix(rgbM, rgbA, FXAA_STRENGTH);
    } else {
        result = mix(rgbM, rgbB, FXAA_STRENGTH);
    }
    
    return vec4(result, 1.0);
}

//!HOOK MAIN
//!COMPONENTS 4
//!DESC CRT Effect
//!WIDTH OUTPUT.width
//!HEIGHT OUTPUT.height
//!BIND FXAA_PROCESSED

struct _params_ {
    vec4 SourceSize;
    vec4 OutputSize;
    uint FrameCount;
    float FXAA_STRENGTH;
    float RESIZE_FACTOR;
    float SHARPNESS_IMAGE;
    float SHARPNESS_EDGES;
    float GLOW_WIDTH;
    float GLOW_HEIGHT;
    float GLOW_HALATION;
    float GLOW_DIFFUSION;
    float MASK_COLORS;
    float MASK_STRENGTH;
    float MASK_SIZE;
    float SCANLINE_SIZE_MIN;
    float SCANLINE_SIZE_MAX;
    float SCANLINE_SHAPE;
    float SCANLINE_OFFSET;
    float SCANLINE_STRENGTH;
    float GAMMA_INPUT;
    float GAMMA_OUTPUT;
    float BRIGHTNESS;
} params = _params_(
    vec4(FXAA_PROCESSED_size, FXAA_PROCESSED_pt), 
    vec4(target_size, 1.0 / target_size.x, 1.0 / target_size.y), 
    uint(frame), 
    float(FXAA_STRENGTH), 
    float(RESIZE_FACTOR), 
    float(SHARPNESS_IMAGE), 
    float(SHARPNESS_EDGES), 
    float(GLOW_WIDTH), 
    float(GLOW_HEIGHT), 
    float(GLOW_HALATION), 
    float(GLOW_DIFFUSION), 
    float(MASK_COLORS), 
    float(MASK_STRENGTH), 
    float(MASK_SIZE), 
    float(SCANLINE_SIZE_MIN), 
    float(SCANLINE_SIZE_MAX), 
    float(SCANLINE_SHAPE), 
    float(SCANLINE_OFFSET),
    float(SCANLINE_STRENGTH),
    float(GAMMA_INPUT), 
    float(GAMMA_OUTPUT), 
    float(BRIGHTNESS)
);

vec4 Position = vec4(FXAA_PROCESSED_pos, 0.0, 1.0);
vec2 TexCoord = FXAA_PROCESSED_pos;
vec2 vTexCoord;

mat3x3 get_color_matrix(sampler2D tex, vec2 co, vec2 dx) {
    return mat3x3(
        pow(texture(tex, co - dx).rgb, vec3(params.GAMMA_INPUT)),
        pow(texture(tex, co).rgb, vec3(params.GAMMA_INPUT)),
        pow(texture(tex, co + dx).rgb, vec3(params.GAMMA_INPUT))
    );
}

vec3 blur(mat3 m, float dist, float rad) {
    vec3 x = vec3(dist - 1.0, dist, dist + 1.0) / rad;
    vec3 w = exp2(x * x * -1.0);
    return (m[0] * w.x + m[1] * w.y + m[2] * w.z) / (w.x + w.y + w.z);
}

vec3 filter_gaussian(sampler2D tex, vec2 co, vec2 tex_size) {
    vec2 dx = vec2(1.0 / tex_size.x, 0.0);
    vec2 dy = vec2(0.0, 1.0 / tex_size.y);
    vec2 pix_co = co * tex_size;
    vec2 tex_co = (floor(pix_co) + 0.5) / tex_size;
    vec2 dist = (fract(pix_co) - 0.5) * -1.0;
    
    mat3x3 line0 = get_color_matrix(tex, tex_co - dy, dx);
    mat3x3 line1 = get_color_matrix(tex, tex_co, dx);
    mat3x3 line2 = get_color_matrix(tex, tex_co + dy, dx);
    
    mat3x3 column = mat3x3(
        blur(line0, dist.x, params.GLOW_WIDTH),
        blur(line1, dist.x, params.GLOW_WIDTH),
        blur(line2, dist.x, params.GLOW_WIDTH)
    );
    
    return blur(column, dist.y, params.GLOW_HEIGHT);
}

vec3 filter_lanczos(sampler2D tex, vec2 co, vec2 tex_size, float sharp) {
    tex_size.x *= sharp;
    vec2 dx = vec2(1.0 / tex_size.x, 0.0);
    vec2 pix_co = co * tex_size - vec2(0.5, 0.0);
    vec2 tex_co = (floor(pix_co) + vec2(0.5, 0.001)) / tex_size;
    vec2 dist = fract(pix_co);
    
    vec4 coef = 3.1415927 * vec4(dist.x + 1.0, dist.x, dist.x - 1.0, dist.x - 2.0);
    coef = max(abs(coef), 0.00001);
    coef = 2.0 * sin(coef) * sin(coef / 2.0) / (coef * coef);
    coef /= dot(coef, vec4(1.0));
    
    vec4 col1 = vec4(pow(texture(tex, tex_co).rgb, vec3(params.GAMMA_INPUT)), 1.0);
    vec4 col2 = vec4(pow(texture(tex, tex_co + dx).rgb, vec3(params.GAMMA_INPUT)), 1.0);
    
    return (mat4x4(col1, col1, col2, col2) * coef).rgb;
}

vec3 get_scanline_weight(float x, vec3 col) {
    vec3 beam = mix(
        vec3(params.SCANLINE_SIZE_MIN),
        vec3(params.SCANLINE_SIZE_MAX),
        pow(col, vec3(1.0 / params.SCANLINE_SHAPE))
    );
    
    vec3 x_mul = 2.0 / beam;
    vec3 x_offset = x_mul * 0.5;
    
    return smoothstep(0.0, 1.0, 1.0 - abs(x * x_mul - x_offset)) * x_offset;
}

vec3 get_mask_weight(float x) {
    float i = mod(floor(x * params.OutputSize.x / params.MASK_SIZE), params.MASK_COLORS);
    
    if (i == 0.0) 
        return mix(vec3(1.0, 0.0, 1.0), vec3(1.0, 0.0, 0.0), params.MASK_COLORS - 2.0);
    else if (i == 1.0) 
        return vec3(0.0, 1.0, 0.0);
    else 
        return vec3(0.0, 0.0, 1.0);
}

void vertex_main() {
    vTexCoord = TexCoord;
}

vec4 hook() {
    vertex_main();
    
    // Calculate proper scaling factor between source and output
    float scale = params.OutputSize.y / params.SourceSize.y;
    float offset = 1.0 / scale * 0.5;
    
    if (bool(mod(floor(scale), 2.0))) 
        offset = 0.0;
    
    // Get texture coordinate
    vec2 co = vTexCoord;
    
    // Apply scanline offset to y-coordinate
    co.y = (co.y * params.SourceSize.y - offset * params.SCANLINE_OFFSET) / params.SourceSize.y;
    
    // Apply CRT effects
    vec3 col_glow = filter_gaussian(FXAA_PROCESSED_raw, co, params.SourceSize.xy);
    vec3 col_soft = filter_lanczos(FXAA_PROCESSED_raw, co, params.SourceSize.xy, params.SHARPNESS_IMAGE);
    vec3 col_sharp = filter_lanczos(FXAA_PROCESSED_raw, co, params.SourceSize.xy, params.SHARPNESS_EDGES);
    
    vec3 col = sqrt(col_sharp * col_soft);
    
    // Calculate scanline position and apply scanlines
    float scanlinePos = fract(co.y * params.SourceSize.y);
    vec3 scanlineWeight = get_scanline_weight(scanlinePos, col_soft);
    col *= scanlineWeight;
    
    // Apply glow effects
    col_glow = clamp(col_glow - col, 0.0, 1.0);
    col += col_glow * col_glow * params.GLOW_HALATION;
    
    // Apply mask based on output coordinates
    col = mix(
        col, 
        col * get_mask_weight(vTexCoord.x) * params.MASK_COLORS, 
        params.MASK_STRENGTH
    );
    
    col += col_glow * params.GLOW_DIFFUSION;
    col = pow(col * params.BRIGHTNESS, vec3(1.0 / params.GAMMA_OUTPUT));
    
    return delinearize(vec4(col, 1.0));
}