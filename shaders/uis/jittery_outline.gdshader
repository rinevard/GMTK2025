shader_type canvas_item;

uniform float bloom_strength: hint_range(0.0, 1.0, 0.02) = 0.1;
// Max distance from texture.
uniform float maxLineWidth: hint_range(0.0, 200.0) = 10.0;
// Min distance from texture.
uniform float minLineWidth: hint_range(0.0, 100.0) = 5.0;
// How often to recompute the outline.
uniform float speed: hint_range(0.0, 10.0) = 1.0;
// How big the outline blotches are.
uniform float blockSize: hint_range(0.000, 100.0) = 20.0;
// The outline color.
uniform vec4 color: source_color;
// Used to compensate for alpha values.
uniform float tolerance: hint_range(0.0, 0.999) = 0.0;

// ================= 新增 Uniform =================
// 控制纹理（白圆）本身的抖动幅度
uniform float texture_jiggle_amount: hint_range(0.0, 50.0) = 5.0;
// ==============================================


// Compensate UV for outline.
void vertex() {
	VERTEX = vec2(VERTEX.x * (1.0 + TEXTURE_PIXEL_SIZE.x * max(maxLineWidth, minLineWidth) * 2.0), VERTEX.y * (1.0 + TEXTURE_PIXEL_SIZE.y * max(maxLineWidth, minLineWidth) * 2.0));
}

// Checks a fragment for the edge of an uv.
bool border(vec2 uv) {
	vec2 uvBorder = abs(uv - vec2(0.5));
	return max(step(0.5, uvBorder.x), step(0.5, uvBorder.y)) > 0.0;
}

// Gets alpha of given fragment if not near the edge.
float get_alpha(sampler2D tex, vec2 uv){
	float res = 0.0;
	if (!border(uv)) {
		res = texture(tex, uv).a;
	}
	return res;
}

// Pseudorandom number
float hash(vec2 p, float s) {
	return fract(35.1 * sin(dot(vec3(112.3, 459.2, 753.2), vec3(p, s))));
}

// Noise function.
float noise(vec2 p, float s) {
	vec2 d = vec2(0, 1);
	vec2 b = floor(p);
	vec2 f = fract(p);
	return mix(
		mix(hash(b + d.xx, s), hash(b + d.yx, s), f.x),
		mix(hash(b + d.xy, s), hash(b + d.yy, s), f.x), f.y);
}

// Randomize line width at fragment.
float get_line_width(vec2 p, float s) {
	p /= blockSize;
	float w = 0.0;
	float intensity = 1.0;
	for (int i = 0; i < 3; i++) {
		w = mix(w, noise(p, s), intensity);
		p /= 2.0;
		intensity /= 2.0;
	}
	
	return mix(maxLineWidth, minLineWidth, w);
}

// Checks for neighboring pixels.
float in_range(vec2 size, sampler2D tex, vec2 uv) {
	float res = 0.0;
	for (float i = -1.0; i < 2.0; i += 2.0) {
		res += get_alpha(tex, uv + vec2(i * size.x, 0.0));
		res += get_alpha(tex, uv + vec2(0.0, i * size.y));
		for (float j = -1.0; j < 2.0; j += 2.0) {
			res += get_alpha(tex, uv + vec2(i * size.x, j * size.y));
			res += get_alpha(tex, uv + vec2(i * size.x, j * size.y * 0.5));
		}
	}
	return res;
}

void fragment() {
	// Correct image size to for outline in frame.
	vec2 uv = UV;
	uv -= vec2(0.5);
	vec2 edge = TEXTURE_PIXEL_SIZE * max(maxLineWidth, minLineWidth) * 2.0;
	uv = uv + uv * edge;
	uv += vec2(0.5);

	float timeStep = floor(TIME * speed);

	// ================= 新增代码块: 计算纹理抖动偏移 =================
	vec2 jiggle_offset = vec2(0.0);
	if (texture_jiggle_amount > 0.0) {
		// 使用噪点函数为x和y坐标生成不同的随机值
		// 使用不同的偏移量(如12.3, 45.6)来确保x和y的噪点不同步
		float jiggle_x = noise(uv * 5.0, timeStep + 12.3);
		float jiggle_y = noise(uv * 5.0, timeStep + 45.6);
		
		// 将噪点值从[0, 1]范围映射到[-0.5, 0.5]，然后乘以抖动强度
		jiggle_offset = vec2(jiggle_x - 0.5, jiggle_y - 0.5);
		jiggle_offset *= texture_jiggle_amount * TEXTURE_PIXEL_SIZE;
	}
	
	// 将抖动偏移应用到UV坐标上，得到最终的采样坐标
	vec2 final_uv = uv + jiggle_offset;
	// ==============================================================
	
	
	if (max(maxLineWidth, minLineWidth) > 0.0) {
		// 使用抖动后的UV (final_uv) 来获取纹理颜色
		vec4 newColor = texture(TEXTURE, final_uv);
		
		if (newColor.a <= tolerance || border(uv)) { // border检查仍然使用原始uv，防止边缘伪影
			vec2 size = TEXTURE_PIXEL_SIZE;
			size *= get_line_width(uv / TEXTURE_PIXEL_SIZE, timeStep);
			
			// 使用抖动后的UV (final_uv) 来计算轮廓，确保轮廓跟随纹理
			vec4 finalColor = step(1.0 - tolerance, in_range(size, TEXTURE, final_uv)) * color;
			newColor = finalColor;
		}
		COLOR = newColor * (1.0 + bloom_strength);
	} else {
		// 如果没有轮廓，仍然应用纹理抖动
		COLOR = texture(TEXTURE, final_uv) * (1.0 + bloom_strength);
	}
}