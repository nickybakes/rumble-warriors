shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;
#include "SI_EffectsInclude_01.gdshaderinc"

uniform vec3 potionColor : source_color = vec3(1, 0, 0);

uniform float fillAmount = .5;

uniform float radius = 1;

const vec3 bottleColor = vec3(1, 1, 1);
const vec4 lightDirection = vec4(normalize(vec3(0.5, 0.5, 1.0)), 0.0);

void fragment() {
	vec3 WORLD_POS = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 OFFSET_POS = WORLD_POS - NODE_POSITION_WORLD;
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	vec3 VIEW_LIGHT_NORMAL = (INV_VIEW_MATRIX * lightDirection).xyz;

	float lightValue = saturate(1.0 - smoothstep(dot(WORLD_NORMAL, VIEW_LIGHT_NORMAL), 0.95, 1.0));

	float fresnel = fresnel(2.0, NORMAL, VIEW);
	float bottleReflectance = saturate(1.0 - smoothstep(fresnel, .3, 1.0)) + lightValue;
	ALBEDO = mix(potionColor, bottleColor, bottleReflectance);
	float pixelFillLevel = saturate((OFFSET_POS.y + radius * .5) / radius);
	ALPHA = saturate(1.0 - smoothstep(fillAmount - pixelFillLevel, .1, 1.0) + bottleReflectance);
}
