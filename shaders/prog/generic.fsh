#include "/prelude/core.glsl"

/* RENDERTARGETS: 0 */
#ifdef ALPHA_BLEND
	layout(location = 0) out vec4 colortex0;
#else
	layout(location = 0) out vec3 colortex0;
#endif

#ifdef TEXTURE
	uniform sampler2D gtexture;

	#ifdef ALPHA_CHECK
		uniform float alphaTestRef;
	#endif
#endif

in VertexData {
	#ifdef TINT_ALPHA
		layout(location = 0, component = 0) vec4 tint;
	#else
		layout(location = 0, component = 0) vec3 tint;
	#endif

	#ifdef TEXTURE
		layout(location = 1, component = 0) vec2 coord;
	#endif
} v;

#ifdef FOG
	uniform float far, fogStart, fogEnd, viewHeight, viewWidth;
	uniform vec3 fogColor;
	uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;

	float linear_step(float edge0, float edge1, float x) {
		return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	}
#endif

void main() {
	#ifdef TEXTURE
		#if defined ALPHA_CHECK || defined ALPHA_BLEND
			vec4 tex = texture(gtexture, v.coord);
		#else
			vec3 tex = texture(gtexture, v.coord).rgb;
		#endif

		#ifdef ALPHA_CHECK
			if (tex.a < alphaTestRef) discard;
		#endif

		tex.rgb *= v.tint.rgb;

		#ifdef ALPHA_BLEND
			colortex0 = tex;
		#else
			colortex0 = tex.rgb;
		#endif
	#else
		colortex0 = v.tint;
	#endif

	#ifdef FOG
		immut vec3 ndc = fma(gl_FragCoord.xyz, vec3(2.0 / vec2(viewWidth, viewHeight), 2.0), vec3(-1.0));
		immut vec3 view = proj_inv(gbufferProjectionInverse, ndc);
		immut vec3 pe = mat3(gbufferModelViewInverse) * view;

		immut float dist = length(pe);

		#ifdef CLOUD_FOG
			// Iris doesn't provide any uniforms for the cloud distance,
			// and we don't want to be doing a bunch of stuff with atomics to calculate the distance to the furthest cloud vertices,
			// so we assume it's always 128 chunks (maximum Cloud Distance in Vanilla)
			const float cloud_fog_end = 2048.0;

			immut float visibility = linear_step(cloud_fog_end, 0.0, dist);
			colortex0.a *= visibility;
		#else
			// todo!() make sure this matches Vanilla fog
			const float border_fog_start = 16.0;

			immut float cyl_dist = max(length(pe.xz), abs(pe.y));
			immut float fog = max(
				linear_step(fogStart, fogEnd, dist),
				linear_step(far - border_fog_start, far, cyl_dist)
			);

			colortex0.rgb = mix(colortex0.rgb, fogColor, fog);
		#endif
	#endif
}
