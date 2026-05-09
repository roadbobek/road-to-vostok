shader_type spatial;

uniform sampler2D albedo : source_color, hint_default_white;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0, 0.1) = 0.75;

// Fragment ----------------------------------------

void fragment()
{
	// Sample textures
	vec4 color = texture(albedo, UV) * tint;
	
	// Output
	ALBEDO = color.rgb;
	SPECULAR = 0.5;
	ROUGHNESS = 0.25;
	ALPHA = opacity;
}