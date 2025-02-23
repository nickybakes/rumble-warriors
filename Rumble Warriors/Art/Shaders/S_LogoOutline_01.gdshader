shader_type spatial;
render_mode blend_mix, unshaded, cull_back;
#include "SI_EffectsInclude_01.gdshaderinc"

global uniform float steppedTime;

uniform vec3 color : source_color = vec3(1, 1, 1);


uniform float timeScale = 3.0;
uniform float wiggleScale = 1.0;
uniform float wiggleWaveScale = 1.0;


void vertex() {
	VERTEX = VERTEX + deltaWiggle2D(VERTEX, steppedTime, wiggleScale, wiggleWaveScale);
}

void fragment() {
	ALBEDO = color;
}
