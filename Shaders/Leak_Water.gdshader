shader_type spatial;
render_mode unshaded;

// Fragment ----------------------------------------

void fragment()
{
	float UVx = min(UV.x, 1.0 - UV.x);
	float UVy = min(UV.y, 1.0 - UV.y);
	float UVFade = smoothstep(0.0, 0.04, min(UVx, UVy));

	// Output ----------------------------------------

	ALBEDO = vec3(0,0,0);
	ALPHA = UVFade;
}