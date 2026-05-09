shader_type spatial;

group_uniforms ____Main____;
uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap_anisotropic;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float tiling : hint_range(0.0, 1.0, 0.1) = 0.2;
uniform float roughness : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float metallic : hint_range(0.0, 1.0, 0.5) = 0.0;

group_uniforms ____Effects____;
uniform bool noise = false;
uniform bool dirt = false;
uniform bool occlusion = false;
uniform bool highlight = false;

uniform float dirtOpacity : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float dirtExposure : hint_range(0.0, 1.0, 0.1) = 1.0;
uniform float dirtSpread : hint_range(0.0, 1.0, 0.1) = 1.0;

// Globals & varyings
global uniform sampler2D Noise : filter_linear_mipmap_anisotropic;
global uniform sampler2D Dirt : source_color, filter_linear_mipmap_anisotropic;
global uniform sampler2D Specular : filter_linear_mipmap_anisotropic;
global uniform float Snow;
varying vec3 worldNormal;
varying vec3 worldPosition;

// Vertex ----------------------------------------
void vertex()
{
    worldNormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
    worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Fragment ----------------------------------------
void fragment()
{
	// Projection
	vec2 projection;
	if (abs(worldNormal).y > abs(worldNormal).x && abs(worldNormal).y > abs(worldNormal).z) { projection = worldPosition.xz; }
	else if (abs(worldNormal).x > abs(worldNormal).y && abs(worldNormal).x > abs(worldNormal).z) { projection = -worldPosition.zy; }
	else { projection = -worldPosition.xy; }

	// Planar mask
	vec3 absNormal = abs(worldNormal);
	float maxNormal = max(max(absNormal.x, absNormal.y), absNormal.z);
	float secondMax = max(min(absNormal.x, absNormal.y), min(max(absNormal.x, absNormal.y), absNormal.z));
	float transitionFactor = smoothstep(0.0, 1.0, maxNormal - secondMax);
	float planarMask = transitionFactor;

    // Sample textures
    vec3 color = texture(albedo, projection * tiling).rgb * tint;
    vec3 detail = texture(normal, projection * tiling).rgb;
    float specular = texture(Specular, projection * 0.2).r;

	// Effects
	if (noise)
	{
		float noiseLayer = texture(Noise, projection * 0.05).r;
		color *= mix(1.0, noiseLayer, 0.3);
	}
	if (dirt)
	{
		float dirtNoise = texture(Noise, projection * vec2(0.1, 0.02)).r;
		float dirtMask = mix(1.0, dirtNoise * dirtSpread, COLOR.r) * dirtOpacity;
		vec3 dirtLayer = texture(Dirt, projection * 0.2).rgb * tint;
		color = mix(color, dirtLayer * dirtExposure, dirtMask);
	}
	if (occlusion)
	{
		color *= mix(1.0, 0.8, (1.0 - COLOR.r));
	}
	if (highlight)
	{
		float highlightSize = 0.1;
		float highlightMask = smoothstep(0.0, highlightSize, UV.y) * smoothstep(0.0, highlightSize, 1.0 - UV.y);
		color *= mix(1.0, 1.4, 1.0 - highlightMask);
	}

	// Output
	ALBEDO = color;
	NORMAL_MAP_DEPTH = 1.0;
	NORMAL_MAP = detail;
	SPECULAR = specular;
	ROUGHNESS = roughness;
}