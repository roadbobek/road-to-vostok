shader_type spatial;
render_mode cull_disabled;

group_uniforms ____Main____;
uniform sampler2D albedo : source_color, filter_linear_mipmap_anisotropic;
uniform sampler2D normal : hint_normal, filter_linear_mipmap;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float limiter : hint_range(0.0, 1.0, 0.1) = 0.1;
uniform float opacity : hint_range(0.0, 1.0, 0.1) = 1.0;

group_uniforms ____Weather____;
uniform bool fractional = false;
uniform bool enableRain = false;
uniform bool enableSnow = false;
uniform float snowAmount : hint_range(0.0, 1.0, 0.05) = 0.0;

group_uniforms ____Effects____;
uniform bool metal = false;

// Globals & varyings
global uniform float Rain;
global uniform float Snow;
global uniform sampler2D Specular : filter_linear_mipmap;
global uniform sampler2D Ripples : filter_linear_mipmap;
global uniform sampler2D Noise : filter_linear_mipmap;
varying float objectY;

// Fragment ----------------------------------------

void vertex()
{
	objectY = MODEL_MATRIX[3].y;
}

void fragment()
{
	// Sample textures
	vec3 color = texture(albedo, UV).rgb * tint.rgb;
	vec3 detail = texture(normal, UV).rgb;
	float specular = texture(Specular, UV).r;
	float alpha = texture(albedo, UV).a;
	float roughness = 1.0;
	
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
		float ripples = texture(Ripples, UV * 8.0).r;
		float rippleUV = texture(Noise, UV * 8.0 + TIME / 10.0).r;
		float rippleMask = smoothstep(0.5, 1.0, rippleUV);
		float rainOutput = ripples * rippleMask * 100.0;
		
		wetness = mix(roughness, (roughness / 1.5) - rainOutput, Rain * rainMask);
		roughness = wetness;
	}
	
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
		
		float snowOutput = smoothstep(0.8, 1.0, snowAmount + color.r);
		color += vec3(0.1, 0.1, 0.1) * snowOutput * Snow * snowMask;
	}
	
	// Metal
	if (metal)
	{
		METALLIC = 1.0;
	}
	
	// Desaturation (Winter)
	float desaturation = mix(0.0, 0.5, Snow);
	float luminance = dot(color, vec3(0.299, 0.587, 0.114));
	color = mix(color, vec3(luminance), desaturation);
	
	// Output
	ALBEDO = color;
	SPECULAR = specular * smoothstep(0.0, limiter, color.r);
	ROUGHNESS = roughness;
	NORMAL_MAP = detail;
	ALPHA = alpha * opacity;
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}