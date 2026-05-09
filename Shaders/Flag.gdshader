shader_type spatial;
render_mode cull_disabled;

uniform sampler2D albedo : filter_linear_mipmap;
uniform sampler2D normal : filter_linear_mipmap;
uniform sampler2D noise : filter_linear_mipmap;
uniform vec3 tint : source_color = vec3(1.0);
const vec2 UVOffset = vec2(-0.1, -0.1);
const vec2 timeScale = vec2(0.1, 0.0);
uniform float distortion : hint_range(0.0, 2.0, 0.1) = 1.0;

void vertex()
{
	vec2 offset = UV * UVOffset;
	offset += TIME * timeScale;

	float displacement = texture(noise, offset).r;
	float textureOffset = displacement * 2.0 - 1.0;
	textureOffset *= UV.x;

	VERTEX.y += textureOffset;
	VERTEX.z += textureOffset * distortion;
	VERTEX.x += textureOffset * -distortion;
}

void fragment()
{
	vec2 offset = UV * UVOffset;
	offset += TIME * timeScale;
	float displacement = texture(noise, offset).r;

	// Sample
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	vec3 detail = texture(normal, UV + displacement).rgb;
	
	ALBEDO = color;
	ROUGHNESS = 0.5;
	SPECULAR = 0.1;
	BACKLIGHT = vec3(0.2);
	NORMAL_MAP = detail;
	NORMAL_MAP_DEPTH = 0.5;
}