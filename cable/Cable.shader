shader_type canvas_item;

uniform bool broken;
uniform vec2 mouse_pos;
uniform float workload;
uniform float size;
uniform vec2 scale;

/// Cubic Pulse
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_cPul(float x, float center, float width) {
	x = abs(x-center);
	if (x > width) return 0.0;
	x /= width;
	return 1.0 - x*x*(3.0 - 2.0*x);
}

//copied from https://thebookofshaders.com/07/
float circle(in vec2 _st, in float _radius){
    vec2 dist = _st-vec2(0.5);
	return 1.-smoothstep(_radius-(_radius*0.01),
                         _radius+(_radius*0.01),
                         dot(dist,dist)*4.0);
}


void fragment() {
	
	COLOR = vec4(1.0, 1.0, 1.0, 1.0);
	float broken_mask = 1.- hfl_cPul(UV.x, .5, .333333);
	
	float center = 1.- step(0.5, hfl_cPul(UV.y, .5, size));
	float center_safe = 1.- step(0.5, hfl_cPul(UV.y, .5, size-.01));
	COLOR *= center;
	if (center < 1.0) {
		/*
		//vec2 t = vec2(mod((TIME), 6.0)-3., 0.0);
		//p *= .35 * fract(UV * scale);
		vec2 p = fract(UV * scale);
		//p -= t * .35;
		float circle = circle(p, 0.9);
		COLOR += vec4(circle);
		COLOR += vec4(p, 1., 1.);
		*/
	}
	if (broken) {
		COLOR.a *= broken_mask;
	}
	
}