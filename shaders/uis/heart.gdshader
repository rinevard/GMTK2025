// shader_type: 指定这是一个用于2D元素的着色器
shader_type canvas_item;

// uniform: 溶解进度，从0.0（完全可见）到1.0（完全溶解）
uniform float progress : hint_range(0.0, 1.0) = 0.0;

void fragment() {
    // 获取纹理的原始颜色
    vec4 color = texture(TEXTURE, UV);

    // 计算当前像素到中心点(0.5, 0.5)的距离
    float dist = distance(UV, vec2(0.5));
    
    // 溶解的阈值。我们乘以0.71让圆形在progress=1.0时刚好覆盖到角落。
    float threshold = progress * 0.71; 

    // 使用 step 函数。如果距离大于阈值，返回1.0（可见），否则返回0.0（透明）。
    // 这会产生一个硬边圆形。如果你想要软边，可以用 smoothstep。
    float alpha_multiplier = step(threshold, dist);
    
    // 使用 smoothstep 可以创建平滑的边缘
    // float softness = 0.01;
    // float alpha_multiplier = smoothstep(threshold - softness, threshold + softness, dist);

    // 将计算出的透明度应用到原始颜色的alpha通道
    color.a *= alpha_multiplier;

    // 将最终颜色赋给屏幕上的像素
    COLOR = color;
}