#version 460 core

/*
	// Clear needs to be enabled in dimensions where the sky geometry isn't rendered, such as the nether
	// We currently don't disable it in any dimension, even though it should be safe in the overworld and the end,
	// as it would make the shader pack too complex, and possibly risk breaking some mods
	const bool colortex0Clear = true;
	const int colortex0Format = RGB8;
*/

#ifdef MC_GL_VENDOR_NVIDIA
	#define immut const
#else
	// We don't trust all other drivers to accept 'const' on immutable variables that aren't constant at compile time,
	// even though it is allowed in GLSL 4.20+
	#define immut
#endif

// Specialized efficient matrix multiplication functions

vec2 rot_trans_mmul(mat4 rot_trans_mat, vec2 vec) {
	return mat2(rot_trans_mat) * vec + rot_trans_mat[3].xy;
}

vec3 rot_trans_mmul(mat4 rot_trans_mat, vec3 vec) {
	return mat3(rot_trans_mat) * vec + rot_trans_mat[3].xyz;
}

vec4 proj_mmul(mat4 proj_mat, vec3 view) {
	return vec4(
		vec2(proj_mat[0].x, proj_mat[1].y) * view.xy,
		fma(proj_mat[2].z, view.z, proj_mat[3].z),
		proj_mat[2].w * view.z
	);
}

vec3 proj_inv(mat4 inv_proj_mat, vec3 ndc) {
	immut vec4 view_undiv = vec4(
		vec2(inv_proj_mat[0].x, inv_proj_mat[1].y) * ndc.xy,
		inv_proj_mat[3].z,
		fma(inv_proj_mat[2].w, ndc.z, inv_proj_mat[3].w)
	);

	return view_undiv.xyz / view_undiv.w;
}
