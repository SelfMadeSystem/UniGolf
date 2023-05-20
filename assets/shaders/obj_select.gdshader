shader_type canvas_item;
render_mode unshaded;

uniform float dash_size = 8.0;
uniform float dash_speed = 32.0;
uniform float line_width = 4.0;
uniform vec2 pos = vec2(0.0, 0.0);
uniform vec2 end = vec2(200.0, 200.0);

float owo(float a, float m) {
	return mod(a + TIME * dash_speed * m, dash_size * 2.0) > dash_size ? 0.0 : 1.0;
}

void fragment() {
	vec2 pixel_coords = SCREEN_UV / SCREEN_PIXEL_SIZE;
	if (pixel_coords.x < pos.x + line_width * 0.5) {
		COLOR.a = owo(pixel_coords.y, 1.0);
	} else if (pixel_coords.x > end.x - line_width * 0.5) {
		COLOR.a = owo(pixel_coords.y, -1.0);
	} else if (pixel_coords.y < pos.y + line_width * 0.5) {
		COLOR.a = owo(pixel_coords.x, -1.0);
	} else {
		COLOR.a = owo(pixel_coords.x, 1.0);
	}
}
