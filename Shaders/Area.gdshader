shader_type spatial;
render_mode unshaded, depth_test_disabled, cull_disabled;

uniform vec3 color : source_color = vec3(1.0, 1.0, 1.0);
const float thickness = 0.05;
const float spacing = 50.0;
const float opacity = 1.0;
const float speed = 0.1;

void fragment() 
{
	float scroll = -TIME * speed;
	float edgeDistance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge = step(edgeDistance, thickness);
	float pattern = step(0.5, 0.5 + 0.5 * sin(spacing * (UV.x + UV.y + scroll)));
	float cutout = edge * pattern * opacity;
	ALBEDO = color;
	ALPHA = cutout;
}