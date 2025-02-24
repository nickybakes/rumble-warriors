shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;
#include "SI_EffectsInclude_01.gdshaderinc"

global uniform float steppedTime;
global uniform float ringRadius;

uniform sampler2D depth_texture : hint_depth_texture, repeat_disable, filter_nearest;
uniform sampler2D fireNoiseTexture : filter_linear_mipmap;

uniform vec3 innerColor : source_color = vec3(0, 0, 0);
uniform vec3 outerColor : source_color = vec3(1, 1, 1);


uniform float depthMultiply = .4;
uniform float depthPower = .6;
uniform float textureScale = .2;
uniform float distortAmount = .6;
uniform float timeScale = 3.0;

uniform float fadeAwayDistance = 2.0;

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
	float xSample = (UV.x * 10.0 * ringRadius) + distortSin + (steppedTime * timeScale * .3 );
	float ySample = WORLD_POS.y - (steppedTime * timeScale);
	float noiseSample = texture(fireNoiseTexture, vec2(xSample, ySample) * textureScale).r;
	float maskColor = saturate(smoothstep(depth - noiseSample, 0.3, 1.0));	
	ALBEDO = mix(innerColor, outerColor, maskColor);
	//ALBEDO = vec3(distortSin);
	float fadeAway = saturate(fadeAwayDistance - abs(VERTEX.z));
	ALPHA = saturate(1.0 - smoothstep(depth - noiseSample - fadeAway, 0.1, 1.0));
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}
