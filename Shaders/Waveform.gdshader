shader_type canvas_item;

const vec4 tint = vec4(0.0, 1.0, 0.25, 0.5);
const int lines = 80;
const float amplitude = 1.0;
const float frequency = 0.1;
const float intensity = 0.8;
const float spread = 0.5;
const float speed = 0.5;

float random(vec2 uv)
{
	return fract(sin(dot(uv.xy,vec2(12.9898,78.233))) * 43758.5453123);
}
float noise(vec2 uv)
{
	vec2 UVIndex = floor(uv);
	vec2 UVFract = fract(uv);
	float a = random(UVIndex);
	float b = random(UVIndex + vec2(1.0, 0.0));
	float c = random(UVIndex + vec2(0.0, 1.0));
	float d = random(UVIndex + vec2(1.0, 1.0));
	vec2 blur = smoothstep(0.0, 1.0, UVFract);
	return mix(a, b, blur.x) + (c - a) * blur.y * (1.0 - blur.x) + (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv)
{
	int octaves = 4;
	float amp = 0.5;
	float freq = 4.;
	float value = 0.0;
	
	for(int i = 0; i < octaves; i++) 
	{
		value += amp * noise(freq * uv - 0.5);
		amp *= 0.6;
		freq *= 2.;
	}
	return value;
}

void fragment()
{
	// Apply time
	float time = TIME;
	
	// Set cutoff
	float cutoff = smoothstep(0.0, spread, (round ((UV.x) * (float(lines)) ) / float(lines)));
	cutoff *= 1. - smoothstep(1.-spread, 1.0, (round ((UV.x) * (float(lines)) ) / float(lines)));

	// Set noise
	float noise = fbm(vec2( round( (UV.x) * float(lines)) * frequency, time * speed) );
	noise *= cutoff;

	// Set wave
	float wave = smoothstep(1.-intensity, 1.0, noise) * amplitude;
	wave = wave + (-0.2 * 0.2);

	// Set line
	float line = abs( sin((float(lines) * 3.1416 * UV.x) + 1.5));
	line = smoothstep(0.5, 1.0, line);

	// Set mask
	float mask = 1.0 - smoothstep(wave, wave + 0.1, abs(UV.y - 0.5) * 2.0);
	line *= mask;
	
	COLOR = vec4(line) * tint;
}