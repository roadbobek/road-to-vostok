shader_type spatial;
render_mode unshaded, cull_disabled, specular_disabled, shadows_disabled, fog_disabled;

uniform vec3 tint : source_color = vec3(0.0, 1.0, 0.0);
uniform sampler2D alpha : source_color, filter_linear_mipmap;
uniform sampler2D noise : filter_linear_mipmap;
uniform bool point = false;

void fragment() 
{
	// Calculate scatter and opacity
	vec2 scatterUV = SCREEN_UV * 2.0 + TIME * 0.01;
	float scatter = texture(noise, scatterUV).r;
	float opacity = texture(alpha, UV).r;
	
	// Set intensity
	float intensity = point ? 10000.0 : 1.0;
	
	// Output
	ALBEDO = tint.rgb * intensity;
	ALPHA = opacity * scatter;
}