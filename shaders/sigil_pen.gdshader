shader_type canvas_item;

// --- 可调参数 ---
uniform float speed : hint_range(0.0, 5.0) = 1.0;
uniform float max_glow_bonus: hint_range(0.0, 1.0, 0.1) = 0.2;

// 第一个波浪 (主波浪，频率较低，振幅较大)
uniform int wave1_frequency : hint_range(1, 10) = 3;
uniform float wave1_amplitude : hint_range(0.0, 0.2) = 0.04;
uniform float wave1_speed : hint_range(0.0, 10.0) = 2.0;

// 第二个波浪 (细节波浪，频率较高，振幅较小)
uniform int wave2_frequency : hint_range(5, 30) = 11;
uniform float wave2_amplitude : hint_range(0.0, 0.1) = 0.02;
uniform float wave2_speed : hint_range(0.0, 20.0) = 5.0;

void fragment() {
    // 1. 创建流动的UV坐标
    vec2 uv_flow = UV;
    uv_flow.x = fract(UV.x - TIME * speed);

    // 2. 计算两个独立的、周期性的波浪偏移
    float angle1 = (uv_flow.x * float(wave1_frequency) + TIME * wave1_speed) * TAU;
    float offset1 = sin(angle1) * wave1_amplitude;

    float angle2 = (uv_flow.x * float(wave2_frequency) + TIME * wave2_speed) * TAU;
    float offset2 = sin(angle2) * wave2_amplitude;
    
    // 3. 将两个波浪的偏移量相加，得到最终的复杂偏移
    float total_offset_y = offset1 + offset2;
    
    // 4. 将偏移应用到UV的y坐标上
    uv_flow.y += total_offset_y;
    
    // 5. 使用扭曲后的UV采样纹理
    vec4 final_color = texture(TEXTURE, uv_flow);
    
    // 防止因扭曲超出边界而采样到错误颜色
    if (UV.y > 1.0 || UV.y < 0.0) {
        final_color.a = 0.0;
    }

    COLOR = final_color * (1.0 + max_glow_bonus);
}