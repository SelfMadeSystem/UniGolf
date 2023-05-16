uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

vec4 clr_at(vec2 uv) {
	vec4 c = textureLod(screen_texture, uv, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	
	return c;
}

bool color_approx_eq(vec4 a, vec4 b) {
	float epsilon = 0.001;
	return abs(a.r - b.r) <= epsilon &&
	abs(a.g - b.g) <= epsilon &&
	abs(a.b - b.b) <= epsilon &&
	abs(a.a - b.a) <= epsilon;
}

void _get_min_max_y(float x,
					float min_x,
					float max_x,
					vec2 tl_width,
					vec2 br_width,
					int pattern,
					out float min_y,
					out float max_y) {
	float aaa = x < 0.0 ? -min_x : max_x;
	
	if (pattern == 0) {
		float a = (aaa - abs(x)) / aaa;
		min_y = a * tl_width.y;
		max_y = a * br_width.y;
	} else if (pattern == 1) {
		aaa += 0.25;
		float z = sqrt(aaa * aaa - x * x) / aaa;
		min_y = floor(z * tl_width.y);
		max_y = floor(z * br_width.y);
	} else if (pattern == 2) {
		min_y = tl_width.y;
		max_y = br_width.y;
	}
}

bool hasTransparentNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 tl_width, vec2 br_width, int pattern) {
	float min_x = -ceil(tl_width.x);
	float max_x = ceil(br_width.x);
	for (float x = min_x; x <= max_x; x++) {
		float min_y;
		float max_y;
		
		_get_min_max_y(x, min_x, max_x, tl_width, br_width, pattern, min_y, max_y);
		
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

bool hasOpaqueNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 tl_width, vec2 br_width, int pattern) {
	float min_x = -ceil(tl_width.x);
	float max_x = ceil(br_width.x);
	for (float x = min_x; x <= max_x; x++) {
		float min_y;
		float max_y;
		
		_get_min_max_y(x, min_x, max_x, tl_width, br_width, pattern, min_y, max_y);
		
		min_y = -ceil(min_y);
		max_y = ceil(max_y);
		
		for (float y = min_y; y <= max_y; y++) {
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if (clr_at(xy).a > 0.001) {
				return true;
			}
		}
	}
	
	return false;
}

bool hasNonColorNeighbour(vec2 uv, vec2 texture_pixel_size, vec2 tl_width, vec2 br_width, int pattern, vec4 color) {
	float min_x = -ceil(tl_width.x);
	float max_x = ceil(br_width.x);
	for (float x = min_x; x <= max_x; x++) {
		float min_y;
		float max_y;
		
		_get_min_max_y(x, min_x, max_x, tl_width, br_width, pattern, min_y, max_y);
		
		min_y = -ceil(min_y);
		max_y = ceil(max_y);
		
		for (float y = min_y; y <= max_y; y++) {
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if (!color_approx_eq(clr_at(xy), color)) {
				return true;
			}
		}
	}
	
	return false;
}

bool hasNonColorNeighbourWithUpOffset(vec2 uv,
									vec2 texture_pixel_size,
									vec2 tl_width,
									vec2 br_width,
									int pattern,
									float offset,
									vec4 color) {
	float min_x = -ceil(tl_width.x);
	float max_x = ceil(br_width.x);
	for (float x = min_x; x <= max_x; x++) {
		float min_y;
		float max_y;
		
		_get_min_max_y(x, min_x, max_x, tl_width, br_width, pattern, min_y, max_y);
		
		min_y = -ceil(min_y);
		max_y = ceil(max_y);
		
		for (float y = max_y; y >= min_y; y--) {
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if (!color_approx_eq(clr_at(xy), color) &&
			!color_approx_eq(clr_at(xy + vec2(0, offset - tl_width.y) * texture_pixel_size * 0.2), color) &&
			!color_approx_eq(clr_at(xy + vec2(0, offset - tl_width.y) * texture_pixel_size * 0.4), color) &&
			!color_approx_eq(clr_at(xy + vec2(0, offset - tl_width.y) * texture_pixel_size * 0.6), color) &&
			!color_approx_eq(clr_at(xy + vec2(0, offset - tl_width.y) * texture_pixel_size * 0.6), color) &&
			!color_approx_eq(clr_at(xy + vec2(0, offset - tl_width.y) * texture_pixel_size * 0.8), color) &&
			!color_approx_eq(clr_at(xy + vec2(0, offset - tl_width.y) * texture_pixel_size * 1.0), color)
			) {
				if ((y >= 0.0)) {
					return true;
				}
			}
		}
	}
	
	return false;
}