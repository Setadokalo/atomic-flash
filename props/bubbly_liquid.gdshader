shader_type canvas_item;

uniform sampler2D bubbly_liquid: repeat_enable, filter_nearest;
uniform vec3 cutout_color: source_color;

varying vec2 vert;
varying vec4 modulate;

void vertex() {
	vert = VERTEX;
	modulate = COLOR;
	// Called for every vertex the material is visible on.
}

float stepped(float val, float stp) {
	return floor(val / stp) * stp;
}

void fragment() {
	COLOR = COLOR;
	vec3 color = texture(TEXTURE, UV).rgb;
	if (length(color - cutout_color) < 0.01) {
		vec2 uv = UV;
		uv.x = uv.x * 4.0 - floor(uv.x * 4.0);
		vec2 vertexScale = vec2(128.0 / 32.0, 208.0 / 64.0);
		uv = uv * vertexScale;
		vec2 offset = vec2(stepped(sin(stepped(uv.y, 1.0 / 64.0) * 8.0) * 0.2, 1.0 / 32.0), stepped(TIME * 0.15, 1.0 / 64.0));
		COLOR = texture(bubbly_liquid, uv + offset) * modulate;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
