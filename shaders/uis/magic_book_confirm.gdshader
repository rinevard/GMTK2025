shader_type canvas_item;

// progress: 动画进度，从 0.0 到 1.0
uniform float progress : hint_range(0.0, 1.0) = 0.0;
// highlight_color: 高光的颜色
uniform vec4 highlight_color : source_color = vec4(1.0, 1.0, 1.0, 1.0); // 白色高光通常效果最好
// highlight_intensity: 高光的强度，可以微调效果
uniform float highlight_intensity : hint_range(0.0, 2.0) = 0.4;
// transition_width: 过渡区域的柔和度
uniform float transition_width : hint_range(0.0, 0.5) = 0.05;


void fragment() {
    // 1. 获取纹理的原始颜色
    vec4 original_color = texture(TEXTURE, UV);

    // 2. 计算像素与垂直中心线的距离
    float dist_from_center = abs(UV.x - 0.5);

    // 3. 计算当前高光“波”的边缘位置
    float wave_front = progress * 0.5;

    // 4. 使用 smoothstep 创建一个平滑的遮罩(mask)
    float effect_mask = 1.0 - smoothstep(wave_front - transition_width, wave_front, dist_from_center);

    // --- 这是关键的修改部分 ---
    // 5. 将高光颜色添加到原始颜色上，而不是替换它
    // 我们将高光颜色乘以强度和遮罩，然后加到原始颜色上。
    vec3 blended_rgb = original_color.rgb + (highlight_color.rgb * highlight_intensity * effect_mask);
    
    // 6. 输出最终颜色
    // 最终颜色 = 混合后的RGB + 原始的Alpha通道
    // 这样可以保留你图片中的透明部分。
    COLOR = vec4(blended_rgb, original_color.a);
}