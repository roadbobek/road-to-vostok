shader_type canvas_item;

uniform float value : hint_range(0.0, 1.0, 0.01) = 1.0;
const vec3 progressColor = vec3(0.0, 1.0, 0.0);
const vec3 fillColor = vec3(0.25);
const float startAngle = 270.0;
const float innerWidth = 0.6;
const float outerWidth = 0.8;
const float alpha = 1.0;
const float blur = 0.05;

mat2 UVRotate(float angle)
{
	return mat2(vec2(cos(angle), -sin(angle)), vec2(sin(angle), cos(angle)));
}

vec4 RadialProgress(vec2 uv, float radialValue, float radialBlur, float IR, float OR)
{
	vec2 rotatedUV = (uv * 2.0 - 1.0) * UVRotate((-radians(startAngle)));
	vec2 origin = vec2(0.0, 0.0);
	float innerRing = IR;
	float outerRing = OR;
	float size = length(rotatedUV);
	float ring = smoothstep(outerRing + radialBlur, outerRing - radialBlur, size) - smoothstep(innerRing + radialBlur, innerRing - radialBlur, size);
	float a = atan(rotatedUV.y - origin.y, rotatedUV.x - origin.x);  
	float theta = (a < 0.0) ? (a + TAU) / TAU : a / TAU;
	float bar = step(theta, radialValue);
	float ui = ring * bar;
	vec4 output = vec4(ui);
	return output;
}

void fragment()
{
	// Sample
	vec4 primary = vec4(progressColor, alpha) * RadialProgress(UV, value, blur, innerWidth, outerWidth);
	vec4 fill = vec4(fillColor, alpha) * RadialProgress(UV, 100, blur, innerWidth, outerWidth);
	
	// Output
	COLOR = primary + fill;
}
