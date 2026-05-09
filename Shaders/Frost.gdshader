shader_type canvas_item;

uniform sampler2D frost : repeat_enable, filter_linear;
uniform float intensity : hint_range(0.0, 1.0) = 1.0;
uniform float scale : hint_range(1.0, 1000.0) = 500.0;
const vec3 tint = vec3(0.3, 0.4, 0.5);

void fragment() 
{
	// Sample noises
	vec2 noiseUV = FRAGCOORD.xy / scale;
	float noise1 = texture(frost, noiseUV).r;
	
	// Set vignette
	float vignette = distance(UV, vec2(0.5));
	float mask = smoothstep(0.0, 1.0, vignette);
	
	// Output
	COLOR = vec4(tint * noise1, intensity * mask);
}