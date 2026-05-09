shader_type spatial;

uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap;

// Globals
global uniform float Wind;

void vertex()
{
	float displacement = 4.0;
	float UVx = UV.x;
	float windDisplacement = displacement * UVx * (1.0 - UVx);
	float windEffect = mix(0.1, 1.0, Wind);
	float windOffset = sin(TIME * 2.0 + UVx * 5.0) * windDisplacement * windEffect;
	vec3 windOutput = vec3(0.1, 0.1, 0.1) * windOffset;
	VERTEX += windOutput;
}

void fragment()
{
	ALBEDO = vec3(0.02, 0.02, 0.02);
	NORMAL = vec3(0.0, 1.0, 0.0);
	ROUGHNESS = 1.0;
	SPECULAR = 0.0;
}