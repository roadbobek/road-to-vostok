shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform float opacity: hint_range(0.0, 4.0, 0.1) = 0.0;

void fragment()
{
	float r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * vec2(opacity,0)), 0.0).r;
	float g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * vec2(0,0)), 0.0).g;
	float b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * vec2(opacity,0)), 0.0).b;
	
	COLOR = vec4(r, g, b, 1.0);
}