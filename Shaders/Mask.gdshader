shader_type spatial;
render_mode depth_draw_always, specular_disabled, unshaded;

uniform bool customFOV = false;
uniform sampler2D screenTexture : hint_screen_texture, filter_linear, repeat_disable;
global uniform float Viewmodel;

void vertex()
{
	if (customFOV)
	{
		float onetanfov = 1.0f / tan(0.5f * (Viewmodel * PI / 180.0f));
		float aspect = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
		PROJECTION_MATRIX[1][1] = -onetanfov;
		PROJECTION_MATRIX[0][0] = onetanfov / aspect;
	}
}

void fragment()
{
	ALBEDO = texture(screenTexture, SCREEN_UV, 0.0).rgb;
	ALPHA = 0.0;
}