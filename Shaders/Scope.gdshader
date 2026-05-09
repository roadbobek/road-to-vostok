shader_type spatial;
render_mode depth_draw_always;
#include "res://Shaders/Lighting.gdshaderinc"

group_uniforms ____Main____;
uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap_anisotropic;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float limiter : hint_range(0.0, 1.0, 0.1) = 0.1;

group_uniforms ____Occlusion____;
uniform sampler2D occlusion : source_color, filter_linear_mipmap;
uniform float occlusionAmount : hint_range(0.0, 1.0, 0.1) = 1.0;

group_uniforms ___Weather____;
uniform bool dynamic = false;
uniform bool fractional = false;
uniform bool enableRain = false;

group_uniforms ____Effects____;
uniform bool metal = false;
uniform bool viewmodel = false;

// Globals
global uniform sampler2D Specular : filter_linear_mipmap_anisotropic;
global uniform sampler2D Noise : filter_linear_mipmap;
global uniform sampler2D Ripples : filter_linear_mipmap;
global uniform float Rain;
global uniform float Indoor;
global uniform float Viewmodel;
global uniform bool Occlusion;

// Varyings
varying vec3 worldNormal;
varying vec3 worldPosition;
varying float bottomMask;
varying float objectY;

// Vertex ----------------------------------------

void vertex()
{
	worldNormal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	worldPosition = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	bottomMask = smoothstep(1.0, 0.0, VERTEX.y);
	objectY = MODEL_MATRIX[3].y;

	if (viewmodel)
	{
		float onetanfov = 1.0f / tan(0.5f * (Viewmodel * PI / 180.0f));
		float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
		PROJECTION_MATRIX[1][1] = -onetanfov;
		PROJECTION_MATRIX[0][0] = onetanfov / aspect;
	}
}

// Fragment ----------------------------------------

void fragment()
{
	// Sample ----------------------------------------
	
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	vec3 detail = texture(normal, UV).rgb;
	vec3 darkening = texture(occlusion, UV).rgb;
	float specular = texture(Specular, UV * 2.0).r;
	float roughness = 0.5;
	
	// Metal ----------------------------------------
	
	if (metal)
	{
		float fresnel = pow(clamp(1.0 - dot(NORMAL, VIEW), 0.5, 1.0), 1.0);
		color *= mix(color, vec3(specular * 10.0), fresnel);
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
		float rainOutput = ripples * rippleMask * 1000.0;
		
		// Rain type
		if(dynamic)
		{
			wetness = mix(roughness, (roughness / 2.0) - rainOutput, Rain * (1.0 - Indoor));
			roughness = wetness;
		}
		else
		{
			wetness = mix(roughness, (roughness / 1.5) - rainOutput, Rain * rainMask);
			roughness = wetness;
		}
	}
	
	// Specular ----------------------------------------
	
	SPECULAR = specular * smoothstep(0.0, limiter, color.r);
	
	// Output ----------------------------------------
	
	if (Occlusion)
	{
		ALBEDO = mix(color, color * darkening, occlusionAmount);
	}
	else
	{
		ALBEDO = color;
	}
	
	ROUGHNESS = roughness;
	NORMAL_MAP = detail;
	ALPHA = 1.0;
}

// Lighting ----------------------------------------

void light()
{
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	float specular = texture(Specular, UV).r;
	custom(color, tint, limiter, specular, metal, ROUGHNESS, METALLIC, NORMAL, LIGHT, VIEW, ALBEDO, ATTENUATION, LIGHT_COLOR, DIFFUSE_LIGHT, SPECULAR_LIGHT);
}
