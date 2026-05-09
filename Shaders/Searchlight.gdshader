shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D depthTexture : hint_depth_texture, filter_linear_mipmap;

uniform sampler2D noise : filter_linear_mipmap;
uniform float silhuette : hint_range(0.1, 20.0) = 20.0;
uniform float startFade : hint_range(0.1, 1.0) = 1.0;
uniform float endFade: hint_range(0.1, 1.0) = 1.0;
uniform vec2 noiseSpeed = vec2(0.1, 0.1);
uniform vec2 noiseScale = vec2(0.2, 0.2);
uniform bool depthFade = true;
uniform float depthFadeDistance : hint_range(1.0, 10.0) = 10.0;

varying vec3 vertexView;
varying vec3 vertexPosition;
varying vec3 cylinderView;

float linearDepth(float rawDepth, mat4 matrix) 
{
	return 1.0 / (rawDepth * matrix[2][3] + matrix[3][3]);
}

void vertex()
{
	vertexView = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertexPosition = VERTEX;
	cylinderView = (MODELVIEW_MATRIX * vec4(0.0, 1.0, 0.0, 0.0)).xyz;
	POSITION = PROJECTION_MATRIX * vec4(vertexView, 1.0);
}

void fragment()
{
	float dist = length(vertexView);
	vec3 N = normalize(NORMAL);
	vec3 V = normalize(-vertexView);
	float NdotV = max(0.0, dot(N, V));
	
	// Calculate alpha
	float alphaSilhuette = pow(NdotV, silhuette);
	float alphaStart = pow(UV.y, startFade);
	float alphaEnd = pow(1.0 - UV.y, endFade);
	float combinedAlpha = alphaSilhuette * alphaEnd * alphaStart;

	// Cylindrical mapping
	float angle = atan(vertexPosition.x, vertexPosition.z);
	float u = (angle / (2.0 * 3.14159265)) + 0.5;
	float v = vertexPosition.y;
	
	// Calculate noise
	vec2 UVAnimated = vec2(u, v) * noiseScale + TIME * noiseSpeed;
	float blendFactor = smoothstep(0.0, 1.0, u);
	float noise1 = texture(noise, UVAnimated).g;
	float noise2 = texture(noise, UVAnimated - vec2(1.0 * noiseScale.x, 0.0)).g;
	float combinedNoise = mix(noise1, noise2, blendFactor);
	
	// Calculate depth
	float depthMultiply = 1.0;
	if (depthFade) {
		float sceneDepth = texture(depthTexture, SCREEN_UV).r;
		if (sceneDepth < 0.9999) {
			float sceneLinear = linearDepth(sceneDepth, INV_PROJECTION_MATRIX);
			float fragLinear = -vertexView.z;
			float diff = sceneLinear - fragLinear;
			depthMultiply = smoothstep(0.0, depthFadeDistance, diff);
		}
	}
	
	// Combine to alpha
	float alpha = combinedAlpha * combinedNoise * depthMultiply;
	
	// Output
	ALBEDO = vec3(1.0, 1.0, 1.0);
	ALPHA = clamp(alpha, 0.0, 1.0);
}