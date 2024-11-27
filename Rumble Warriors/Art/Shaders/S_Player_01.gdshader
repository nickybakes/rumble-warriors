shader_type spatial;
render_mode blend_mix, unshaded, depth_draw_never;
#include "SI_EffectsInclude_01.gdshaderinc"

uniform vec3 playerColor : source_color = vec3(1, 0, 0);

const vec3 reflectColor = vec3(1, 1, 1);
const vec4 lightDirection = vec4(normalize(vec3(0.5, 0.5, 1.0)), 0.0);

void fragment() {
	vec3 WORLD_POS = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	vec3 VIEW_LIGHT_NORMAL = (INV_VIEW_MATRIX * lightDirection).xyz;

	float lightValue = saturate(1.0 - smoothstep(dot(WORLD_NORMAL, VIEW_LIGHT_NORMAL), 0.95, 1.0));

	ALBEDO = mix(playerColor, reflectColor, lightValue);
}
