shader_type spatial;
render_mode cull_disabled, unshaded;

uniform sampler2D flipbook : source_color, filter_linear_mipmap, repeat_disable;
uniform vec4 color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity : hint_range(1, 100) = 1.0;
uniform int HFrames = 8;
uniform int VFrames = 8;
uniform bool loop = true;
uniform bool limitTilt = true;

varying vec2 nextUV;
varying float timer;

void vertex() 
{
	// Billboard vectors
	vec3 vRight = normalize(INV_VIEW_MATRIX[0].xyz);
	vec3 vUp = normalize(INV_VIEW_MATRIX[1].xyz);
	vec3 vBack = normalize(INV_VIEW_MATRIX[2].xyz);
	
	// Limit tilt
	if (limitTilt) 
	{
		vUp = normalize(mix(vec3(0.0, 1.0, 0.0), vUp, 0.5));
		vBack = normalize(cross(vRight, vUp));
	}
	
	// Calculate matrix
	mat4 mat_world = mat4(vec4(vRight, 0.0), vec4(vUp, 0.0), vec4(vBack, 0.0), MODEL_MATRIX[3]);
	mat_world = mat_world * mat4(
		vec4(cos(INSTANCE_CUSTOM.x), -sin(INSTANCE_CUSTOM.x), 0.0, 0.0), 
		vec4(sin(INSTANCE_CUSTOM.x), cos(INSTANCE_CUSTOM.x), 0.0, 0.0), 
		vec4(0.0, 0.0, 1.0, 0.0), 
		vec4(0.0, 0.0, 0.0, 1.0)
	);
	
	// Apply matrix
	MODELVIEW_MATRIX = VIEW_MATRIX * mat_world;
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
	
	// Handle flipbook
	float xFrames = float(HFrames);
	float yFrames = float(VFrames);
	float totalFrames = float(HFrames * VFrames);
	float particleFrame = floor(INSTANCE_CUSTOM.z * float(totalFrames));
	
	// Handle loop
	if (!loop) { particleFrame = mod(particleFrame, totalFrames); } 
	else { particleFrame = clamp(particleFrame, 0.0, totalFrames - 1.0); }
	
	// Loop UV's
	UV /= vec2(xFrames, yFrames);
	nextUV = UV;
	UV += vec2(mod(particleFrame, xFrames) / xFrames, floor((particleFrame + 0.5) / xFrames) / yFrames);
	nextUV += vec2(mod(particleFrame + 1.0, xFrames) / xFrames, floor((particleFrame + 1.0 + 0.5) / xFrames) / yFrames);
	timer = fract(INSTANCE_CUSTOM.y * xFrames * yFrames);
}

void fragment() 
{
	vec4 albedo = texture(flipbook, UV);
	albedo *= COLOR;
	ALBEDO = color.rgb * albedo.rgb * intensity;
	ALPHA *= color.a * albedo.a;
}