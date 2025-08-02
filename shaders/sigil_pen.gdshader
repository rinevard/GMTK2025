// Godot Shader Language
shader_type canvas_item;

// 定义一些可以在检查器中调整的参数
uniform sampler2D brush_texture : source_color; // 我们的笔刷纹理
uniform vec4 color_cyan : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 color_magenta : source_color = vec4(1.0, 0.0, 1.0, 1.0);
uniform vec4 color_yellow : source_color = vec4(1.0, 1.0, 0.0, 1.0);
uniform float offset_amount = 0.02; // 色彩偏移量

void fragment() {
	// UV 是当前像素在 Polygon2D 纹理上的坐标 (从 0.0 到 1.0)
	
	// 对笔刷纹理进行三次采样
	// 1. 青色层：在UV坐标上稍微偏移一点
	float cyan_alpha = texture(brush_texture, UV - vec2(offset_amount, 0.0)).a;
	
	// 2. 品红层：在UV坐标上向相反方向偏移
	float magenta_alpha = texture(brush_texture, UV + vec2(offset_amount, 0.0)).a;
	
	// 3. 黄色/主色层：在原始UV坐标采样
	float yellow_alpha = texture(brush_texture, UV).a;
	
	// 根据每次采样的 alpha (透明度) 值，将三种颜色混合起来
	// alpha 值越高的颜色，贡献越大
	vec3 final_color = color_cyan.rgb * cyan_alpha + 
					   color_magenta.rgb * magenta_alpha + 
					   color_yellow.rgb * yellow_alpha;
	
	// 最终的透明度取三者中的最大值，防止线条中间有空洞
	float final_alpha = max(cyan_alpha, max(magenta_alpha, yellow_alpha));
	
	// 输出最终颜色
	COLOR = vec4(final_color, final_alpha);
}