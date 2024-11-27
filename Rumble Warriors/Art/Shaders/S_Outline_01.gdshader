shader_type spatial;
render_mode blend_mix, unshaded, cull_front, depth_draw_never;
#include "SI_EffectsInclude_01.gdshaderinc"

uniform vec3 outlineColor : source_color = vec3(0, 0, 0);
uniform float outlineThickness = .1;

void vertex(){
	VERTEX += NORMAL * outlineThickness;
}

void fragment() {
	ALBEDO = outlineColor;
}
