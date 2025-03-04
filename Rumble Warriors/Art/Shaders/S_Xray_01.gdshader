shader_type spatial;
render_mode unshaded, depth_test_disabled, depth_draw_always;
#include "SI_EffectsInclude_01.gdshaderinc"

uniform vec3 color : source_color = vec3(.25, .25, .25);
uniform float fresnelPower = 1.0;
uniform float fresnelMultiply = 1.0;

void fragment() {
	float value = pow(dot(normalize(NORMAL), VIEW), fresnelPower) * fresnelMultiply;
	vec2 tone = tone(VERTEX);
	ALPHA = .5 * (clamp(trunc(value + tone.y), 0.0, 1.0)) * 2.0;
	ALBEDO = color;
}
