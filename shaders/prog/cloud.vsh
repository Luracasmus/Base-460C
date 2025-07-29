#version 460 compatibility

out VertexData {
	layout(location = 0, component = 0) vec4 tint;
} v;

void main() {
	// The code that 'ftransform()' gets transformed into in 'gbuffers_clouds.vsh' is currently impossible to implement in the core profile
	gl_Position = ftransform();

	v.tint = gl_Color;
}
