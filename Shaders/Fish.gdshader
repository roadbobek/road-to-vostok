shader_type spatial;

group_uniforms ____Main____;
uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);

// Uniforms for S-curve animation
group_uniforms ____Animation____;
uniform bool swim = false;
uniform float amplitude : hint_range(0.0, 1.0) = 0.1;
uniform float frequency : hint_range(0.0, 10.0) = 5.0;
uniform float speed : hint_range(0.0, 20.0) = 10.0;
uniform float length_scale : hint_range(0.1, 1.0) = 0.5;

void vertex()
{
	if (swim)
	{
		float time = TIME;
		float z_pos = VERTEX.z;
		float x_pos = VERTEX.x;
		float influence = pow(abs(z_pos) / length_scale, 2.0);
		influence = clamp(influence, 0.1, 1.0);
		float normalized_z = z_pos / length_scale + 0.5;
		float wave = sin(normalized_z * frequency + time * speed) * amplitude * influence;
		float asym_wave = sin(normalized_z * frequency * 1.3 + time * speed * 0.8 + 1.0) * 0.0 * (x_pos / length_scale);
		VERTEX.x += wave + asym_wave;
	}
}

void fragment()
{
	// Sample textures
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	vec3 detail = texture(normal, UV).rgb;

	// Output
	ALBEDO = color;
	NORMAL_MAP = detail;
	METALLIC = 0.5;
	ROUGHNESS = 0.5;
	SPECULAR = 0.5;
}