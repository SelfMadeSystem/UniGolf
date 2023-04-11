shader_type canvas_item;

uniform vec2 cell_size = vec2(64, 64);
uniform vec2 offset = vec2(0, 0);
uniform int width = 2;
uniform vec4 color : source_color;


void fragment() {
	vec2 uv = SCREEN_UV / SCREEN_PIXEL_SIZE - offset;
    vec2 grid = floor(uv / cell_size) * cell_size;
	vec2 diff = uv - grid;
	if (diff.x <= float(width) || diff.y <= float(width)) {
		COLOR = color;
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}