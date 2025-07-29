#include "/prelude/core.glsl"

/* RENDERTARGETS: 0 */
layout(location = 0) out vec3 colortex0;

uniform int renderStage;
uniform float viewHeight, viewWidth;
uniform vec3 fogColor, skyColor, upPosition;
uniform mat4 gbufferProjectionInverse;

in VertexData {
	layout(location = 0, component = 0) flat vec3 tint;
} v;

// The code below is largely based on:
// https://github.com/shaderLABS/Base-330/blob/main/shaders/gbuffers_skybasic.fsh

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 sky(vec3 n_view) {
	immut float up_dot = dot(n_view, 0.01 * upPosition); // Not much, what's up with you?
	return mix(skyColor, fogColor, fogify(max(up_dot, 0.0), 0.25));
}

void main() {
	immut vec2 ndc = fma(gl_FragCoord.xy, 2.0 / vec2(viewWidth, viewHeight), vec2(-1.0));

	immut vec3 view = vec3(
		vec2(gbufferProjectionInverse[0].x, gbufferProjectionInverse[1].y) * ndc,
		gbufferProjectionInverse[3].z
	) / (gbufferProjectionInverse[2].w + gbufferProjectionInverse[3].w);

	colortex0 = sky(normalize(view));

	if (renderStage == MC_RENDER_STAGE_STARS) {
		colortex0 += v.tint; // todo!() this seems to differ a bit from Vanilla
	}
}
