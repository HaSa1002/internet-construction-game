shader_type canvas_item;

const float PI = 3.14159265358979323846;
const float TWO_PI = 6.28318530718;

uniform vec2 mouse;
uniform float delta;
uniform float rects;

/// 	HaSa Function Library
/// My collected Function Library

/// Implement:
/// Polynomial Shaping Functions: www.flong.com/texts/code/shapers_poly
/// Exponential Shaping Functions: www.flong.com/texts/code/shapers_exp
/// Circular & Elliptical Shaping Functions: www.flong.com/texts/code/shapers_circ
/// Bezier and Other Parametric Shaping Functions: www.flong.com/texts/code/shapers_bez


/// RGB to HSV
/// copied from https://thebookofshaders.com/06/
vec4 hfl_rgb2hsv(in vec4 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r),vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec4(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x, c.a);
}


/// HSV to RGB
/// copied from https://www.shadertoy.com/view/MsS3Wc
vec4 hfl_hsv2rgb(in vec4 c) {
	vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0), 6.0)-3.0)-1.0, 0.0, 1.0 );
	rgb = rgb*rgb*(3.0-2.0*rgb);
	return vec4(c.z * mix(vec3(1.0), rgb, c.y), c.a);
}


/// Almost Identity 1
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_aI(float x, float threshold, float approx) {
	if (x>threshold) return x;
	float a = 2.0*approx - threshold;
	float b = 2.0*threshold - 3.0*approx;
	float t = x / threshold;
	return (a*t + b)*t*t + approx;
}

/// Almost Identity 2
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_aI_sqrt(float x, float approx) {
	return sqrt(x*x + approx);
}


/// Almost Unit Identity
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_aI_unit(float x) {
	return x*x*(2.0 - x);
}


/// Exponential Impulse
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_expImp(float x, float k) {
	float h = k*x;
	return h*exp(1.0-h);
}


/// Sustained Impulse
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_expSImp(float x, float k, float f) {
	float s = max(x-f,0.0);
	return min(x*x/(f*f), 1.0+(2.0/f)*s*exp((-k)*s));
}


/// Polynomial Impulse
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_polyImp(float x, float k, float n) {
	return (n/(n-1.0)) * pow((n-1.0)*k,1.0/n) * x/(1.0+k*pow(x,n));
}


/// Cubic Pulse
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_cPul(float x, float center, float width) {
	x = abs(x-center);
	if (x > width) return 0.0;
	x /= width;
	return 1.0 - x*x*(3.0 - 2.0*x);
}


/// Exponential Step
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_expStep(float x, float k, float n) {
	return exp(-k*pow(x,n));
}


/// Gain
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_gain(float x, float k) {
	float a = 0.5*pow(2.0*((x<0.5)?x:1.0-x), k);
	return (x<0.5)?a:1.0-a;
}


/// Parabola
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_parabola(float x, float k) {
	return pow(4.0*x*(1.0-x), k);
}


/// Power Curve
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_pcurve(float x, float a, float b) {
	float k = pow(a+b,a+b) / (pow(a,a)*pow(b,b));
	return k * pow( x, a ) * pow( 1.0-x, b );
}


/// Sinc curve
/// copied from http://www.iquilezles.org/www/articles/functions/functions.htm
float hfl_sinc(float x, float k) {
	float a = PI*(k*x-1.0);
	return sin(a)/a;
}


/// Full Rect
float hfl_rect_full(vec2 p, float width, float curveture) {
	vec2 tl = smoothstep(width, curveture, p);
	vec2 br = smoothstep(width, curveture, 1.0-p);
	return  tl.x * tl.y * br.x * br.y;
}

// Line
float hfl_line(float p, float line_width, float blur, float offset) {
	return smoothstep(line_width, blur, offset + p);
}


/// Rect
float hfl_rect(vec2 p, float line_width, float curveture, vec4 offset) {
	vec2 tl = smoothstep(line_width, curveture, p - offset.xy);
	vec2 br = smoothstep(line_width, curveture, 1.0 - offset.zw - p);
	return  tl.x * tl.y * br.x * br.y;
}


/// Rect Outline
float hfl_rect_outline(vec2 p, float width, float curveture) {
	vec2 tl = smoothstep(width, curveture, p);
	vec2 br = smoothstep(width, curveture, 1.0-p);
	return  1.0 - (tl.x * tl.y * br.x * br.y);
}



float plot(vec2 p, float pct){
	return smoothstep( pct-0.02, pct, p.y) - smoothstep( pct, pct+0.02, p.y);
}


float doubleGradient(float p, float start, float end, float max1, float max2) {
	return smoothstep(start, max1, p) - smoothstep(max2, end, p);
}



void fragment() {
	vec2 p = fract(UV*rects);
	
	vec3 color = vec3(.0,.0,.4);
	color *= step(0.01, sin(p.x));
	color *= step(0.01, sin(p.y));

	if (color.b == .0) {
		float r = step(.9, p.x);
		float b = step(.9, p.y);
		float l = step(.9, 1.0-p.x);
		float _t = step(.9, 1.0-p.y);
		color = vec3(.0,.0,.6) * l * _t;
		if (color.b == .0) {
			color = vec3(.0,.0,.6) * r;
			if (color.b == .0) {
				color = vec3(.0,.0,.6) * b;
			}
			
		}
		if (color.b == .0) {
			color = vec3(.0,.0,.5);
			color += vec3(.2,.2,.1) * smoothstep(0.93, 1., 1.-distance(UV, mouse)*0.5)
		} else {
			color += vec3(.5,.5,.5) * smoothstep(0.93, 1., 1.-distance(UV, mouse)*0.5)
		}
	}
	
	color *= 1.-distance(UV, mouse)*0.5;
	
	COLOR = vec4(color, 1.0);
}







