#include "/prelude/core.glsl"

uniform mat4 modelViewMatrix, projectionMatrix;

#ifdef CHUNK_OFFSET
	uniform vec3 chunkOffset;
#endif

#ifdef ENTITY_COLOR
	uniform vec4 entityColor;
#endif

#ifdef TEXTURE
	uniform mat4 textureMatrix;

	in vec2 vaUV0;
#endif

#ifdef LIGHT
	uniform sampler2D lightmap;

	in ivec2 vaUV2;
#endif

in vec3 vaPosition;
in vec4 vaColor;

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
	vec3 model = vaPosition;

	#ifdef CHUNK_OFFSET
		model += chunkOffset;
	#endif

	gl_Position = proj_mmul(projectionMatrix, rot_trans_mmul(modelViewMatrix, model));;

	#ifdef TINT_ALPHA
		v.tint = vaColor;
	#else
		v.tint = vaColor.rgb;
	#endif

	#ifdef ENTITY_COLOR
		v.tint.rgb = mix(v.tint.rgb, entityColor.rgb, entityColor.a);
	#endif

	#ifdef LIGHT
		#ifdef TERRAIN
			// [8, 248] to [0.5/16.0, 15.5/16.0].
			immut vec2 lm_coord = vec2(1.0/256.0) * vaUV2;
		#else
			// [0, 240] to [0.5/16.0, 15.5/16.0].
			immut vec2 lm_coord = fma(vaUV2, vec2(0.00390625), vec2(0.03125));
		#endif

		v.tint.rgb *= textureLod(lightmap, lm_coord, 0.0).rgb;
	#endif

	#ifdef TEXTURE
		v.coord = rot_trans_mmul(textureMatrix, vaUV0);
	#endif
}
