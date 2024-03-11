shader_type spatial;

render_mode unshaded, blend_add;

uniform vec3 uv1_scale = vec3(1.0, 1.0, 1.0);
uniform vec3 uv1_offset = vec3(0.0, 0.0, 0.0);
uniform float variation = 0.0;
varying float elapsed_time;
void vertex() {
	elapsed_time = TIME;
	UV = UV*uv1_scale.xy+uv1_offset.xy;
}
float rand(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}
vec2 rand2(vec2 x) {
    return fract(cos(mod(vec2(dot(x, vec2(13.9898, 8.141)),
						      dot(x, vec2(3.4562, 17.398))), vec2(3.14))) * 43758.5453);
}
vec3 rand3(vec2 x) {
    return fract(cos(mod(vec3(dot(x, vec2(13.9898, 8.141)),
							  dot(x, vec2(3.4562, 17.398)),
                              dot(x, vec2(13.254, 5.867))), vec3(3.14))) * 43758.5453);
}
float param_rnd(float minimum, float maximum, float seed) {
	return minimum+(maximum-minimum)*rand(vec2(seed));
}
vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
	vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}
vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}
float pingpong(float a, float b)
{
  return (b != 0.0) ? abs(fract((a - b) / (b * 2.0)) * b * 2.0 - b) : 0.0;
}
float value_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float p00 = rand(mod(o, size));
	float p01 = rand(mod(o + vec2(0.0, 1.0), size));
	float p10 = rand(mod(o + vec2(1.0, 0.0), size));
	float p11 = rand(mod(o + vec2(1.0, 1.0), size));
	p00 = sin(p00 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p01 = sin(p01 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p10 = sin(p10 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	p11 = sin(p11 * 6.28318530718 + offset * 6.28318530718) / 2.0 + 0.5;
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_value(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = value_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlin_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float a00 = rand(mod(o, size)) * 6.28318530718 + offset * 6.28318530718;
	float a01 = rand(mod(o + vec2(0.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a10 = rand(mod(o + vec2(1.0, 0.0), size)) * 6.28318530718 + offset * 6.28318530718;
	float a11 = rand(mod(o + vec2(1.0, 1.0), size)) * 6.28318530718 + offset * 6.28318530718;
	vec2 v00 = vec2(cos(a00), sin(a00));
	vec2 v01 = vec2(cos(a01), sin(a01));
	vec2 v10 = vec2(cos(a10), sin(a10));
	vec2 v11 = vec2(cos(a11), sin(a11));
	float p00 = dot(v00, f);
	float p01 = dot(v01, f - vec2(0.0, 1.0));
	float p10 = dot(v10, f - vec2(1.0, 0.0));
	float p11 = dot(v11, f - vec2(1.0, 1.0));
	vec2 t =  f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
	return 0.5 + mix(mix(p00, p10, t.x), mix(p01, p11, t.x), t.y);
}
float fbm_2d_perlin(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlin_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float perlinabs_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	return abs(2.0*perlin_noise_2d(coord, size, offset, seed)-1.0);
}
float fbm_2d_perlinabs(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = perlinabs_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float fbm_2d_mod289(float x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}
float fbm_2d_permute(float x) {
	return fbm_2d_mod289(((x * 34.0) + 1.0) * x);
}
vec2 fbm_2d_rgrad2(vec2 p, float rot, float seed) {
	float u = fbm_2d_permute(fbm_2d_permute(p.x) + p.y) * 0.0243902439 + rot; // Rotate by shift
	u = fract(u) * 6.28318530718; // 2*pi
	return vec2(cos(u), sin(u));
}
float simplex_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	coord *= 2.0; // needed for it to tile
	coord += rand2(vec2(seed, 1.0-seed)) + size;
	size *= 2.0; // needed for it to tile
	coord.y += 0.001;
	vec2 uv = vec2(coord.x + coord.y*0.5, coord.y);
	vec2 i0 = floor(uv);
	vec2 f0 = fract(uv);
	vec2 i1 = (f0.x > f0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
	vec2 p0 = vec2(i0.x - i0.y * 0.5, i0.y);
	vec2 p1 = vec2(p0.x + i1.x - i1.y * 0.5, p0.y + i1.y);
	vec2 p2 = vec2(p0.x + 0.5, p0.y + 1.0);
	i1 = i0 + i1;
	vec2 i2 = i0 + vec2(1.0, 1.0);
	vec2 d0 = coord - p0;
	vec2 d1 = coord - p1;
	vec2 d2 = coord - p2;
	vec3 xw = mod(vec3(p0.x, p1.x, p2.x), size.x);
	vec3 yw = mod(vec3(p0.y, p1.y, p2.y), size.y);
	vec3 iuw = xw + 0.5 * yw;
	vec3 ivw = yw;
	vec2 g0 = fbm_2d_rgrad2(vec2(iuw.x, ivw.x), offset, seed);
	vec2 g1 = fbm_2d_rgrad2(vec2(iuw.y, ivw.y), offset, seed);
	vec2 g2 = fbm_2d_rgrad2(vec2(iuw.z, ivw.z), offset, seed);
	vec3 w = vec3(dot(g0, d0), dot(g1, d1), dot(g2, d2));
	vec3 t = 0.8 - vec3(dot(d0, d0), dot(d1, d1), dot(d2, d2));
	t = max(t, vec3(0.0));
	vec3 t2 = t * t;
	vec3 t4 = t2 * t2;
	float n = dot(t4, w);
	return 0.5 + 5.5 * n;
}
float fbm_2d_simplex(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = simplex_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node =  0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718 * node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular2_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = length(diff);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular2(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular2_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular3_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular3(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular3_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular4_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = abs((diff).x) + abs((diff).y);
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular4(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular4_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular5_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.5 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			min_dist = min(min_dist, dist);
		}
	}
	return min_dist;
}
float fbm_2d_cellular5(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular5_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
float cellular6_noise_2d(vec2 coord, vec2 size, float offset, float seed) {
	vec2 o = floor(coord)+rand2(vec2(seed, 1.0-seed))+size;
	vec2 f = fract(coord);
	float min_dist1 = 2.0;
	float min_dist2 = 2.0;
	for(float x = -1.0; x <= 1.0; x++) {
		for(float y = -1.0; y <= 1.0; y++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 node = rand2(mod(o + vec2(x, y), size)) + vec2(x, y);
			node = 0.5 + 0.25 * sin(offset * 6.28318530718 + 6.28318530718*node);
			vec2 diff = neighbor + node - f;
			float dist = max(abs((diff).x), abs((diff).y));
			if (min_dist1 > dist) {
				min_dist2 = min_dist1;
				min_dist1 = dist;
			} else if (min_dist2 > dist) {
				min_dist2 = dist;
			}
		}
	}
	return min_dist2-min_dist1;
}
float fbm_2d_cellular6(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = cellular6_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
// MIT License Inigo Quilez - https://www.shadertoy.com/view/Xd23Dh
float voronoise_noise_2d( vec2 coord, vec2 size, float offset, float seed) {
	vec2 i = floor(coord) + rand2(vec2(seed, 1.0-seed)) + size;
	vec2 f = fract(coord);
	
	vec2 a = vec2(0.0);
	
	for( int y=-2; y<=2; y++ ) {
		for( int x=-2; x<=2; x++ ) {
			vec2  g = vec2( float(x), float(y) );
			vec3  o = rand3( mod(i + g, size) + vec2(seed) );
			o.xy += 0.25 * sin(offset * 6.28318530718 + 6.28318530718*o.xy);
			vec2  d = g - f + o.xy;
			float w = pow( 1.0-smoothstep(0.0, 1.414, length(d)), 1.0 );
			a += vec2(o.z*w,w);
		}
	}
	
	return a.x/a.y;
}
float fbm_2d_voronoise(vec2 coord, vec2 size, int folds, int octaves, float persistence, float offset, float seed) {
	float normalize_factor = 0.0;
	float value = 0.0;
	float scale = 1.0;
	for (int i = 0; i < octaves; i++) {
		float noise = voronoise_noise_2d(coord*size, size, offset, seed);
		for (int f = 0; f < folds; ++f) {
			noise = abs(2.0*noise-1.0);
		}
		value += noise * scale;
		normalize_factor += scale;
		size *= 2.0;
		scale *= persistence;
	}
	return value / normalize_factor;
}
vec2 transform2_clamp(vec2 uv) {
	return clamp(uv, vec2(0.0), vec2(1.0));
}
vec2 transform2(vec2 uv, vec2 translate, float rotate, vec2 scale) {
 	vec2 rv;
	uv -= translate;
	uv -= vec2(0.5);
	rv.x = cos(rotate)*uv.x + sin(rotate)*uv.y;
	rv.y = -sin(rotate)*uv.x + cos(rotate)*uv.y;
	rv /= scale;
	rv += vec2(0.5);
	return rv;	
}
float shape_circle(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float distance = length(uv);
	return clamp((1.0-distance/size)/edge, 0.0, 1.0);
}
float shape_polygon(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y)+3.14159265359;
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(0.5+angle/slice)*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = atan(uv.x, uv.y);
	float slice = 6.28318530718/sides;
	return clamp((1.0-(cos(floor(angle*sides/6.28318530718-0.5+2.0*step(fract(angle*sides/6.28318530718), 0.5))*slice-angle)*length(uv))/size)/edge, 0.0, 1.0);
}
float shape_curved_star(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = max(edge, 1.0e-8);
	float angle = 2.0*(atan(uv.x, uv.y)+3.14159265359);
	float slice = 6.28318530718/sides;
	return clamp((1.0-cos(floor(0.5+0.5*angle/slice)*2.0*slice-angle)*length(uv)/size)/edge, 0.0, 1.0);
}
float shape_rays(vec2 uv, float sides, float size, float edge) {
	uv = 2.0*uv-1.0;
	edge = 0.5*max(edge, 1.0e-8)*size;
	float slice = 6.28318530718/sides;
	float angle = mod(atan(uv.x, uv.y)+3.14159265359, slice)/slice;
	return clamp(min((size-angle)/edge, angle/edge), 0.0, 1.0);
}
vec2 get_from_tileset(float count, float seed, vec2 uv) {
	return clamp((uv+floor(rand2(vec2(seed))*count))/count, vec2(0.0), vec2(1.0));
}
vec2 custom_uv_transform(vec2 uv, vec2 cst_scale, float rnd_rotate, float rnd_scale, vec2 seed) {
	seed = rand2(seed);
	uv -= vec2(0.5);
	float angle = (seed.x * 2.0 - 1.0) * rnd_rotate;
	float ca = cos(angle);
	float sa = sin(angle);
	uv = vec2(ca*uv.x+sa*uv.y, -sa*uv.x+ca*uv.y);
	uv *= (seed.y-0.5)*2.0*rnd_scale+1.0;
	uv /= cst_scale;
	uv += vec2(0.5);
	return uv;
}
vec3 blend_normal(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1 + (1.0-opacity)*c2;
}
vec3 blend_dissolve(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	if (rand(uv) < opacity) {
		return c1;
	} else {
		return c2;
	}
}
vec3 blend_multiply(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*c1*c2 + (1.0-opacity)*c2;
}
vec3 blend_screen(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*(1.0-(1.0-c1)*(1.0-c2)) + (1.0-opacity)*c2;
}
float blend_overlay_f(float c1, float c2) {
	return (c1 < 0.5) ? (2.0*c1*c2) : (1.0-2.0*(1.0-c1)*(1.0-c2));
}
vec3 blend_overlay(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_overlay_f(c1.x, c2.x), blend_overlay_f(c1.y, c2.y), blend_overlay_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_hard_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*0.5*(c1*c2+blend_overlay(uv, c1, c2, 1.0)) + (1.0-opacity)*c2;
}
float blend_soft_light_f(float c1, float c2) {
	return (c2 < 0.5) ? (2.0*c1*c2+c1*c1*(1.0-2.0*c2)) : 2.0*c1*(1.0-c2)+sqrt(c1)*(2.0*c2-1.0);
}
vec3 blend_soft_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_soft_light_f(c1.x, c2.x), blend_soft_light_f(c1.y, c2.y), blend_soft_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_burn_f(float c1, float c2) {
	return (c1==0.0)?c1:max((1.0-((1.0-c2)/c1)),0.0);
}
vec3 blend_burn(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_burn_f(c1.x, c2.x), blend_burn_f(c1.y, c2.y), blend_burn_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_dodge_f(float c1, float c2) {
	return (c1==1.0)?c1:min(c2/(1.0-c1),1.0);
}
vec3 blend_dodge(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_dodge_f(c1.x, c2.x), blend_dodge_f(c1.y, c2.y), blend_dodge_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
vec3 blend_lighten(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*max(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_darken(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*min(c1, c2) + (1.0-opacity)*c2;
}
vec3 blend_difference(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*clamp(c2-c1, vec3(0.0), vec3(1.0)) + (1.0-opacity)*c2;
}
vec3 blend_additive(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + c1 * oppacity;
}
vec3 blend_addsub(vec2 uv, vec3 c1, vec3 c2, float oppacity) {
	return c2 + (c1 - .5) * 2.0 * oppacity;
}
float blend_linear_light_f(float c1, float c2) {
	return (c1 + 2.0 * c2) - 1.0;
}
vec3 blend_linear_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
return opacity*vec3(blend_linear_light_f(c1.x, c2.x), blend_linear_light_f(c1.y, c2.y), blend_linear_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_vivid_light_f(float c1, float c2) {
	return (c1 < 0.5) ? 1.0 - (1.0 - c2) / (2.0 * c1) : c2 / (2.0 * (1.0 - c1));
}
vec3 blend_vivid_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_vivid_light_f(c1.x, c2.x), blend_vivid_light_f(c1.y, c2.y), blend_vivid_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_pin_light_f( float c1, float c2) {
	return (2.0 * c1 - 1.0 > c2) ? 2.0 * c1 - 1.0 : ((c1 < 0.5 * c2) ? 2.0 * c1 : c2);
}
vec3 blend_pin_light(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_pin_light_f(c1.x, c2.x), blend_pin_light_f(c1.y, c2.y), blend_pin_light_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_hard_mix_f(float c1, float c2) {
	return floor(c1 + c2);
}
vec3 blend_hard_mix(vec2 uv, vec3 c1, vec3 c2, float opacity) {
		return opacity*vec3(blend_hard_mix_f(c1.x, c2.x), blend_hard_mix_f(c1.y, c2.y), blend_hard_mix_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float blend_exclusion_f(float c1, float c2) {
	return c1 + c2 - 2.0 * c1 * c2;
}
vec3 blend_exclusion(vec2 uv, vec3 c1, vec3 c2, float opacity) {
	return opacity*vec3(blend_exclusion_f(c1.x, c2.x), blend_exclusion_f(c1.y, c2.y), blend_exclusion_f(c1.z, c2.z)) + (1.0-opacity)*c2;
}
float sdRipples(float d, float w, int r) {
	for (int i = 0; i < r; ++i) {
		d = abs(d)-w;
	}
	return d;
}
vec2 scale(vec2 uv, vec2 center, vec2 scale) {
	uv -= center;
	uv /= scale;
	uv += center;
	return uv;
}
const float p_o155430_cx = 0.000000000;
const float p_o155430_cy = 0.000000000;
const float p_o155430_scale_x = 0.700000000;
const float p_o155430_scale_y = 0.700000000;
const float p_o155390_amount1 = 1.280000000;
const float p_o155402_amount1 = 0.130000000;
const float p_o155400_amount1 = 1.000000000;
const float p_o155406_default_in1 = 0.000000000;
const float p_o155406_default_in2 = 0.000000000;
const float p_o155389_default_in1 = 0.000000000;
const float p_o155389_default_in2 = 0.000000000;
const float p_o155408_default_in1 = 0.000000000;
const float p_o155408_default_in2 = 0.000000000;
const float p_o155369_radius = 1.360000000;
const float p_o155369_repeat = 1.000000000;
const float p_o155370_translate_x = 0.000000000;
const float p_o155370_translate_y = -1.000000000;
const float p_o155370_rotate = 0.000000000;
const float p_o155370_scale_x = 1.000000000;
const float p_o155370_scale_y = 1.000000000;
const float p_o155384_default_in1 = 2.000000000;
const float p_o155384_default_in2 = 0.000000000;
const float p_o155371_repeat = 1.000000000;
const float p_o155371_rotate = 90.000000000;
const float p_o155371_gradient_0_pos = 0.000000000;
const vec4 p_o155371_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o155371_gradient_1_pos = 1.000000000;
const vec4 p_o155371_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o155371_gradient_gradient_fct(float x) {
  if (x < p_o155371_gradient_0_pos) {
    return p_o155371_gradient_0_col;
  } else if (x < p_o155371_gradient_1_pos) {
    return mix(p_o155371_gradient_0_col, p_o155371_gradient_1_col, ((x-p_o155371_gradient_0_pos)/(p_o155371_gradient_1_pos-p_o155371_gradient_0_pos)));
  }
  return p_o155371_gradient_1_col;
}
const float p_o155385_translate_x = 0.000000000;
const float p_o155385_rotate = 0.000000000;
const float p_o155385_scale_x = 1.000000000;
const float p_o155385_scale_y = 1.000000000;
const float p_o155387_value = 0.496100000;
const float p_o155387_width = 0.240000000;
const float p_o155387_contrast = 0.000000000;
const float p_o155391_amount = 0.095000000;
const float p_o155391_eps = 0.100000000;
const float seed_o155386 = 0.323758483;
const float p_o155386_scale_x = 15.000000000;
const float p_o155386_scale_y = 11.000000000;
const float p_o155386_folds = 0.000000000;
const float p_o155386_iterations = 5.000000000;
const float p_o155386_persistence = 0.280000000;
const float p_o155386_offset = 0.000000000;
float o155391_input_d(vec2 uv, float _seed_variation_) {
float o155386_0_1_f = fbm_2d_voronoise((uv), vec2(p_o155386_scale_x, p_o155386_scale_y), int(p_o155386_folds), int(p_o155386_iterations), p_o155386_persistence, p_o155386_offset, (seed_o155386+fract(_seed_variation_)));
return o155386_0_1_f;
}
vec2 o155391_slope(vec2 uv, float epsilon, float _seed_variation_) {
	return vec2(o155391_input_d(fract(uv+vec2(epsilon, 0.0)), _seed_variation_)-o155391_input_d(fract(uv-vec2(epsilon, 0.0)), _seed_variation_), o155391_input_d(fract(uv+vec2(0.0, epsilon)), _seed_variation_)-o155391_input_d(fract(uv-vec2(0.0, epsilon)), _seed_variation_));
}const float p_o155409_default_in1 = 0.000000000;
const float p_o155409_default_in2 = 3.000000000;
const float seed_o155407 = 0.000000000;
const float p_o155407_v1 = 0.000000000;
const float p_o155407_v2 = 0.100000000;
const float p_o155407_v3 = 0.200000000;
const float p_o155407_v4 = 0.300000000;
const float p_o155407_v5 = 0.400000000;
float o155407_input_in(vec2 uv, float _seed_variation_) {
float o155371_0_r = 0.5+(cos(p_o155371_rotate*0.01745329251)*((vec2(fract(p_o155369_repeat*atan((uv).y-0.5, (uv).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((uv)-vec2(0.5))))).x-0.5)+sin(p_o155371_rotate*0.01745329251)*((vec2(fract(p_o155369_repeat*atan((uv).y-0.5, (uv).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((uv)-vec2(0.5))))).y-0.5))/(cos(abs(mod(p_o155371_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o155371_0_1_rgba = o155371_gradient_gradient_fct(fract(o155371_0_r*p_o155371_repeat));
float o155384_0_clamp_false = p_o155384_default_in1/(dot((o155371_0_1_rgba).rgb, vec3(1.0))/3.0);
float o155384_0_clamp_true = clamp(o155384_0_clamp_false, 0.0, 1.0);
float o155384_0_2_f = o155384_0_clamp_false;
vec2 o155391_0_slope = o155391_slope((fract(transform2((fract(transform2((vec2(fract(p_o155369_repeat*atan((uv).y-0.5, (uv).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((uv)-vec2(0.5))))), vec2(p_o155370_translate_x*(2.0*1.0-1.0), p_o155370_translate_y*(2.0*1.0-1.0)), p_o155370_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155370_scale_x*(2.0*1.0-1.0), p_o155370_scale_y*(2.0*o155384_0_2_f-1.0))))), vec2(p_o155385_translate_x*(2.0*1.0-1.0), (elapsed_time*.2)*(2.0*1.0-1.0)), p_o155385_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155385_scale_x*(2.0*1.0-1.0), p_o155385_scale_y*(2.0*1.0-1.0))))), p_o155391_eps, _seed_variation_);
vec2 o155391_0_warp = o155391_0_slope;float o155386_0_1_f = fbm_2d_voronoise(((fract(transform2((fract(transform2((vec2(fract(p_o155369_repeat*atan((uv).y-0.5, (uv).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((uv)-vec2(0.5))))), vec2(p_o155370_translate_x*(2.0*1.0-1.0), p_o155370_translate_y*(2.0*1.0-1.0)), p_o155370_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155370_scale_x*(2.0*1.0-1.0), p_o155370_scale_y*(2.0*o155384_0_2_f-1.0))))), vec2(p_o155385_translate_x*(2.0*1.0-1.0), (elapsed_time*.2)*(2.0*1.0-1.0)), p_o155385_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155385_scale_x*(2.0*1.0-1.0), p_o155385_scale_y*(2.0*1.0-1.0)))))+p_o155391_amount*o155391_0_warp), vec2(p_o155386_scale_x, p_o155386_scale_y), int(p_o155386_folds), int(p_o155386_iterations), p_o155386_persistence, p_o155386_offset, (seed_o155386+fract(_seed_variation_)));
vec4 o155391_0_1_rgba = vec4(vec3(o155386_0_1_f), 1.0);
float o155387_0_step = clamp(((dot((o155391_0_1_rgba).rgb, vec3(1.0))/3.0) - (p_o155387_value))/max(0.0001, p_o155387_width)+0.5, 0.0, 1.0);
float o155387_0_false = clamp((min(o155387_0_step, 1.0-o155387_0_step) * 2.0) / (1.0 - p_o155387_contrast), 0.0, 1.0);
float o155387_0_true = 1.0-o155387_0_false;float o155387_0_1_f = o155387_0_false;
vec4 o155385_0_1_rgba = vec4(vec3(o155387_0_1_f), 1.0);
vec4 o155370_0_1_rgba = o155385_0_1_rgba;
vec4 o155369_0_1_rgba = o155370_0_1_rgba;
return (dot((o155369_0_1_rgba).rgb, vec3(1.0))/3.0);
}
const float p_o155388_sides = 6.000000000;
const float p_o155388_radius = 0.720000000;
const float p_o155388_edge = 1.020000000;
const float p_o155405_default_in1 = 0.000000000;
const float p_o155405_default_in2 = 0.000000000;
const float p_o155412_default_in1 = 0.000000000;
const float p_o155412_default_in2 = 0.000000000;
const float p_o155411_default_in1 = 0.000000000;
const float p_o155411_default_in2 = 0.537500000;
const float p_o155415_default_in1 = 0.000000000;
const float p_o155415_default_in2 = 0.400000000;
const float p_o155414_value = 0.231900000;
const float p_o155414_width = 0.652600000;
const float p_o155414_contrast = 0.000000000;
const float seed_o155416 = 0.000000000;
const float p_o155416_sx = 1.000000000;
const float p_o155416_sy = 1.000000000;
const float p_o155416_rotate = 0.000000000;
const float p_o155416_scale = 0.000000000;
const float seed_o155410 = 0.000000000;
const float p_o155410_scale_x = 19.000000000;
const float p_o155410_scale_y = 1.000000000;
const float p_o155410_folds = 0.000000000;
const float p_o155410_iterations = 3.000000000;
const float p_o155410_persistence = 0.500000000;
vec4 o155416_input_in(vec2 uv, float _seed_variation_) {
float o155410_0_1_f = fbm_2d_value((uv), vec2(p_o155410_scale_x, p_o155410_scale_y), int(p_o155410_folds), int(p_o155410_iterations), p_o155410_persistence, (elapsed_time*.5), (seed_o155410+fract(_seed_variation_)));
return vec4(vec3(o155410_0_1_f), 1.0);
}
const float p_o155417_repeat = 1.000000000;
const float p_o155417_gradient_0_pos = 0.000000000;
const vec4 p_o155417_gradient_0_col = vec4(0.000000000, 0.000000000, 0.000000000, 1.000000000);
const float p_o155417_gradient_1_pos = 1.000000000;
const vec4 p_o155417_gradient_1_col = vec4(1.000000000, 1.000000000, 1.000000000, 1.000000000);
vec4 o155417_gradient_gradient_fct(float x) {
  if (x < p_o155417_gradient_0_pos) {
    return p_o155417_gradient_0_col;
  } else if (x < p_o155417_gradient_1_pos) {
    return mix(p_o155417_gradient_0_col, p_o155417_gradient_1_col, ((x-p_o155417_gradient_0_pos)/(p_o155417_gradient_1_pos-p_o155417_gradient_0_pos)));
  }
  return p_o155417_gradient_1_col;
}
const float p_o155413_sides = 6.000000000;
const float p_o155413_radius = 1.130000000;
const float p_o155413_edge = 1.020000000;
const float p_o155403_sides = 6.000000000;
const float p_o155403_radius = 1.000000000;
const float p_o155403_edge = 1.000000000;
const vec4 p_o155401_color = vec4(0.203922004, 0.364562988, 0.482353002, 1.000000000);
const vec4 p_o155399_color = vec4(0.318706006, 0.743714988, 1.000000000, 1.000000000);
const float p_o155398_default_in1 = 0.000000000;
const float p_o155398_default_in2 = 64.000000000;
const float p_o155397_bevel = 8.000000000;
const float p_o155397_base = 1.000000000;
const float p_o155396_r = -0.029200000;
const float p_o155396_ripples = 1.000000000;
const float p_o155395_r = 0.400000000;
const float p_o155395_cx = 0.000000000;
const float p_o155395_cy = 0.000000000;
void fragment() {
	float _seed_variation_ = variation;
	vec2 uv = fract(UV);
float o155371_0_r = 0.5+(cos(p_o155371_rotate*0.01745329251)*((vec2(fract(p_o155369_repeat*atan((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).y-0.5, (scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y)))-vec2(0.5))))).x-0.5)+sin(p_o155371_rotate*0.01745329251)*((vec2(fract(p_o155369_repeat*atan((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).y-0.5, (scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y)))-vec2(0.5))))).y-0.5))/(cos(abs(mod(p_o155371_rotate, 90.0)-45.0)*0.01745329251)*1.41421356237);vec4 o155371_0_1_rgba = o155371_gradient_gradient_fct(fract(o155371_0_r*p_o155371_repeat));
float o155384_0_clamp_false = p_o155384_default_in1/(dot((o155371_0_1_rgba).rgb, vec3(1.0))/3.0);
float o155384_0_clamp_true = clamp(o155384_0_clamp_false, 0.0, 1.0);
float o155384_0_2_f = o155384_0_clamp_false;
vec2 o155391_0_slope = o155391_slope((fract(transform2((fract(transform2((vec2(fract(p_o155369_repeat*atan((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).y-0.5, (scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y)))-vec2(0.5))))), vec2(p_o155370_translate_x*(2.0*1.0-1.0), p_o155370_translate_y*(2.0*1.0-1.0)), p_o155370_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155370_scale_x*(2.0*1.0-1.0), p_o155370_scale_y*(2.0*o155384_0_2_f-1.0))))), vec2(p_o155385_translate_x*(2.0*1.0-1.0), (elapsed_time*.2)*(2.0*1.0-1.0)), p_o155385_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155385_scale_x*(2.0*1.0-1.0), p_o155385_scale_y*(2.0*1.0-1.0))))), p_o155391_eps, _seed_variation_);
vec2 o155391_0_warp = o155391_0_slope;float o155386_0_1_f = fbm_2d_voronoise(((fract(transform2((fract(transform2((vec2(fract(p_o155369_repeat*atan((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).y-0.5, (scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).x-0.5)*0.15915494309), min(0.99999, 2.0/p_o155369_radius*length((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y)))-vec2(0.5))))), vec2(p_o155370_translate_x*(2.0*1.0-1.0), p_o155370_translate_y*(2.0*1.0-1.0)), p_o155370_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155370_scale_x*(2.0*1.0-1.0), p_o155370_scale_y*(2.0*o155384_0_2_f-1.0))))), vec2(p_o155385_translate_x*(2.0*1.0-1.0), (elapsed_time*.2)*(2.0*1.0-1.0)), p_o155385_rotate*0.01745329251*(2.0*1.0-1.0), vec2(p_o155385_scale_x*(2.0*1.0-1.0), p_o155385_scale_y*(2.0*1.0-1.0)))))+p_o155391_amount*o155391_0_warp), vec2(p_o155386_scale_x, p_o155386_scale_y), int(p_o155386_folds), int(p_o155386_iterations), p_o155386_persistence, p_o155386_offset, (seed_o155386+fract(_seed_variation_)));
vec4 o155391_0_1_rgba = vec4(vec3(o155386_0_1_f), 1.0);
float o155387_0_step = clamp(((dot((o155391_0_1_rgba).rgb, vec3(1.0))/3.0) - (p_o155387_value))/max(0.0001, p_o155387_width)+0.5, 0.0, 1.0);
float o155387_0_false = clamp((min(o155387_0_step, 1.0-o155387_0_step) * 2.0) / (1.0 - p_o155387_contrast), 0.0, 1.0);
float o155387_0_true = 1.0-o155387_0_false;float o155387_0_1_f = o155387_0_false;
vec4 o155385_0_1_rgba = vec4(vec3(o155387_0_1_f), 1.0);
vec4 o155370_0_1_rgba = o155385_0_1_rgba;
vec4 o155369_0_1_rgba = o155370_0_1_rgba;
float o155407_1_1_f = o155407_input_in((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), (seed_o155407+fract(_seed_variation_))+p_o155407_v2);
float o155409_0_clamp_false = o155407_1_1_f*p_o155409_default_in2;
float o155409_0_clamp_true = clamp(o155409_0_clamp_false, 0.0, 1.0);
float o155409_0_2_f = o155409_0_clamp_false;
float o155408_0_clamp_false = (dot((o155369_0_1_rgba).rgb, vec3(1.0))/3.0)+o155409_0_2_f;
float o155408_0_clamp_true = clamp(o155408_0_clamp_false, 0.0, 1.0);
float o155408_0_1_f = o155408_0_clamp_false;
float o155388_0_1_f = shape_circle((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), p_o155388_sides, p_o155388_radius*1.0, p_o155388_edge*1.0);
float o155389_0_clamp_false = o155408_0_1_f*o155388_0_1_f;
float o155389_0_clamp_true = clamp(o155389_0_clamp_false, 0.0, 1.0);
float o155389_0_1_f = o155389_0_clamp_false;
vec4 o155417_0_1_rgba = o155417_gradient_gradient_fct(fract(p_o155417_repeat*0.15915494309*atan((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).y-0.5, (scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))).x-0.5)));
vec3 o155416_0_map = ((o155417_0_1_rgba).rgb);
float o155416_0_rnd =  float((seed_o155416+fract(_seed_variation_)))+o155416_0_map.z;
vec4 o155416_0_1_rgba = o155416_input_in(get_from_tileset(1.0, o155416_0_rnd, custom_uv_transform(o155416_0_map.xy, vec2(p_o155416_sx, p_o155416_sy), p_o155416_rotate*0.01745329251, p_o155416_scale, vec2(o155416_0_map.z, float((seed_o155416+fract(_seed_variation_)))))), false ? o155416_0_rnd : 0.0);
float o155414_0_step = clamp(((dot((o155416_0_1_rgba).rgb, vec3(1.0))/3.0) - (p_o155414_value))/max(0.0001, p_o155414_width)+0.5, 0.0, 1.0);
float o155414_0_false = clamp((min(o155414_0_step, 1.0-o155414_0_step) * 2.0) / (1.0 - p_o155414_contrast), 0.0, 1.0);
float o155414_0_true = 1.0-o155414_0_false;float o155414_0_1_f = o155414_0_false;
float o155415_0_clamp_false = o155414_0_1_f+p_o155415_default_in2;
float o155415_0_clamp_true = clamp(o155415_0_clamp_false, 0.0, 1.0);
float o155415_0_2_f = o155415_0_clamp_false;
float o155411_0_clamp_false = o155415_0_2_f*p_o155411_default_in2;
float o155411_0_clamp_true = clamp(o155411_0_clamp_false, 0.0, 1.0);
float o155411_0_2_f = o155411_0_clamp_false;
float o155413_0_1_f = shape_circle((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), p_o155413_sides, p_o155413_radius*1.0, p_o155413_edge*1.0);
float o155412_0_clamp_false = o155411_0_2_f*o155413_0_1_f;
float o155412_0_clamp_true = clamp(o155412_0_clamp_false, 0.0, 1.0);
float o155412_0_1_f = o155412_0_clamp_false;
float o155403_0_1_f = shape_circle((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), p_o155403_sides, p_o155403_radius*1.0, p_o155403_edge*1.0);
vec4 o155404_0_1_rgba = vec4(vec3(1.0)-vec4(vec3(o155403_0_1_f), 1.0).rgb, vec4(vec3(o155403_0_1_f), 1.0).a);
float o155405_0_clamp_false = o155412_0_1_f/(dot((o155404_0_1_rgba).rgb, vec3(1.0))/3.0);
float o155405_0_clamp_true = clamp(o155405_0_clamp_false, 0.0, 1.0);
float o155405_0_1_f = o155405_0_clamp_false;
float o155406_0_clamp_false = o155389_0_1_f+o155405_0_1_f;
float o155406_0_clamp_true = clamp(o155406_0_clamp_false, 0.0, 1.0);
float o155406_0_1_f = o155406_0_clamp_false;
vec4 o155401_0_1_rgba = p_o155401_color;
vec4 o155400_0_b = vec4(vec3(o155406_0_1_f), 1.0);
vec4 o155400_0_l;
float o155400_0_a;

o155400_0_l = o155401_0_1_rgba;
o155400_0_a = p_o155400_amount1*1.0;
o155400_0_b = vec4(blend_multiply((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), o155400_0_l.rgb, o155400_0_b.rgb, o155400_0_a*o155400_0_l.a), min(1.0, o155400_0_b.a+o155400_0_a*o155400_0_l.a));

vec4 o155400_0_2_rgba = o155400_0_b;
vec4 o155402_0_b = o155400_0_2_rgba;
vec4 o155402_0_l;
float o155402_0_a;

o155402_0_l = o155400_0_2_rgba;
o155402_0_a = p_o155402_amount1*1.0;
o155402_0_b = vec4(blend_additive((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), o155402_0_l.rgb, o155402_0_b.rgb, o155402_0_a*o155402_0_l.a), min(1.0, o155402_0_b.a+o155402_0_a*o155402_0_l.a));

vec4 o155402_0_2_rgba = o155402_0_b;
vec4 o155399_0_1_rgba = p_o155399_color;
float o155395_0_1_sdf2d = length((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y)))-vec2(p_o155395_cx+0.5, p_o155395_cy+0.5))-p_o155395_r;
float o155396_0_1_sdf2d = sdRipples(o155395_0_1_sdf2d, p_o155396_r, int(p_o155396_ripples));
float o155397_0_1_f = clamp(p_o155397_base-o155396_0_1_sdf2d/max(p_o155397_bevel, 0.00001), 0.0, 1.0);
float o155398_0_clamp_false = pow(o155397_0_1_f,p_o155398_default_in2);
float o155398_0_clamp_true = clamp(o155398_0_clamp_false, 0.0, 1.0);
float o155398_0_2_f = o155398_0_clamp_false;
vec4 o155390_0_b = o155402_0_2_rgba;
vec4 o155390_0_l;
float o155390_0_a;

o155390_0_l = o155399_0_1_rgba;
o155390_0_a = p_o155390_amount1*o155398_0_2_f;
o155390_0_b = vec4(blend_additive((scale((uv), vec2(0.5+p_o155430_cx, 0.5+p_o155430_cy), vec2(p_o155430_scale_x, p_o155430_scale_y))), o155390_0_l.rgb, o155390_0_b.rgb, o155390_0_a*o155390_0_l.a), min(1.0, o155390_0_b.a+o155390_0_a*o155390_0_l.a));

vec4 o155390_0_1_rgba = o155390_0_b;
vec4 o155430_0_1_rgba = o155390_0_1_rgba;

	vec4 color_tex = o155430_0_1_rgba;
	color_tex = mix(pow((color_tex + vec4(0.055)) * (1.0 / (1.0 + 0.055)),vec4(2.4)),color_tex * (1.0 / 12.92),lessThan(color_tex,vec4(0.04045)));
	ALBEDO = color_tex.rgb;
	ALPHA = color_tex.a;

}



