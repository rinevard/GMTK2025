// 文件名: ReplicaShader_OriginalColor.gdshader
shader_type canvas_item;

// 我们可以保留这些 uniform，即使不直接使用 tint_color，它们在将来扩展时也可能有用。
uniform vec4 tint_color : source_color = vec4(0.5, 0.7, 1.0, 1.0); 
uniform float alpha : hint_range(0.0, 1.0) = 0.6;
uniform float distortion_amount : hint_range(0.0, 0.1) = 0.01;
uniform float distortion_speed : hint_range(0.0, 10.0) = 2.0;

void fragment() {
	// 1. 创建失真效果 (这部分是正确的)
	vec2 distorted_uv = UV;
	distorted_uv.y += sin(TIME * distortion_speed + UV.x * 10.0) * distortion_amount;
	
	// 2. 获取失真后的原始纹理颜色 (这部分也是正确的)
	vec4 original_color = texture(TEXTURE, distorted_uv);
	
	// 3. 【核心修改】应用效果
	// 将最终颜色的 RGB 设置为我们刚刚从纹理中采样到的颜色
	COLOR.rgb = original_color.rgb * 0.5 + tint_color.rgb * 0.5;
	
	// 4. 设置最终的透明度
	// 这里的逻辑依然正确，它保留了精灵本身的透明区域，并应用了全局透明度
	COLOR.a = original_color.a * alpha;
}