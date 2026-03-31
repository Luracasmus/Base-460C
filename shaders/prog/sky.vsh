#include "/prelude/core.glsl"

uniform int renderStage;

out
#include "/lib/v_data_generic.glsl"

void main() {
	gl_Position = proj_mmul(mat4(gl_ProjectionMatrix), rot_trans_mmul(mat4(gl_ModelViewMatrix), vec3(gl_Vertex)));

	if (renderStage == MC_RENDER_STAGE_STARS) {
		// We skip reading the vertex attributes and writing the vertex parameters when we can, for performance
		v.unorm4x8_tint = packUnorm4x8(vec4(vec3(gl_Color), 0.0));
	}
}
