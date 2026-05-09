shader_type canvas_item;

// The screen texture sampler for post-processing
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

group_uniforms ____Resolution____;
uniform vec2 resolution = vec2(1920, 1080);

group_uniforms ____Roll____;
uniform bool roll = true;
uniform float rollSpeed = 1.0;
uniform float rollTiling = 50.0;
uniform float rollDistort = 0.001;

group_uniforms ____Noise____;
uniform float noiseLines = 0.1;
uniform float noiseStatic = 0.1;

group_uniforms ____Color____;
uniform bool discolor = true;
uniform float aberration = 0.001;
uniform float brightness = 1.5;

group_uniforms ____Edges____;
uniform float warpAmount = 2.0;
uniform float vignetteAmount = 0.5;
uniform float vignetteOpacity = 1.0;

// Utility ----------------------------------------

vec2 random(vec2 uv)
{
	uv = vec2(dot(uv, vec2(127.1, 311.7)), dot(uv, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv)
{
	vec2 i = floor(uv);
	vec2 f = fract(uv);
	vec2 u = smoothstep(0.0, 1.0, f);
	return mix(mix(dot(random(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
			dot(random(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
		mix(dot(random(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
			dot(random(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

vec2 warp(vec2 uv)
{
	vec2 center = uv - 0.5;
	float combined = dot(center, center);
	float final = combined * combined;
	return uv + center * final * (warpAmount * 0.01); 
}

float vignette(vec2 uv)
{
	uv *= 1.0 - uv.xy;
	float v = uv.x * uv.y * 15.0; // Multiplier from your reference
	return pow(v, vignetteAmount * vignetteOpacity);
}

float border(vec2 uv)
{
	float radius = min(warpAmount * 0.01, 0.08);
	radius = max(min(min(abs(radius * 2.0), 1.0), 1.0), 1e-5);
	vec2 absUV = abs(uv * 2.0 - 1.0) - vec2(1.0) + radius;
	float dist = length(max(vec2(0.0), absUV)) / radius;
	return clamp(1.0 - smoothstep(0.95, 1.0, dist), 0.0, 1.0);
}

// Fragment ----------------------------------------

void fragment()
{
	// We use SCREEN_UV for the pixel sampling (the "warped" look)
	vec2 warped_screen_uv = warp(SCREEN_UV);
	
	vec2 rollUV = vec2(0.0);
	float time = roll ? TIME : 0.0;
	float rollLine = 0.0;
	vec4 color;

	if (roll || noiseLines > 0.0)
	{
		rollLine = smoothstep(0.3, 0.9, sin(warped_screen_uv.y * rollTiling - time * rollSpeed));
		rollLine *= rollLine * smoothstep(0.3, 0.9, sin(warped_screen_uv.y * rollTiling - time * rollSpeed));
		rollUV = vec2((rollLine * rollDistort * (1.0 - SCREEN_UV.x)), 0.0);
	}

	if (roll)
	{
		color.r = texture(screen_texture, warped_screen_uv + rollUV * 0.8 + vec2(aberration, 0.0) * 0.1).r;
		color.g = texture(screen_texture, warped_screen_uv + rollUV * 1.2 - vec2(aberration, 0.0) * 0.1).g;
		color.b = texture(screen_texture, warped_screen_uv + rollUV).b;
		color.a = 1.0;
	}
	else
	{
		color.r = texture(screen_texture, warped_screen_uv + vec2(aberration, 0.0) * 0.1).r;
		color.g = texture(screen_texture, warped_screen_uv - vec2(aberration, 0.0) * 0.1).g;
		color.b = texture(screen_texture, warped_screen_uv).b;
		color.a = 1.0;
	}

	float r = color.r;
	float g = color.g;
	float b = color.b;
	color.r = clamp(r * brightness, 0.0, 1.0);
	color.g = clamp(g * brightness, 0.0, 1.0);
	color.b = clamp(b * brightness, 0.0, 1.0);

	if (noiseLines > 0.0)
	{
		float n = smoothstep(0.4, 0.5, noise(warped_screen_uv * vec2(2.0, 200.0) + vec2(10.0, time)));
		rollLine *= n * clamp(random((ceil(warped_screen_uv * resolution) / resolution) + vec2(time * 0.8, 0.0)).x + 0.8, 0.0, 1.0);
		color.rgb = clamp(mix(color.rgb, color.rgb + rollLine, noiseLines), vec3(0.0), vec3(1.0));
	}

	if (noiseStatic > 0.0)
	{
		color.rgb += clamp(random((ceil(warped_screen_uv * resolution) / resolution) + fract(time)).x, 0.0, 1.0) * noiseStatic;
	}

	// KEY CHANGE: Use standard UV for borders and vignette so they stay tied to the screen edges
	color.rgb *= border(UV);
	color.rgb *= vignette(UV);

	if (discolor)
	{
		vec3 grey = vec3(dot(color.rgb, vec3(0.333)));
		color.rgb = mix(color.rgb, grey, 0.5);
		color.rgb = (color.rgb - vec3(0.5)) * 1.2 + vec3(0.5);
	}

	COLOR = color;
}