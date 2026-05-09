shader_type spatial;
render_mode diffuse_lambert_wrap;

group_uniforms ____Main____;
uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 2.0, 0.1) = 1.0;

// Fragment ----------------------------------------

void fragment()
{
	// Sample textures
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	float alpha = texture(albedo, UV).a;

	// Output
	ALBEDO = color;
	SPECULAR = 0.1;
	ROUGHNESS = 0.5;
	ALPHA = alpha * opacity;
}