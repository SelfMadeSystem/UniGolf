shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 color : source_color = vec4(1.0);
uniform vec2 tl_width = vec2(4, 4);
uniform vec2 br_width = vec2(4, 10);
uniform int pattern : hint_range(0, 2) = 1; // diamond, circle, square

vec4 clr_at(vec2 uv) {
	vec4 c = textureLod(screen_texture, uv, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	
	return c;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size) {
	float min_x = -ceil(tl_width.x);
	float max_x = ceil(br_width.x);
	for (float x = min_x; x <= max_x; x++) {
		float min_y;
		float max_y;
		
		float aaa = x < 0.0 ? -min_x : max_x;
		
		if (pattern == 0) {
			float a = (aaa - abs(x)) / aaa;
			min_y = a * tl_width.y;
			max_y = a * br_width.y;
		} else if (pattern == 1) {
			float z = sqrt(aaa * aaa - x * x) / aaa;
			float a = tl_width.y + 0.5;
			float b = br_width.y + 0.5;
			min_y = floor(z * a);
			max_y = floor(z * b);
		} else if (pattern == 2) {
			min_y = tl_width.y;
			max_y = br_width.y;
		}
		
		min_y = -ceil(min_y);
		max_y = ceil(max_y);
		
		for (float y = min_y; y <= max_y; y++) {
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if (clr_at(xy).a < 0.0001) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec4 c = clr_at(SCREEN_UV);

	COLOR = c;
	
	if (c.a > 0.001) {
		vec2 uv = SCREEN_UV;
	
		COLOR = clr_at(uv);
		
		if (hasContraryNeighbour(uv, SCREEN_PIXEL_SIZE)) {
			COLOR.rgb = mix(COLOR.rgb, color.rgb, color.a);
			COLOR.a += (1.0 - COLOR.a) * color.a;
		}
	}
}