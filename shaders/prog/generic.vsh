#include "/prelude/core.glsl"

#ifdef ENTITY_COLOR
	uniform vec4 entityColor;
#endif

#ifdef LIGHT
	uniform sampler2D lightmap;
#endif

out VertexData {
	#ifdef TINT_ALPHA
		layout(location = 0, component = 0) vec4 tint;
	#else
		layout(location = 0, component = 0) vec3 tint;
	#endif

	#ifdef TEXTURE
		layout(location = 1, component = 0) vec2 coord;
	#endif
} v;

void main() {
	vec3 model = vec3(gl_Vertex);

	gl_Position = proj_mmul(mat4(gl_ProjectionMatrix), rot_trans_mmul(mat4(gl_ModelViewMatrix), model));

	#ifdef TINT_ALPHA
		v.tint = vec4(gl_Color);
	#else
		v.tint = vec3(gl_Color);
	#endif

	#ifdef ENTITY_COLOR
		v.tint.rgb = mix(v.tint.rgb, entityColor.rgb, entityColor.a);
	#endif

	#ifdef LIGHT
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

		v.tint.rgb *= textureLod(lightmap, fma(vec2(gl_MultiTexCoord1), scale, offset), 0.0).rgb;
	#endif

	#ifdef TEXTURE
		v.coord = rot_trans_mmul(mat4(gl_TextureMatrix[0]), vec2(gl_MultiTexCoord0));
	#endif
}
