shader_type spatial;
render_mode unshaded, depth_draw_opaque, cull_back;
#include "SI_PowerupInclude_01.gdshaderinc"

global uniform float steppedTime;

uniform sampler2D colorPalette : source_color, filter_nearest, repeat_disable;

void vertex() {
	vec3 delta = vec3(0.0);
	
	delta = deltaFireFlower(VERTEX, COLOR, steppedTime);
	
	delta += deltaWiggle(VERTEX, steppedTime);
	
	VERTEX = VERTEX + delta;
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	vec3 VIEW_LIGHT_NORMAL = (INV_VIEW_MATRIX * vec4(normalize(vec3(0.6, 0.5, -1.0)), 0.0)).xyz;
	
	float value = dot(WORLD_NORMAL, VIEW_LIGHT_NORMAL);
	float map1 = map(value, -.8, -.5, 0, 1);
	float map2 = map(value, -.3, 0.05, 0, 1);
	vec2 tone = tone(VERTEX);
	map1 = 1.0 - clamp(trunc(map1 + tone.x), 0.0, 1.0);
	map2 = (clamp(trunc(map2 + tone.y), 0.0, 1.0)) * 2.0;
	
	vec2 adjustedUVs = UV;
	
	adjustedUVs.y += (map1 + map2) * .25;
	
	ALBEDO = texture(colorPalette, adjustedUVs).rgb;
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
