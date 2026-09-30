//!HOOK MAIN
//!BIND HOOKED
//!DESC VHS Effect
//!WIDTH HOOKED.w
//!HEIGHT HOOKED.h

// - VHS shader by hunterk
// - Adapted for MPV by shmup

#define resolution vec2(HOOKED_size.x, HOOKED_size.y)
#define resolutionFactor min(resolution.y / 1080.0, 1.0)

// parameters - adjust these values to tweak the effect
#define wiggle (5.0 * resolutionFactor)
#define smear (0.75 * resolutionFactor)

// timing functions
#define iTime (frame / 60.0)

//YIQ/RGB conversion
vec3 rgb2yiq(vec3 c) {
  return vec3(
      (0.2989*c.r + 0.5959*c.g + 0.2115*c.b),
      (0.5870*c.r - 0.2744*c.g - 0.5229*c.b),
      (0.1140*c.r - 0.3216*c.g + 0.3114*c.b)
      );
}

vec3 yiq2rgb(vec3 c) {
  return vec3(
      (1.0*c.r + 1.0*c.g + 1.0*c.b),
      (0.956*c.r - 0.2720*c.g - 1.1060*c.b),
      (0.6210*c.r - 0.6474*c.g + 1.7046*c.b)
      );
}

vec2 Circle(float Start, float Points, float Point) {
  float Rad = (3.141592 * 2.0 * (1.0 / Points)) * (Point + Start);
  return vec2(-(.3+Rad), cos(Rad));
}

vec3 Blur(sampler2D tex, vec2 uv, float d) {
  float t = 0.0;
  float b = 1.0;
  vec2 PixelOffset = vec2(d+.0005*t, 0);

  float Start = 2.0 / 14.0;
  vec2 Scale = 0.66 * 4.0 * 2.0 * PixelOffset.xy * resolutionFactor;

  vec3 N0 = texture(tex, uv + Circle(Start, 14.0, 0.0) * Scale).rgb;
  vec3 N1 = texture(tex, uv + Circle(Start, 14.0, 1.0) * Scale).rgb;
  vec3 N2 = texture(tex, uv + Circle(Start, 14.0, 2.0) * Scale).rgb;
  vec3 N3 = texture(tex, uv + Circle(Start, 14.0, 3.0) * Scale).rgb;
  vec3 N4 = texture(tex, uv + Circle(Start, 14.0, 4.0) * Scale).rgb;
  vec3 N5 = texture(tex, uv + Circle(Start, 14.0, 5.0) * Scale).rgb;
  vec3 N6 = texture(tex, uv + Circle(Start, 14.0, 6.0) * Scale).rgb;
  vec3 N7 = texture(tex, uv + Circle(Start, 14.0, 7.0) * Scale).rgb;
  vec3 N8 = texture(tex, uv + Circle(Start, 14.0, 8.0) * Scale).rgb;
  vec3 N9 = texture(tex, uv + Circle(Start, 14.0, 9.0) * Scale).rgb;
  vec3 N10 = texture(tex, uv + Circle(Start, 14.0, 10.0) * Scale).rgb;
  vec3 N11 = texture(tex, uv + Circle(Start, 14.0, 11.0) * Scale).rgb;
  vec3 N12 = texture(tex, uv + Circle(Start, 14.0, 12.0) * Scale).rgb;
  vec3 N13 = texture(tex, uv + Circle(Start, 14.0, 13.0) * Scale).rgb;
  vec3 N14 = texture(tex, uv).rgb;

  vec4 clr = texture(tex, uv);
  float W = 1.0 / 15.0;

  clr.rgb =
    (N0 * W) +
    (N1 * W) +
    (N2 * W) +
    (N3 * W) +
    (N4 * W) +
    (N5 * W) +
    (N6 * W) +
    (N7 * W) +
    (N8 * W) +
    (N9 * W) +
    (N10 * W) +
    (N11 * W) +
    (N12 * W) +
    (N13 * W) +
    (N14 * W);
  return vec3(clr.rgb)*b;
}

float onOff(float a, float b, float c, float framecount) {
  return step(c, sin((framecount * 0.001) + a*cos((framecount * 0.001)*b)));
}

vec2 jumpy(vec2 uv, float framecount) {
  vec2 look = uv;
  float window = 1.0/(1.0+80.0*(look.y-mod(framecount/4.0,1.0))*(look.y-mod(framecount/4.0,1.0)));
  look.x += 0.05 * sin(look.y*10.0 + framecount)/20.0*onOff(4.0,4.0,0.3, framecount)*(0.5+cos(framecount*20.0))*window * resolutionFactor;
  float vShift = (0.1*wiggle) * 0.4*onOff(2.0,3.0,0.9, framecount)*(sin(framecount)*sin(framecount*20.0) +
      (0.5 + 0.1*sin(framecount*200.0)*cos(framecount)));
  look.y = mod(look.y - 0.01 * vShift, 1.0);
  return look;
}

vec4 hook() {
  float framecount = iTime * 60.0;
  float d = 0.1 - ceil(mod(iTime/3.0,1.0) + 0.5) * 0.1;
  vec2 uv = jumpy(HOOKED_pos, framecount);
  vec2 uv2 = uv;

  float s = 0.0001 * -d + 0.0001 * wiggle * sin(iTime);

  float e = min(0.30,pow(max(0.0,cos(uv.y*4.0+0.3)-0.75)*(s+0.5)*1.0,3.0))*25.0 * resolutionFactor;
  uv.x+=abs(s*pow(min(0.003,(-uv.y+(0.01*mod(iTime, 17.0))))*3.0,2.0)) * resolutionFactor;
  float c = max(0.0001,0.002*d) * smear * resolutionFactor;

  d=0.051+abs(sin(s/4.0));
  vec2 uvo = uv;
  vec4 final;
  final.rgb = Blur(HOOKED_raw, uv, c+c*(uv.x));
  float y = rgb2yiq(final.rgb).r;

  uv.x+=0.01*d;
  c*=6.0;
  final.rgb = Blur(HOOKED_raw, uv, c);
  float i = rgb2yiq(final.rgb).g;

  uv.x+=0.005*d;

  c*=2.50;
  final.rgb = Blur(HOOKED_raw, uv, c);
  float q = rgb2yiq(final.rgb).b;
  final = vec4(yiq2rgb(vec3(y,i,q))-pow(s+e*2.0,3.0), 1.0);

  return final;
}
