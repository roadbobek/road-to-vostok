shader_type spatial;
render_mode unshaded;

const float signal = 0.2;
const float distortion = 0.1;
const float resolution = 512.0;

// Noise function
float hash(vec2 p) 
{
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

void fragment() 
{
	// Calculate UV
	vec2 gridUV = floor(UV * resolution) / resolution;
	vec2 centerUV = gridUV - 0.5;
	vec2 warpedUV = gridUV + centerUV * dot(centerUV, centerUV) * distortion;
	
	// Calculate noise
	float t = floor(TIME * 10.0);
	float n1 = hash(warpedUV + t * 0.01);
	float n2 = hash(warpedUV * 0.5 - t * 0.02);
	float noise = smoothstep(0.0, 1.0, (n1 + n2));
	
	// Calculate effects
	float wave = sin(warpedUV.y * 2.0 + TIME * 0.3) * 0.5 + 0.5;
	float scanlines = sin(gridUV.y * resolution) * 0.1;
	float vignette = warpedUV.x * warpedUV.y * (1.0 - warpedUV.x) * (1.0 - warpedUV.y);
	vignette = pow(vignette, 0.5);
	
	// Combined color
	vec3 color = vec3(0.85, 0.95, 1.0) + (noise * signal + scanlines);
	color *= vignette;
	
	// Output
	ALBEDO = color;
}