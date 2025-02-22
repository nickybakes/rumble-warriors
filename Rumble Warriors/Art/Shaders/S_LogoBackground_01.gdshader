shader_type spatial;
render_mode blend_mix, unshaded, cull_disabled;
#include "SI_EffectsInclude_01.gdshaderinc"

global uniform float steppedTime;

uniform sampler2D fireNoiseTexture : filter_linear_mipmap;

uniform vec3 innerColor : source_color = vec3(0, 0, 0);
uniform vec3 outerColor : source_color = vec3(1, 1, 1);


uniform float textureScale = .2;
uniform float distortAmount = .6;
uniform float timeScale = 3.0;
uniform float wiggleScale = 1.0;
uniform float wiggleWaveScale = 1.0;


void vertex() {
	VERTEX = VERTEX + (deltaWiggle2D(VERTEX, steppedTime, wiggleScale, wiggleWaveScale) * COLOR.r);
}

void fragment() {
	float distortSin = timeSin(steppedTime * timeScale, COLOR.r, .1) * distortAmount;
	vec2 uvCoord = UV + (vec2(.5, .5) * steppedTime * timeScale) + vec2(distortSin, 0.0);
	float noiseSample = 1.0 - texture(fireNoiseTexture, uvCoord * textureScale).r;
	float maskColor = saturate(smoothstep(COLOR.r - noiseSample, 0.3, 1.0));	
	float mixColor = smoothstep(COLOR.r - noiseSample, 0.0, 1.0);
	ALBEDO = mix(innerColor, outerColor, 1.0 - mixColor);
	ALPHA = maskColor;
}
