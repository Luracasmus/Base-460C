#version 460 compatibility

out
#include "/lib/v_data_generic.glsl"

void main() {
	// The code that 'ftransform()' gets transformed into in 'gbuffers_clouds.vsh' is currently impossible to implement in the core profile
	gl_Position = ftransform();

	v.unorm4x8_tint = packUnorm4x8(vec4(gl_Color));
}
