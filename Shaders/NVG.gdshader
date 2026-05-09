shader_type canvas_item;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear_mipmap;

uniform vec4 tint : source_color;
uniform float noise : hint_range(0, 100.0, 1.0) = 10.0;
uniform float vignette : hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float goggleSeparation : hint_range(0.0, 1.0, 0.1) = 0.4;
uniform float goggleSize : hint_range(0.0, 1.0, 0.1) = 0.8;
uniform float goggleAspect : hint_range(0.0, 2.0, 0.1) = 1.6;
uniform float goggleOutline : hint_range(0.0, 0.1, 0.01) = 0.05;

float Goggles(vec2 uv) 
{
	vec2 centerUV = (uv * 2.0 - 1.0);
	centerUV.x *= goggleAspect;
	vec2 G1Center = vec2(-goggleSeparation * goggleAspect, 0.0);
	float G1Distance = length(centerUV - G1Center);
	vec2 G2Center = vec2(goggleSeparation * goggleAspect, 0.0);
	float G2Distance = length(centerUV - G2Center);
	float goggles = min(G1Distance, G2Distance);
	return goggles;
}

void fragment() 
{
	// Get pixel color
	vec4 pixelColor = texture(screen_texture, SCREEN_UV);
	
	// Calculate goggles
	float goggleMask = smoothstep(goggleSize + vignette, goggleSize, Goggles(UV));
	float goggleOutlines = 1.0 - smoothstep(goggleSize - goggleOutline, goggleSize, Goggles(UV));
	
	// Apply noise
	vec2 uv = SCREEN_UV;
	float x = (uv.x + 1.0) * (uv.y + 1.0) * (TIME * 10.0);
	vec4 noiseEffect = vec4(mod((mod(x, 13.0)) * (mod(x, 123.0)), 0.01) - 0.005) * noise;
	
	// Calculate color with noise
	vec4 color = pixelColor * tint;
	color += noiseEffect;
	
	// Apply goggle outlines
	color.rgb *= (1.0 + goggleOutlines);
	
	// Output
	COLOR = mix(vec4(0.0, 0.0, 0.0, 1.0), color, goggleMask);
}