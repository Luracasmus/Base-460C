#include "/prelude/core.glsl"

uniform int renderStage;

out VertexData {
	layout(location = 0, component = 0) flat vec3 tint;
} v;

void main() {
	gl_Position = proj_mmul(mat4(gl_ProjectionMatrix), rot_trans_mmul(mat4(gl_ModelViewMatrix), vec3(gl_Vertex)));

	if (renderStage == MC_RENDER_STAGE_STARS) {
		// We skip reading the vertex attributes and writing the vertex parameters when we can, for performance
		v.tint = vec3(gl_Color);
	}
}
