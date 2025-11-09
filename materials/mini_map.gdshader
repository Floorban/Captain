shader_type canvas_item;

uniform float circle_width: hint_range(0.0, 1.0, 0.05) = 0.15;
uniform float wait_time: hint_range(0.0, 5.0, 0.1) = 0.5;
uniform float speed: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float alpha_boost: hint_range(1.0, 5.0, 0.1) = 2.0;

uniform bool scan_active = false;
uniform float scan_time = 0.0;  

render_mode blend_add;
uniform vec4 glow_color : source_color = vec4(1.0, 0.9, 0.5, 1.0);
uniform float intensity : hint_range(0.0, 5.0) = 1.5;
uniform float spread : hint_range(0.1, 2.0) = 1.0;
uniform float pulse_speed : hint_range(0.0, 10.0) = 1.0;

void fragment() {
    vec2 centered_uv = UV - vec2(0.5);
    float dist = length(centered_uv) * spread;
    float alpha = max(0.0, 1.0 - dist);
    alpha *= (1.0 + 0.2 * sin(TIME * pulse_speed));
    alpha = clamp(alpha * intensity, 0.0, 1.0);
    COLOR = glow_color * alpha;
	
	if (!scan_active) {
		discard;
	}
	
	dist = distance(UV, vec2(0.5)) * 0.5;
	float current_radius = scan_time * speed;
	float mod_dist = dist - current_radius + 0.5;
	//float mod_dist = dist - mod(TIME * speed, 0.75 + wait_time) + 0.5;
	COLOR.a *= 1.0 - step(0.5, mod_dist);
	COLOR.a += step(0.5 - circle_width / 2.0, mod_dist) - 1.0;
	COLOR.a -= smoothstep(0.5 - circle_width / 2.0, 0.5 + circle_width / 2.0, mod_dist);
	COLOR.a -= 2.0 * dist;
	COLOR.a *= alpha_boost;
}