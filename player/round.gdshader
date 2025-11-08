shader_type canvas_item;

uniform float radius = 0.4;
uniform float softness = 0.095;

void fragment() {
	// UV centered around 0.5 → 0.5
	vec2 centered = UV - vec2(0.5);
	float dist = length(centered);

	// Hard circle edge
	if (dist > radius) {
		discard;
	}

	// Optional soft edge
	if (softness > 0.0) {
		float alpha = smoothstep(radius, radius - softness, dist);
		COLOR = texture(TEXTURE, UV) * alpha;
	} else {
		COLOR = texture(TEXTURE, UV);
	}
}
