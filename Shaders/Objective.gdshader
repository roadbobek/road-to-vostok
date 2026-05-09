shader_type spatial;
render_mode shadows_disabled;

const float occlusion = 0.5;
const float spherical = 1.0;
global uniform sampler2D Specular : filter_linear_mipmap;

void fragment()
{
	// Spherical lens ----------------------------------------

	vec2 uv_center = UV - vec2(0.5);
	uv_center *= spherical;
	uv_center.y = -uv_center.y;
	float r2 = dot(uv_center, uv_center);
	float z = sqrt(1.0 - r2);
	vec3 normal = normalize(vec3(uv_center.x, uv_center.y, z));
	NORMAL_MAP = normal * 0.5 + 0.5;

	// Occlusion ----------------------------------------

	float edge = smoothstep(occlusion - 0.15, occlusion, length(UV - 0.5));
	edge = 1.0 - edge;

	// Reflection ----------------------------------------

	float specular = texture(Specular, UV).r;

	// Output ----------------------------------------

	ALBEDO = vec3(0.0);
	ROUGHNESS = 0.1 + specular;
	SPECULAR = 0.4 * edge;
}