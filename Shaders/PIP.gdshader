shader_type spatial;
render_mode unshaded;

uniform sampler2D viewport : source_color, filter_linear;
uniform bool active = true;
const float brightness = 0.8;
const float contrast = 0.99;

void fragment()
{
	vec3 color = texture(viewport, UV).rgb;
	color *= brightness;
	color = (color - 0.5) * contrast + 0.5;

	if (active)
	{
		ALBEDO = color;
	}
	else
	{
		ALBEDO = vec3(0.0);
	}
}