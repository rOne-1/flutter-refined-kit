#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uResolution;
uniform float uTime;
uniform float uFlowSpeed;
uniform float uDistortionScale;
uniform float uFrequency;
uniform vec4 uBaseColor;
uniform vec4 uHighlightColor;

out vec4 fragColor;

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / max(uResolution, vec2(1.0, 1.0));

  float t = uTime * uFlowSpeed * 0.35;
  vec2 p = uv * uFrequency;

  // Multi-pass sinusoidal domain warping
  for (int i = 1; i < 5; i++) {
    float fi = float(i);
    p.x += (0.35 / fi) * sin(fi * 2.4 * p.y + t + 0.3 * fi);
    p.y += (0.35 / fi) * cos(fi * 2.4 * p.x + t + 0.4 * (fi + 1.0));
  }

  // Surface curvature and reflection estimation
  float v = sin(p.x * uDistortionScale + t) * cos(p.y * uDistortionScale + t);

  // Sharp metallic specular reflection bands
  float reflection = abs(sin(v * 3.14159265 + t * 0.5));
  float specular = pow(reflection, 3.5);
  float rim = pow(1.0 - abs(v), 2.0) * 0.4;

  float highlightFactor = clamp(specular + rim, 0.0, 1.0);
  vec3 col = mix(uBaseColor.rgb, uHighlightColor.rgb, highlightFactor);
  float alpha = mix(uBaseColor.a, uHighlightColor.a, highlightFactor);

  fragColor = vec4(clamp(col, 0.0, 1.0), clamp(alpha, 0.0, 1.0));
}
