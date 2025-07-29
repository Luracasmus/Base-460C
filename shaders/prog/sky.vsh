#include "/prelude/core.glsl"

uniform int renderStage;
uniform mat4 modelViewMatrix, projectionMatrix;

in vec3 vaPosition;
in vec4 vaColor;

out VertexData {
	layout(location = 0, component = 0) flat vec3 tint;
} v;

void main() {
	gl_Position = proj_mmul(projectionMatrix, rot_trans_mmul(modelViewMatrix, vaPosition));

	if (renderStage == MC_RENDER_STAGE_STARS) {
		// We skip reading the vertex attributes and writing the vertex parameters when we can, for performance
		v.tint = vaColor.rgb;
	}
}
