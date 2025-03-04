shader_type spatial;

#include "SI_EffectsInclude_01.gdshaderinc"

global uniform vec2 ringCenter;
global uniform float ringRadius;

uniform sampler2D devTexture : source_color, filter_nearest;

uniform float textureScale = 1.5;

uniform float saturation : hint_range(0.0, 1.0, .01) = 1.0;

void vertex() {
	COLOR.r = map(cos(NODE_POSITION_WORLD.x * 5.0), 0.0, 1.0, .4, .8);
	COLOR.g = map(sin(NODE_POSITION_WORLD.y * 5.0), 0.0, 1.0, .5, .8);
	COLOR.b = map(sin(NODE_POSITION_WORLD.z * 5.0), 0.0, 1.0, .4, .8);
}

void fragment() {
	vec3 WORLD_POS = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(normalize(NORMAL), 0.0)).xyz;
	vec3 absNormal = abs(WORLD_NORMAL);
	vec3 blendWeights = pow(absNormal, vec3(100.0));
	blendWeights = normalize(blendWeights);
	vec2 WORLD_UV = (blendWeights.x * WORLD_POS.yz) + (blendWeights.y * WORLD_POS.xz) + (blendWeights.z * WORLD_POS.xy);
	
	vec3 adjustedColor = COLOR.rgb + ((1.0 - saturation) * 5.0);
	
	vec3 sampledColor = adjustedColor * texture(devTexture, WORLD_UV * textureScale).rgb;
	
	float insideRing = saturate(map(distance(WORLD_POS.xz, ringCenter) - (ringRadius * .95), 0.0, .4, 0.0, 1.0));
	
	ALBEDO = mix(sampledColor, sampledColor * .1, insideRing);
	ROUGHNESS = mix(.7, .9, insideRing);
	METALLIC = mix(.3, 0.1, insideRing);
}
