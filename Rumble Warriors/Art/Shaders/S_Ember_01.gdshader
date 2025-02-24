shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;
#include "SI_EffectsInclude_01.gdshaderinc"

global uniform float steppedTime;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D fireNoiseTexture : filter_linear_mipmap;

uniform vec3 innerColor : source_color = vec3(0, 0, 0);
uniform vec3 outerColor : source_color = vec3(1, 1, 1);


uniform float depthMultiply = .4;
uniform float depthPower = .6;
uniform float textureScale = .2;
uniform float distortAmount = .6;

uniform float fadeAwayDistance = 2.0;


void vertex() {
    VERTEX.xz = normalize(INV_VIEW_MATRIX[0].xz) * VERTEX.x + normalize(INV_VIEW_MATRIX[2].xz) * VERTEX.z;
    VERTEX.y = VERTEX.y;
}

void fragment() {
	vec3 WORLD_POS = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 WORLD_NORMAL = (INV_VIEW_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	vec3 absNormal = abs(WORLD_NORMAL);
	// Get the raw linear depth from the depth texture into a  [-1, 1] range
    float depth = textureLod(depth_texture, SCREEN_UV, 0.0).r;
	// Recreate linear depth of the intersecting geometry using projection matrix, and subtract the vertex of the sphere
	depth = PROJECTION_MATRIX[3][2] / (depth + PROJECTION_MATRIX[2][2]) + VERTEX.z;
	// Intensity intersection effect
	depth = 1.0 - saturate(pow(depth * depthMultiply, depthPower));

	float distortSin = timeSin(steppedTime, depth, 5.0) * distortAmount;
	float xSample = (WORLD_POS.x + WORLD_POS.z) + distortSin + (steppedTime * 0.1);
	float ySample = WORLD_POS.y - (steppedTime * 3.0);
	float noiseSample = texture(fireNoiseTexture, vec2(xSample, ySample) * textureScale).r;
	float UVmask = (1.0 - abs(2.0 * UV.x - 1.0)) * UV.y;
	float emberMask = UVmask * timeSin(UV.y, COLOR.r, 3.4);
	float maskColor = saturate(smoothstep(emberMask - noiseSample - depth, 0.3, 1.0));

	ALBEDO = mix(innerColor, outerColor, maskColor);

	//ALBEDO = vec3(distortSin);
	float fadeAway = saturate(fadeAwayDistance - abs(VERTEX.z));
	ALPHA = saturate(1.0 - smoothstep(emberMask - noiseSample - depth - fadeAway, 0.1, 1.0));
	ALPHA_SCISSOR_THRESHOLD = .1;
	//ALBEDO = vec3(emberMask);

}
