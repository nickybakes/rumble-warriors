float blend_overlay_float(float a, float b, float t){
	if (a < 0.5) {
    	return 2.0 * a * b;
	} else {
    	return 1.0 - 2.0 * (1.0 - a) * (1.0 - b);
	}
}

vec3 blend_overlay(vec3 a, vec3 b, float t){
	return mix(vec3(blend_overlay_float(a.r, b.r, t),
	blend_overlay_float(a.g, b.g, t),
	blend_overlay_float(a.b, b.b, t)), b, 1.0 - t);
}

vec3 blend_overlay_asym(float a, vec3 b, float t){
	return mix(vec3(blend_overlay_float(a, b.r, t),
	blend_overlay_float(a, b.g, t),
	blend_overlay_float(a, b.b, t)), b, 1.0 - t);
}

float remap(float i, float a, float b, float x, float y){
	return mix (x, y, (i-a)/b);
}

float saturate(float t){
	return clamp(t, 0.0, 1.0);
}

float scanline_screenspace(float time, float screenY, float scanlineSize, float speed)
{
	return clamp(pow(sin(screenY * scanlineSize + time * speed), 2.0), 0.0, 1.0);
}

vec3 fresnel_glow_color(float amount, float intensity, vec3 color, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * color * intensity;
}

float fresnel_glow(float amount, float intensity, vec3 normal, vec3 view)
{
	return pow((1.0 - dot(normalize(normal), normalize(view))), amount) * intensity;
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}
