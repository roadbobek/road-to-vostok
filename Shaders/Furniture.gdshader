shader_type spatial;
render_mode unshaded;

uniform bool valid = true;
const float opacity = 0.05;
const vec3 validColor = vec3(0.0, 1.0, 0.0);
const vec3 invalidColor = vec3(1.0, 0.0, 0.0);

void fragment() 
{
	vec3 color;
	
	if (valid)
	{
		color = validColor;
	}
	else
	{
		color = invalidColor;
	}
	
	ALBEDO = color;
	ALPHA = opacity;
}
