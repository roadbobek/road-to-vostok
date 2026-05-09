shader_type canvas_item;

uniform vec4 tint : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float intensity = 0.4;
uniform float opacity : hint_range(0.0, 1.0) = 0.5;
uniform sampler2D screen_vec : hint_screen_texture;

float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, intensity * opacity);
}

void fragment(){
	vec4 color = texture(screen_vec, SCREEN_UV);
	vec4 text = texture(TEXTURE, UV);

	text.rgba *= (tint.rgba);
	text.rgba *= (1.0 - vignette(UV));

	COLOR = vec4((text.rgb)*color.rgb,text.a);
}