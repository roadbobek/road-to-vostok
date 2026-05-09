shader_type canvas_item;

uniform float exposure : hint_range(0.0, 4.0) = 1.0;
uniform float contrast : hint_range(0.0, 2.0) = 1.0;
uniform bool posterize = false;

void fragment() {
    // Sample the original texture color
    vec4 color = texture(TEXTURE, UV);

    // Apply exposure (affects brightness)
    color.rgb = color.rgb * pow(2.0, exposure - 1.0);

    // Apply contrast
    color.rgb = ((color.rgb - 0.5) * contrast) + 0.5;

    // Apply posterization
	if (posterize)
	{
	    color.rgb = floor(color.rgb * 15.0) / 15.0;
    	color.rgb = clamp(color.rgb, 0.0, 1.0);
	}


    // Preserve original alpha (transparency)
    COLOR = vec4(color.rgb, color.a);
}