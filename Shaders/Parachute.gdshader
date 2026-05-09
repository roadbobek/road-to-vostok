shader_type spatial;

uniform sampler2D albedo : source_color, filter_linear_mipmap;
uniform sampler2D normal : hint_normal, filter_linear_mipmap;
uniform float progress : hint_range(-1.0, 2.0) = -1.0;

const float windLowIntensity = 0.2;
const float windHighIntensity = 0.5;
const float windSpeed = 10.0;

void vertex() 
{
	// Isolate factors
	float openingFactor = clamp(progress, -1.0, 0.0) + 1.0;
	float releaseFactor = clamp(progress, 0.0, 1.0);
	
	// Open scaling
	VERTEX = mix(vec3(0.0), VERTEX, openingFactor);
	
	// Release scaling
	vec3 center = vec3(0.0, VERTEX.y, 0.0);
	VERTEX.xz = mix(VERTEX.xz, center.xz, releaseFactor);
	VERTEX.y += releaseFactor * 20.0;
	
	// Wind parameters
	vec3 worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float wind = sin(TIME * windSpeed + dot(worldPosition.xz, vec2(1.0, 0.0)));
	float height = worldPosition.y;
	float highThreshold = 200.0;
	float lowThreshold = 100.0;
	
	// Wind intensity
	float windIntensity;
	float t = clamp((height - lowThreshold) / (highThreshold - lowThreshold), 0.0, 1.0);
	windIntensity = mix(windLowIntensity, windHighIntensity, t);
	
	// Apply wind
	float windBoost = 1.0 + (releaseFactor * 5.0);
	float heightFactor = clamp(VERTEX.y - 2.0, 0.0, 1.0);
	VERTEX.y += wind * windIntensity * heightFactor * windBoost;
}

void fragment() 
{
	// Sample
	vec3 color = texture(albedo, UV).rgb;
	vec3 detail = texture(normal, UV).rgb;
	
	// Output
	ALBEDO = color;
	NORMAL_MAP = detail;
	SPECULAR = 0.5;
	ROUGHNESS = 0.5;
}