shader_type canvas_item;

uniform float scroll_speed = 1.5;
uniform float head_progress : hint_range(0.0, 1.0) = 1.0;
uniform float tail_progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	float line_progress = UV.x;
	if (line_progress < tail_progress || line_progress > head_progress) {
		discard;
	}

	// --- 3. 纹理滚动 ---
	vec2 scrolling_uv = UV;
	scrolling_uv.x += TIME * scroll_speed;

	// --- 4. 颜色计算 ---
	vec4 texture_color = texture(TEXTURE, scrolling_uv);
	COLOR = texture_color * COLOR;
}