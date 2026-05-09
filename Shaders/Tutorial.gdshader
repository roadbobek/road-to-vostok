shader_type spatial;

uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D text : source_color, filter_linear_mipmap_anisotropic;
global uniform sampler2D Specular : filter_linear_mipmap_anisotropic;

// Fragment ----------------------------------------

void fragment()
{
	// Sample
	vec3 color = texture(albedo, UV).rgb;
	vec3 info = texture(text, UV).rgb;
	float specular = texture(Specular, UV).r;

	// Output
	ALBEDO = color * info;
	SPECULAR = specular;
}