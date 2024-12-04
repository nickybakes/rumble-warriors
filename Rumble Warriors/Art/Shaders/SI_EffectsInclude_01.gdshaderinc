vec3 rotateAroundAxis(vec3 vector, vec3 axis, float angle) {
// RotationByAxis:6
	axis = normalize(axis);
	mat3 rot_matrix = mat3(
		vec3( cos(angle)+axis.x*axis.x*(1.0 - cos(angle)), axis.x*axis.y*(1.0-cos(angle))-axis.z*sin(angle), axis.x*axis.z*(1.0-cos(angle))+axis.y*sin(angle) ),
		vec3( axis.y*axis.x*(1.0-cos(angle))+axis.z*sin(angle), cos(angle)+axis.y*axis.y*(1.0-cos(angle)), axis.y*axis.z*(1.0-cos(angle))-axis.x*sin(angle) ),
		vec3( axis.z*axis.x*(1.0-cos(angle))-axis.y*sin(angle), axis.z*axis.y*(1.0-cos(angle))+axis.x*sin(angle), cos(angle)+axis.z*axis.z*(1.0-cos(angle)) )
	);

	return vector * rot_matrix;
}

float timeCos(float offset, float time, float scale){
	return cos(offset + time * scale);
}

float timeSin(float offset, float time, float scale){
	return sin(offset + time * scale);
}

vec3 hsv2rgb(float hue, float sat, float val){
	vec3 c = vec3(hue, sat, val);
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float map(float value, float min1, float max1, float min2, float max2) {
  return min2 + (value - min1) * (max2 - min2) / (max1 - min1);
}

float remap(float i, float a, float b, float x, float y){
	return mix(x, y, (i-a)/b);
}

float saturate(float t){
	return clamp(t, 0.0, 1.0);
}

vec2 tone(vec3 vertex){
	vec2 camCoord = (rotateAroundAxis(vertex, vec3(0, 0, 1), .785).xy + vec2(.5, .5)) * vec2(40, 40);
	float sine = abs(sin(camCoord.x));
	float cosine = abs(cos(camCoord.y));
	return vec2(sine, cosine * sine);
}

float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0 )), amount);
}