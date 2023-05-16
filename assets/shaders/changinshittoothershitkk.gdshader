shader_type canvas_item;
render_mode unshaded;

uniform vec4 wall_detect : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 wall_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform vec4 wall_border : source_color = vec4(0.7, 0.0, 0.0, 1.0);
uniform vec2 wall_tl_width = vec2(2, 2);
uniform vec2 wall_br_width = vec2(2, 10);
uniform float wall_offset = 10.0;
uniform int wall_pattern : hint_range(0, 2) = 1; // diamond, circle, square

uniform vec4 water_detect : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 water_color : source_color = vec4(0.0, 0.6, 1.0, 1.0);
uniform vec4 water_border : source_color = vec4(0.3, 0.3, 0.3, 1.0);
uniform vec2 water_tl_width = vec2(0, 10);
uniform vec2 water_br_width = vec2(0, 0);
uniform int water_pattern : hint_range(0, 2) = 2; // diamond, circle, square

uniform vec4 border : source_color = vec4(0.0, 0.0, 0.0, 0.4);
uniform vec2 border_tl_width = vec2(4, 4);
uniform vec2 border_br_width = vec2(4, 4);
uniform int border_pattern : hint_range(0, 2) = 1; // diamond, circle, square

#include "utils.gdshaderinc"

void fragment() {
	vec4 c = clr_at(SCREEN_UV);

	COLOR = c;
	vec2 uv = SCREEN_UV;
	
	bool skip = false;
	for (float i = 0.0; i <= wall_offset; i++) {
		if (color_approx_eq(clr_at(uv + vec2(0.0, SCREEN_PIXEL_SIZE.y * i)), wall_detect)) {
			skip = true;
			if (hasNonColorNeighbourWithUpOffset(uv, SCREEN_PIXEL_SIZE, wall_tl_width, wall_br_width, wall_pattern, wall_offset, wall_detect)) {
				COLOR = wall_border;
			} else {
				COLOR = wall_color;
			}
			break;
		}
	}
	
	if (!skip && c.a > 0.001) {
		COLOR = clr_at(uv);
		
		if (color_approx_eq(COLOR, wall_detect)) {
			if (hasNonColorNeighbourWithUpOffset(uv, SCREEN_PIXEL_SIZE, wall_tl_width, wall_br_width, wall_pattern, wall_offset, wall_detect)) {
				COLOR = wall_border;
			} else {
				COLOR = wall_color;
			}
		} else if (color_approx_eq(COLOR, water_detect)) {
			if (hasNonColorNeighbour(uv, SCREEN_PIXEL_SIZE, water_tl_width, water_br_width, water_pattern, water_detect)) {
				COLOR = water_border;
			} else {
				COLOR = water_color;
			}
		}
	} else {
		if (!skip && hasOpaqueNeighbour(uv, SCREEN_PIXEL_SIZE, border_tl_width, border_br_width, border_pattern)) {
			COLOR = border;
		}
	}
}