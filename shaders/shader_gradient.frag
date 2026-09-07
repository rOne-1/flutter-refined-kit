#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uSpeed;
uniform float uFrequency;
uniform float uGrainStrength;
uniform float uColorCount;
uniform vec4 uColor0;
uniform vec4 uColor1;
uniform vec4 uColor2;
uniform vec4 uColor3;
uniform vec4 uColor4;

out vec4 fragColor;

// Simplex 3D noise
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 mod289(vec4 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec4 permute(vec4 x) { return mod289(((x * 34.0) + 1.0) * x); }
vec4 taylorInvSqrt(vec4 r) { return 1.79284291400159 - 0.85373472095314 * r; }

float snoise(vec3 v) {
  const vec2 C = vec2(1.0 / 6.0, 1.0 / 3.0);
  const vec4 D = vec4(0.0, 0.5, 1.0, 2.0);

  vec3 i  = floor(v + dot(v, C.yyy));
  vec3 x0 = v - i + dot(i, C.xxx);

  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min(g.xyz, l.zxy);
  vec3 i2 = max(g.xyz, l.zxy);

  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;

  i = mod289(i);
  vec4 p = permute(permute(permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0));

  float n_ = 0.142857142857;
  vec3 ns = n_ * D.wyz - D.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_);

  vec4 x = x_ * ns.x + ns.yyyy;
  vec4 y = y_ * ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4(x.xy, y.xy);
  vec4 b1 = vec4(x.zw, y.zw);

  vec4 s0 = floor(b0) * 2.0 + 1.0;
  vec4 s1 = floor(b1) * 2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
  vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

  vec3 p0 = vec3(a0.xy, h.x);
  vec3 p1 = vec3(a0.zw, h.y);
  vec3 p2 = vec3(a1.xy, h.z);
  vec3 p3 = vec3(a1.zw, h.w);

  vec4 norm = taylorInvSqrt(vec4(dot(p0, p0), dot(p1, p1), dot(p2, p2), dot(p3, p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

  vec4 m = max(0.6 - vec4(dot(x0, x0), dot(x1, x1), dot(x2, x2), dot(x3, x3)), 0.0);
  m = m * m;
  return 42.0 * dot(m * m, vec4(dot(p0, x0), dot(p1, x1), dot(p2, x2), dot(p3, x3)));
}

vec4 evaluateGradient(float factor) {
  float clampedFactor = clamp(factor, 0.0, 1.0);
  int count = int(clamp(uColorCount, 3.0, 5.0));

  if (count == 3) {
    float scaled = clampedFactor * 2.0;
    if (scaled < 1.0) {
      return mix(uColor0, uColor1, scaled);
    } else {
      return mix(uColor1, uColor2, scaled - 1.0);
    }
  } else if (count == 4) {
    float scaled = clampedFactor * 3.0;
    if (scaled < 1.0) {
      return mix(uColor0, uColor1, scaled);
    } else if (scaled < 2.0) {
      return mix(uColor1, uColor2, scaled - 1.0);
    } else {
      return mix(uColor2, uColor3, scaled - 2.0);
    }
  } else {
    float scaled = clampedFactor * 4.0;
    if (scaled < 1.0) {
      return mix(uColor0, uColor1, scaled);
    } else if (scaled < 2.0) {
      return mix(uColor1, uColor2, scaled - 1.0);
    } else if (scaled < 3.0) {
      return mix(uColor2, uColor3, scaled - 2.0);
    } else {
      return mix(uColor3, uColor4, scaled - 3.0);
    }
  }
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uResolution, vec2(1.0, 1.0));

  float t = uTime * uSpeed * 0.25;

  // Domain warping with 3D simplex noise
  vec3 p = vec3(uv * uFrequency, t);
  float n1 = snoise(p);
  vec3 p2 = p + vec3(n1 * 0.7, n1 * 0.5, t * 0.3);
  float n2 = snoise(p2);
  vec3 p3 = p + vec3(n2 * 0.6, n2 * 0.8, t * 0.5);
  float n3 = snoise(p3);

  // Map [-1, 1] to [0, 1]
  float factor = n3 * 0.5 + 0.5;

  vec4 col = evaluateGradient(factor);

  // Procedural film grain overlay
  if (uGrainStrength > 0.0) {
    float grain = fract(sin(dot(fragCoord + vec2(t * 100.0, 0.0), vec2(12.9898, 78.233))) * 43758.5453);
    col.rgb += (grain - 0.5) * uGrainStrength;
  }

  fragColor = col;
}
