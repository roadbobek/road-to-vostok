shader_type canvas_item;

uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;
uniform float sharpness : hint_range(0.0, 2.0, 0.05) = 1.0;

void fragment() 
{
	// Get size & UV
	vec2 size = vec2(textureSize(screenTexture, 0));
	vec2 screenUV = SCREEN_UV;
	
	// Sharpening filter
	vec3 center = texture(screenTexture, screenUV).rgb;
	vec3 left   = texture(screenTexture, screenUV + vec2(-1.0, 0.0) / size).rgb;
	vec3 right  = texture(screenTexture, screenUV + vec2(1.0, 0.0) / size).rgb;
	vec3 up     = texture(screenTexture, screenUV + vec2(0.0, -1.0) / size).rgb;
	vec3 down   = texture(screenTexture, screenUV + vec2(0.0, 1.0) / size).rgb;
	vec3 blurred = (left + right + up + down) * 0.25;
	vec3 result = center + (center - blurred) * sharpness;
	
	// Output
	COLOR = vec4(result, 1.0);
}