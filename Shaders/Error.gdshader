shader_type canvas_item;

uniform float thickness : hint_range(0.0, 100.0) = 2.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.2;
const vec3 tint = vec3(1.0, 0.0, 0.0);

void fragment() 
{
	// Calculate UV rate
	vec2 UVRate = vec2(length(vec2(dFdx(UV.x), dFdy(UV.x))), length(vec2(dFdx(UV.y), dFdy(UV.y))));
	
	// Calculate distance
	vec2 distanceToEdge = min(UV, 1.0 - UV);
	vec2 distanceInPixels = distanceToEdge / UVRate;
	float edgeDistance = min(distanceInPixels.x, distanceInPixels.y);
	float border = 1.0 - smoothstep(thickness - 1.0, thickness, edgeDistance);

	COLOR = vec4(tint, border * intensity);
}