shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform vec4 color : source_color = vec4(1.0);
uniform float width : hint_range(0, 10) = 1.0;
uniform int pattern : hint_range(0, 2) = 1; // diamond, circle, square
uniform bool inside = true;
uniform bool add_margins = false; // only useful when inside is false

vec4 clr_at(vec2 uv) {
	vec4 c = textureLod(screen_texture, uv, 0.0);
	
	if (c.a > 0.0001) {
		c.rgb /= c.a;
	}
	
	return c;
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) {
		float x = abs(i) > width ? width * sign(i) : i;
		float offset;
		
		if (pattern == 0) {
			offset = width - abs(x);
		} else if (pattern == 1) {
			offset = floor(sqrt(pow(width + 0.5, 2) - x * x));
		} else if (pattern == 2) {
			offset = width;
		}
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) {
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a == 0.0) == inside) {
				return true;
			}
		}
	}
	
	return false;
}

void fragment() {
	vec4 c = clr_at(SCREEN_UV);

	COLOR = c;
	
	if (true || c.a < 0.001) {
		vec2 uv = SCREEN_UV;
	
		if (add_margins) {
			vec2 texture_pixel_size = SCREEN_PIXEL_SIZE;
			
			uv = (uv - texture_pixel_size * width);
			
			if (uv != clamp(uv, vec2(0.0), vec2(1.0))) {
				COLOR.a = 0.0;
			} else {
				COLOR = clr_at(uv);
			}
		} else {
			COLOR = clr_at(uv);
		}
		
		if ((COLOR.a > 0.0) == inside && hasContraryNeighbour(uv, SCREEN_PIXEL_SIZE, screen_texture)) {
			COLOR.rgb = inside ? mix(COLOR.rgb, color.rgb, color.a) : color.rgb;
			COLOR.a += (1.0 - COLOR.a) * color.a;
		}
	}
}