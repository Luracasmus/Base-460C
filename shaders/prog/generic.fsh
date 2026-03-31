#include "/prelude/core.glsl"

/* RENDERTARGETS: 0 */
#ifdef TRANSLUCENT
	layout(location = 0) out vec4 colortex0;
#else
	layout(location = 0) out vec3 colortex0;
#endif

#ifdef TEXTURED
	uniform sampler2D gtexture;

	#ifdef ALPHA_CHECK
		layout(depth_greater) out float gl_FragDepth;
		uniform float alphaTestRef;
	#else
		layout(depth_unchanged) out float gl_FragDepth;
	#endif
#endif

in
#include "/lib/v_data_generic.glsl"

#ifdef FOG
	uniform float far, fogStart, fogEnd, viewHeight, viewWidth;
	uniform vec3 fogColor;
	uniform mat4 gbufferModelViewInverse, gbufferProjectionInverse;

	float linear_step(float edge0, float edge1, float x) {
		return clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	}
#endif

void main() {
	#ifdef TERRAIN
		immut vec3 tint = v.tint;
	#else
		#ifdef TRANSLUCENT
			immut vec4 tint = unpackUnorm4x8(v.unorm4x8_tint);
		#else
			immut vec3 tint = unpackUnorm4x8(v.unorm4x8_tint).rgb;
		#endif
	#endif

	#ifdef TEXTURED
		#if defined ALPHA_CHECK || defined TRANSLUCENT
			vec4 tex = texture(gtexture, v.coord);
		#else
			vec3 tex = texture(gtexture, v.coord).rgb;
		#endif

		#ifdef ALPHA_CHECK
			if (tex.a < alphaTestRef) discard;
		#endif

		#ifdef TRANSLUCENT
			#ifdef TERRAIN
				#ifdef IRIS_FEATURE_FADE_VARIABLE
					tex *= vec4(tint, v.fade);
				#else
					tex.rgb *= tint;
				#endif
			#else
				tex *= tint;
			#endif
		#else
			tex.rgb *= tint;
		#endif

		#if !defined TRANSLUCENT && defined TERRAIN && defined IRIS_FEATURE_FADE_VARIABLE
			tex.rgb = mix(fogColor, tex.rgb, v.fade);
		#endif

		#ifdef TRANSLUCENT
			colortex0 = tex;
		#else
			colortex0 = tex.rgb;
		#endif
	#else
		colortex0 = tint;
	#endif

	#ifdef FOG
		immut vec3 ndc = fma(gl_FragCoord.xyz, vec3(2.0 / vec2(viewWidth, viewHeight), 2.0), vec3(-1.0));
		immut vec3 view = proj_inv(gbufferProjectionInverse, ndc);
		immut vec3 pe = mat3(gbufferModelViewInverse) * view;

		immut float dist = length(pe);

		#ifdef CLOUD_FOG
			// Iris doesn't provide any uniforms for the cloud distance,
			// and we don't want to be doing a bunch of stuff with atomics to calculate the distance to the furthest cloud vertices,
			// so we let the user configure it.

			immut float visibility = linear_step(float(CLOUD_FOG_END * 16), 0.0, dist);
			colortex0.a *= visibility;
		#else
			immut float cyl_dist = max(length(pe.xz), abs(pe.y));
			immut float fog = max(
				linear_step(fogStart, fogEnd, dist), // Spherical environment fog.
				linear_step(far - clamp(0.1 * far, 4.0, 64.0), far, cyl_dist) // Cylidrical border fog.
			);

			colortex0.rgb = mix(colortex0.rgb, fogColor, fog);
		#endif
	#endif
}
