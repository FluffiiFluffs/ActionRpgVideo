shader_type canvas_item;
render_mode blend_mix;

// Blur strengths
uniform float base_blur : hint_range(0.0, 10.0) = 0.5;
uniform float max_blur  : hint_range(0.0, 10.0) = 4.0;

// Show some of the sprite image over the blur
uniform float sprite_mix : hint_range(0.0, 1.0) = 0.25;

// Optional grading
uniform vec4  tint          : source_color = vec4(1.0);
uniform float tint_strength : hint_range(0.0, 1.0) = 0.0;
uniform float saturation    : hint_range(0.0, 1.0) = 1.0;

// Toggle small kernel blur instead of mip bias
uniform bool  use_kernel = false;
uniform float kernel_radius_pixels : hint_range(0.0, 8.0) = 2.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

float luma(vec3 c) { return dot(c, vec3(0.299, 0.587, 0.114)); }

vec3 grade(vec3 rgb) {
	float y = luma(rgb);
	vec3 desat = mix(vec3(y), rgb, saturation);
	return mix(desat, tint.rgb, tint_strength);
}

vec2 screen_pixel_size() {
	// texel size for the screen texture
	return 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));
}

vec3 blur_kernel(vec2 uv, float radius_px) {
	// five tap cross with gaussian like weights
	vec2 px = screen_pixel_size() * radius_px;
	float w0 = 0.4026;
	float w1 = 0.2442;
	float w2 = 0.0545;

	vec3 acc = texture(SCREEN_TEXTURE, uv).rgb * w0;

	acc += texture(SCREEN_TEXTURE, uv + vec2(px.x, 0.0)).rgb * w1;
	acc += texture(SCREEN_TEXTURE, uv - vec2(px.x, 0.0)).rgb * w1;
	acc += texture(SCREEN_TEXTURE, uv + vec2(0.0, px.y)).rgb * w1;
	acc += texture(SCREEN_TEXTURE, uv - vec2(0.0, px.y)).rgb * w1;

	vec2 px2 = px * 2.0;
	acc += texture(SCREEN_TEXTURE, uv + vec2(px2.x, 0.0)).rgb * w2;
	acc += texture(SCREEN_TEXTURE, uv - vec2(px2.x, 0.0)).rgb * w2;
	acc += texture(SCREEN_TEXTURE, uv + vec2(0.0, px2.y)).rgb * w2;
	acc += texture(SCREEN_TEXTURE, uv - vec2(0.0, px2.y)).rgb * w2;

	float norm = w0 + 4.0 * (w1 + w2);
	return acc / norm;
}

void fragment() {
	// brightness from your mask drives blur amount
	vec4 mask_col = texture(TEXTURE, UV);
	float mask_brightness = luma(mask_col.rgb);

	float blur_amt = mix(base_blur, max_blur, mask_brightness);

	vec3 bg;
	if (use_kernel) {
		float radius_px = kernel_radius_pixels * blur_amt;
		bg = blur_kernel(SCREEN_UV, radius_px);
	} else {
		bg = texture(SCREEN_TEXTURE, SCREEN_UV, blur_amt).rgb;
	}

	vec3 graded = grade(bg);

	// blend some of the sprite back on top
	vec3 final_rgb = mix(graded, mask_col.rgb, sprite_mix);

	COLOR = vec4(final_rgb, mask_col.a);
}

