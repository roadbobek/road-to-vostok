shader_type spatial;
render_mode shadows_disabled, cull_front;

group_uniforms Main;
uniform vec3 color : source_color;

group_uniforms Waves;
uniform sampler2D waveA : filter_linear_mipmap_anisotropic;
uniform sampler2D waveB : filter_linear_mipmap_anisotropic;
uniform float waveIntensity : hint_range(0.0, 2.0, 0.1) = 2.0;
uniform float waveSpeed : hint_range(0.0, 1.0, 0.1) = 0.2;

// Varyings
varying vec3 worldCamera;
varying vec3 worldVertex;

// Vertex ----------------------------------------

void vertex()
{
	worldCamera = (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz;
	worldVertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

// Fragment ----------------------------------------

void fragment()
{
	// Calculate normals & vectors
	vec2 normalDirection = vec2(waveSpeed, waveSpeed) / 10.0;
	vec2 waveVector1 = (TIME * -normalDirection);
	vec2 waveVector2 = (TIME * normalDirection / 2.0);
	vec2 baseUV = worldVertex.xz * 0.1;
	vec2 waveUV1 = baseUV + waveVector1;
	vec2 waveUV2 = baseUV * 0.5 + waveVector2;
	vec2 waveUV3 = baseUV * 0.2 + waveVector1 * 0.5;

	// Blend waves
	vec3 wave1 = texture(waveA, waveUV1).xyz;
	vec3 wave2 = texture(waveB, waveUV2).xyz;
	vec3 wave3 = texture(waveA, waveUV3).xyz;
	vec3 waveBlend = normalize(mix(mix(wave1, wave2, 0.5), wave3, 0.5));

	// Output ----------------------------------------

	ALBEDO = color;
	ROUGHNESS = 0.0;
	SPECULAR = 1.0;
	NORMAL_MAP = waveBlend;
	NORMAL_MAP_DEPTH = waveIntensity;
}