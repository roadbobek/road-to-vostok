shader_type spatial;

uniform sampler2D screenTexture : hint_screen_texture, filter_linear, repeat_disable;
uniform sampler2D depthTexture : hint_depth_texture, filter_linear, repeat_disable;

group_uniforms Main;
uniform float worldFade : hint_range(0.0, 1000.0, 1.0) = 1000.0;
uniform float edgeFade : hint_range(0.0, 10.0, 1.0) = 10.0;

group_uniforms Ice;
uniform sampler2D iceAlbedo : filter_linear_mipmap_anisotropic;
uniform sampler2D iceNormal : filter_linear_mipmap_anisotropic;
uniform vec3 iceColor : source_color;
uniform float iceTiling : hint_range(0.1, 100.0, 1.0) = 100.0;
uniform float iceSpecular : hint_range(0.0, 1.0, 0.1) = 0.2;
uniform float iceRoughness : hint_range(0.0, 1.0, 0.1) = 0.0;

group_uniforms Snow;
uniform sampler2D snowAlbedo : filter_linear_mipmap_anisotropic;
uniform sampler2D snowNormal : filter_linear_mipmap_anisotropic;
uniform sampler2D snowMask : filter_linear_mipmap;
uniform vec3 snowColor : source_color = vec3(1.0, 1.0, 1.0);
uniform float snowTiling : hint_range(0.1, 100.0, 1.0) = 100.0;
uniform float snowMaskTiling : hint_range(0.1, 100.0, 1.0) = 10.0;
uniform float snowSpecular : hint_range(0.0, 1.0, 0.1) = 0.2;
uniform float snowRoughness : hint_range(0.0, 1.0, 0.1) = 0.5;

group_uniforms Reflections;
uniform bool SSREnabled = true;
uniform float SSRDistance : hint_range(0.0, 300.0, 0.5) = 300.0;
uniform float SSRResolutionNear : hint_range(0.1, 20.0, 0.1) = 10.0;
uniform float SSRResolutionFar : hint_range(2.0, 40.0, 0.1) = 20.0;
uniform float SSRRefraction : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform float SSRJitterFix : hint_range(0.0, 1.0, 0.1) = 0.5;
uniform float SSRHeightFade : hint_range(0.0, 20.0, 1.0) = 10.0;
uniform float SSRColorDistance : hint_range(0.0, 300.0, 1.0) = 150.0;
uniform vec3 SSRNearColor : source_color;
uniform vec3 SSRFarColor : source_color;

varying vec3 worldCamera;
varying vec3 worldPosition;
varying vec3 worldVertex;
varying vec2 vertexUV;
varying vec3 UVWorldPosition;

// Utility ----------------------------------------

vec2 GetUVFromViewPosition(vec3 positionViewSpace, mat4 projectionMatrix)
{
	vec4 positionClipSpace = projectionMatrix * vec4(positionViewSpace.xyz, 1.0);
	vec2 positionNDC = positionClipSpace.xy / positionClipSpace.w;
	return positionNDC.xy * 0.5 + 0.5;
}
vec3 GetViewPositionFromUV(vec2 uv, float depth, mat4 inverseProjectionMatrix)
{
	vec4 positionNDC = vec4((uv * 2.0) - 1.0, depth, 1.0);
	vec4 viewPosition = inverseProjectionMatrix * positionNDC;
	return viewPosition.xyz / viewPosition.w;
}
bool BoundCheck(vec2 uv)
{
	vec2 flooredUV = abs(floor(uv));
	return flooredUV.x + flooredUV.y < 0.1;
}
bool ValidateRay(vec2 uv, float currentDepth, float validationRadius, mat4 inverseProjectionMatrix)
{
	float pixelSize = 1.0 / 1920.0;
	float totalDeviation = 0.0;
	int samples = 0;

	for (float x = -validationRadius; x <= validationRadius; x += 1.0)
	{
		for (float y = -validationRadius; y <= validationRadius; y += 1.0)
		{
			vec2 offset = vec2(x, y) * pixelSize;
			vec2 sampleUV = uv + offset;
			if (!BoundCheck(sampleUV)) continue;

			float sampleDepth = GetViewPositionFromUV(sampleUV, texture(depthTexture, sampleUV).x, inverseProjectionMatrix).z;
			totalDeviation += abs(sampleDepth - currentDepth);
			samples++;
		}
	}

	float averageDeviation = totalDeviation / float(samples);
	return averageDeviation < 1.0;
}

// Vertex ----------------------------------------

void vertex() {
	worldPosition = VERTEX;
	worldCamera = (inverse(MODELVIEW_MATRIX) * vec4(0, 0, 0, 1)).xyz;
	worldVertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	UVWorldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vertexUV = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xz;
}

// Fragment ----------------------------------------

void fragment() {
	// Calculate depth
	float depth = texture(depthTexture, SCREEN_UV, 0.0).r;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	float vertexY = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).y;
	float depthY = world.y / world.w;
	float verticalDepth = vertexY - depthY;

	// Ice layer
	vec3 iceLayer = texture(iceAlbedo, UV * iceTiling).rgb * iceColor;
	vec3 iceNormalLayer = texture(iceNormal, UV * iceTiling).xyz;

	// Snow layer
	vec3 snowLayer = texture(snowAlbedo, UV * snowTiling).rgb * snowColor;
	vec3 snowNormalLayer = texture(snowNormal, UV * snowTiling).xyz;
	float snowMaskLayer = texture(snowMask, UV * snowMaskTiling).r;

	// Mix Layers
	vec3 colorOutput = mix(iceLayer, snowLayer, snowMaskLayer);
	vec3 normalOutput = mix(iceNormalLayer, snowNormalLayer, snowMaskLayer);
	float roughnessOutput = mix(iceRoughness, snowRoughness, snowMaskLayer);
	float specularOutput = mix(iceSpecular, snowSpecular, snowMaskLayer);

	// Calculate SSR
	vec3 colorSample = vec3(-1.0);
	float alphaMask = 0.0;

	if (SSREnabled)
	{
		vec3 reflectedNormal = normalize((mat3(VIEW_MATRIX) * (vec3(NORMAL_MAP.x, 0.0, NORMAL_MAP.y) * 2.0 - 1.0) * 0.1) + NORMAL);
		vec3 reflectedPath = reflect(-VIEW, reflectedNormal);
		vec3 currentViewPosition = VERTEX;
		vec2 currentScreenPosition = vec2(0.0);
		vec2 finalScreenPosition = vec2(0.0);
		float currentStep = 0.0;
		float currentDepth = 0.0;
		bool rayValid = false;

		for (float i = 0.01; i < SSRDistance; i++) {
			currentStep = mix(SSRResolutionNear, SSRResolutionFar, float(i) / float(SSRDistance));
			currentViewPosition += reflectedPath * currentStep;
			currentScreenPosition = GetUVFromViewPosition(currentViewPosition, PROJECTION_MATRIX);

			if (!BoundCheck(currentScreenPosition)) break;

			currentDepth = GetViewPositionFromUV(currentScreenPosition, texture(depthTexture, currentScreenPosition).x, INV_PROJECTION_MATRIX).z - currentViewPosition.z;

			if (currentDepth > -0.0001 && currentDepth <= 1.0 * currentStep)
			{
				if (ValidateRay(currentScreenPosition, currentViewPosition.z + currentDepth, SSRJitterFix, INV_PROJECTION_MATRIX))
				{
					colorSample = textureLod(screenTexture, currentScreenPosition, 1.0).rgb;
					float distanceFactor = clamp(i / SSRColorDistance, 0.0, 1.0);
					vec3 distanceColor = mix(SSRNearColor, SSRFarColor, distanceFactor);
					colorSample *= distanceColor;
					finalScreenPosition = currentScreenPosition;
					rayValid = true;
					break;
				}
				break;
			}

			 i += currentStep;
		}

		if (rayValid)
		{
			vec2 RUV = 1.0 - abs(finalScreenPosition * 2.0 - 1.0);
			RUV = pow(RUV, vec2(0.5));
			alphaMask = clamp(min(RUV.x, RUV.y), 0.0, 1.0) * (1.0 - snowMaskLayer);

			float cameraHeight = worldCamera.y;
			float surfaceHeight = worldVertex.y;
			float heightDifference = cameraHeight - surfaceHeight;
			float fadeStartHeight = SSRHeightFade;
			float fadeEndHeight = SSRHeightFade + 10.0;
			float fadeFactor = smoothstep(fadeStartHeight, fadeEndHeight, heightDifference);
			alphaMask *= (1.0 - fadeFactor);
		}
		else
		{
			alphaMask = 0.0;
		}
	}

	// Transparency ----------------------------------------

	float origin = length(vec3(0, 0, 0) - worldVertex);
	float alpha = 1.0 - smoothstep(worldFade / 2.0, worldFade, origin);
	float alphaBlend = -verticalDepth * edgeFade;
	alphaBlend = clamp(1.0 - exp(alphaBlend), 0.0, 1.0);
	float alphaOutput = alphaBlend * alpha;

	// Output ----------------------------------------

	ALBEDO = mix(colorOutput, colorSample, alphaMask);
	ALPHA = alphaOutput;
	ROUGHNESS = roughnessOutput;
	SPECULAR = specularOutput;
	NORMAL_MAP = normalOutput;
	NORMAL_MAP_DEPTH = 1.0;
}