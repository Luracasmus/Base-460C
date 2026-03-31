VertexData {
	#ifdef TERRAIN
		layout(location = 0, component = 0) vec3 tint;

		#ifdef IRIS_FEATURE_FADE_VARIABLE
			layout(location = 2, component = 0) flat float fade;
		#endif
	#else
		layout(location = 0, component = 0) flat uint unorm4x8_tint;
	#endif

	#ifdef TEXTURED
		layout(location = 1, component = 0) vec2 coord;
	#endif
} v;
