shader_type canvas_item;

uniform int rotation = 0;
uniform vec2 offset = vec2(0.0, 0.0);

uniform sampler2D sprite;
uniform float sprite_size = 64.0;

vec2 get_coords(vec2 uv, vec2 sps) {
	switch ((rotation + 1) % 4) {
		case 1:
			uv = vec2(1.0 - uv.y - sprite_size * 0.5 * sps.y, uv.x);
			break;
		case 2:
			uv = vec2(1.0 - uv.x, 1.0 - uv.y - sprite_size * 0.5 * sps.y);
			break;
		case 3:
			uv = vec2(uv.y, 1.0 - uv.x);
			break;
	}
	return uv;
}

vec2 aaaa(vec2 sps) {
	switch ((rotation + 1) % 2) {
		case 0:
			return sps;
		case 1:
			return vec2(sps.y, sps.x);
	}
	return vec2(0, 0);
}

void fragment() {
	vec2 coords = (get_coords(SCREEN_UV - offset * SCREEN_PIXEL_SIZE, SCREEN_PIXEL_SIZE) / aaaa(SCREEN_PIXEL_SIZE)) / sprite_size;
	coords = mod(coords, 1.0);
	COLOR = texture(sprite, coords);
}
