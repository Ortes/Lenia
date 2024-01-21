#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform float uTime;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec4 color = texture(uTexture, FlutterFragCoord());

    color.rgb = vec3(sin(uTime), cos(uTime), 0.0);

    fragColor = vec4(vec3(sin(uTime), cos(uTime), 0.0), 1.0);
}
