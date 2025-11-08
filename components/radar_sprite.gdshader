shader_type canvas_item;

// --- Retro FX ---
uniform float shake: hint_range(0, 10) = 0.015;
uniform float noiseQuality: hint_range(0.1, 250, 0.1) = 250;
uniform float noiseIntensity: hint_range(0, 0.05, 0.001) = 0.001;
uniform float offsetIntensity: hint_range(0, 0.05, 0.0001) = 0.0045;
uniform float colorOffsetIntensity: hint_range(0.1, 1.5, 0.001) = 0.2;
uniform float pixelSize: hint_range(1, 1024) = 200.0;
uniform float grainIntensity: hint_range(0, 1) = 0.04;
uniform float lens_distortion_strength: hint_range(0, 0.1) = 0.05;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

// --- Helpers ---
float rand(vec2 co) {
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float verticalBar(float pos, float uvY, float offset) {
	float edge0 = pos - shake;
	float edge1 = pos + shake;

	float x = smoothstep(edge0, pos, uvY) * offset;
	x -= smoothstep(pos, edge1, uvY) * offset;
	return x;
}

uniform bool shaking       = false;
uniform float amplitude    = 1.0;
uniform float noise_scale  = 20.0;
uniform float noise_speed  = 20.0;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  float a = hash(i + vec2(0.0,0.0));
  float b = hash(i + vec2(1.0,0.0));
  float c = hash(i + vec2(0.0,1.0));
  float d = hash(i + vec2(1.0,1.0));
  vec2 u = f*f*(3.0-2.0*f);
  return mix(a, b, u.x) +
  (c - a) * u.y * (1.0 - u.x) +
  (d - b) * u.x * u.y;
}

void fragment() {
	if (shaking) {
	vec2 uv = UV;
	vec4 orig = texture(TEXTURE, uv);
	if (orig.a <= 0.0) {
		discard;
	}

    // Generate two noise values to construct a random direction.
	float nx = noise(uv * noise_scale + vec2(TIME * noise_speed, 0.0));
	float ny = noise(uv * noise_scale + vec2(0.0, TIME * noise_speed));
    // Map [0,1] to [-1,1]
	vec2 rand_dir = normalize(vec2(nx * 2.0 - 1.0, ny * 2.0 - 1.0));

    // Use another noise value to determine the jitter amplitude sign.
    float n = noise(uv * noise_scale + vec2(TIME * noise_speed));
    float off = (n * 2.0 - 1.0) * amplitude;

    // Offset along a random direction
    vec2 uv2 = uv + rand_dir * off * TEXTURE_PIXEL_SIZE;
    COLOR = texture(TEXTURE, uv2);
  }

	vec2 iRes = 1.0 / SCREEN_PIXEL_SIZE;
	vec2 uv = FRAGCOORD.xy / iRes;

	// -------- Retro Pixelation --------
	uv = floor(uv * pixelSize) / pixelSize;

	// -------- Vertical Bar Distortion --------
	for (float i = 0.0; i < 0.71; i += 0.1313) {
		float d = mod(TIME * i, 1.7);
		float o = sin(1.0 - tan(TIME * 0.24 * i));
		o *= offsetIntensity;
		uv.x += verticalBar(d, uv.y, o);
	}

	// -------- Noise Distortion --------
	float uvY = uv.y * noiseQuality;
	uvY = float(int(uvY)) * (1.0 / noiseQuality);
	float noise = rand(vec2(TIME * 0.00001, uvY));
	uv.x += noise * noiseIntensity;

	// -------- Chromatic Offset --------
	vec2 offsetR = vec2(0.006 * sin(TIME), 0.0) * colorOffsetIntensity;
	vec2 offsetG = vec2(0.0073 * cos(TIME * 0.97), 0.0) * colorOffsetIntensity;

	float r = texture(screen_texture, uv + offsetR).r;
	float g = texture(screen_texture, uv + offsetG).g;
	float b = texture(screen_texture, uv).b;

	vec4 tex = vec4(r, g, b, 1.0);

	// -------- Grain --------
	float grain = rand(uv) * 2.0 - 1.0;
	tex.rgb += grainIntensity * grain;

	// -------- Lens Distortion --------
	vec2 dist = uv * lens_distortion_strength * (uv - 1.0);
	vec4 distorted = texture(screen_texture, uv + dist);
	tex = mix(tex, distorted, 0.5);

	COLOR = tex;

}