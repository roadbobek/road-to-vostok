shader_type spatial;
render_mode cull_disabled;

group_uniforms ____Main____;
uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float limiter : hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float opacity : hint_range(0.0, 2.0, 0.1) = 1.0;

group_uniforms ____Weather____;
uniform bool fractional = false;
uniform bool enableRain = false;
uniform bool enableSnow = false;
uniform bool snowFading = false;
uniform float snowAmount : hint_range(0.0, 1.0, 0.05) = 0.0;

group_uniforms ____Noise____;
uniform bool marking = false;

// Globals & varyings
global uniform float Snow;
global uniform float Rain;
global uniform sampler2D Noise : filter_linear_mipmap;
global uniform sampler2D Specular : filter_linear_mipmap;
global uniform sampler2D Ripples : filter_linear_mipmap;
varying float cameraDistance;
varying vec3 worldPosition;
varying vec3 worldNormal;
varying float objectY;

// Fragment ----------------------------------------

void vertex()
{
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	cameraDistance = length(worldPosition - CAMERA_POSITION_WORLD);
	worldNormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	objectY = MODEL_MATRIX[3].y;
}

void fragment()
{
	// Sample textures
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	vec3 detail = texture(normal, UV).rgb;
	float alpha = texture(albedo, UV).a;
	float roughness = 0.5;
	
	// Snow
	if (enableSnow)
	{
		// Snow mask
		 float snowMask = 1.0;
		
		// Fractional
		if (fractional)
		{
			float heightFraction = abs(fract(objectY / 0.1) * 0.1);
			float epsilon = 0.0001;
			snowMask = float(min(heightFraction, 0.1 - heightFraction) > (0.005 + epsilon));
		}
		
		float topCoverage = worldNormal.y + color.r - (1.0 - snowAmount);
		float topOutput = smoothstep(0.8, 1.0, topCoverage + color.r);
		color += vec3(0.1, 0.1, 0.1) * topOutput * Snow * snowMask;
	}
	
	// Rain ----------------------------------------
	
	if (enableRain)
	{
		// Rain mask
		float rainMask = 1.0;
		float wetness;
		
		// Fractional
		if (fractional)
		{
			float YFraction = abs(fract(objectY / 0.2) * 0.2);
			float epsilon = 0.0001;
			rainMask = float(min(YFraction, 0.2 - YFraction) > (0.005 + epsilon));
		}
		
		// Rain output
		float rippleProjection = smoothstep(0.0, 0.5, worldNormal.y);
		float ripples = texture(Ripples, UV * 8.0).r;
		float rippleUV = texture(Noise, UV * 8.0 + TIME / 10.0).r;
		float rippleMask = smoothstep(0.5, 1.0, rippleUV * rippleProjection);
		float rainOutput = ripples * rippleMask * 100.0;
		
		wetness = mix(roughness, (roughness / 1.5) - rainOutput, Rain * rainMask);
		roughness = wetness;
	}
	
	// Desaturation (Winter)
	float desaturation = mix(0.0, 0.5, Snow);
	float luminance = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(luminance), desaturation);

	// Noise
	if (marking)
	{
		float alphaDetail = texture(Specular, UV * 40.0).r;
		color *= mix(1.0, alphaDetail, 1.0);
		alpha *= mix(1.0, alphaDetail, 0.8);
	}
	
	// Output
	ALBEDO = color;
	SPECULAR = smoothstep(0.0, limiter, color.r);
	ROUGHNESS = roughness;
	NORMAL_MAP = detail;
	
	if (snowFading)
	{
		ALPHA = alpha * (1.0 - Snow) * opacity;
	}
	else
	{
		ALPHA = alpha * opacity;
	}
}