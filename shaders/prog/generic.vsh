#include "/prelude/core.glsl"

#ifdef ENTITY_COLOR
	uniform vec4 entityColor;
#endif

#ifdef LIT
	uniform sampler2D lightmap;
#endif

out
#include "/lib/v_data_generic.glsl"

void main() {
	vec3 model = vec3(gl_Vertex);

	gl_Position = proj_mmul(mat4(gl_ProjectionMatrix), rot_trans_mmul(mat4(gl_ModelViewMatrix), model));

	#if defined TRANSLUCENT && !defined TERRAIN
		vec4 tint = vec4(gl_Color);
	#else
		vec3 tint = vec3(gl_Color);
	#endif

	#ifdef ENTITY_COLOR
		tint.rgb = mix(tint.rgb, entityColor.rgb, entityColor.a);
	#endif

	#ifdef LIT
		#if defined TERRAIN && MC_VERSION >= 12110 && IRIS_VERSION < 11006
			// `gl_TextureMatrix[1]` is broken here.
			// [8, 248] -> [0.5/16, 15.5/16]
			immut vec2 scale = vec2(256.0);
			immut vec2 offset = vec2(0.0);
		#else
			immut mat4 lm_tex_mat = mat4(gl_TextureMatrix[1]);
			immut vec2 scale = vec2(lm_tex_mat[0].x, lm_tex_mat[1].y);
			immut vec2 offset = vec2(lm_tex_mat[0].w, lm_tex_mat[1].w);
		#endif

		tint.rgb *= textureLod(lightmap, fma(vec2(gl_MultiTexCoord1), scale, offset), 0.0).rgb;
	#endif

	#ifdef TERRAIN
		v.tint = tint;

		#ifdef IRIS_FEATURE_FADE_VARIABLE
			v.fade = float(mc_chunkFade);
		#endif
	#else
		#ifdef TRANSLUCENT
			v.unorm4x8_tint = packUnorm4x8(tint);
		#else
			v.unorm4x8_tint = packUnorm4x8(vec4(tint, 0.0));
		#endif
	#endif

	#ifdef TEXTURED
		v.coord = rot_trans_mmul(mat4(gl_TextureMatrix[0]), vec2(gl_MultiTexCoord0));
	#endif
}
