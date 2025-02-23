shader_type spatial;
render_mode blend_mix, unshaded, cull_back;
#include "SI_EffectsInclude_01.gdshaderinc"

global uniform float steppedTime;

uniform sampler2D textTexture : filter_linear_mipmap;

void fragment() {
	vec4 sampledColor = texture(textTexture, UV);
	ALBEDO = sampledColor.rgb;
	ALPHA = sampledColor.a;
}
