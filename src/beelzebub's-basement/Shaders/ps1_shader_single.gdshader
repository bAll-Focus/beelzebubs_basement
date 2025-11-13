shader_type spatial;
render_mode skip_vertex_transform, unshaded;

group_uniforms Basic;
uniform sampler2D my_texture : source_color, filter_nearest, repeat_disable;
uniform vec3 tint : source_color = vec3(1);
uniform bool vertex_snap = true;
group_uniforms;

group_uniforms Dithering;
global uniform bool dither = true;
global uniform float dither_spread = 1.0;
global uniform float dither_gamma = 1.0;
group_uniforms;

group_uniforms AffineTextureMapping;
uniform bool do_affine_mapping = false;
group_uniforms;

varying vec4 clip_position;

void vertex() {
	mat4 model_matrix = MODEL_MATRIX;
	vec4 world_space_pos = model_matrix * vec4(VERTEX, 1);
	vec4 view_pos = VIEW_MATRIX * world_space_pos;
	vec4 clip_pos = PROJECTION_MATRIX * view_pos;;
	if (vertex_snap) {
		clip_pos.xy = round(clip_pos.xy / clip_pos.w * VIEWPORT_SIZE.xy) / VIEWPORT_SIZE.xy * clip_pos.w;
	}
	POSITION = clip_pos;
	clip_position = clip_pos;
	NORMAL = MODEL_NORMAL_MATRIX * NORMAL;
	if (do_affine_mapping == true) {
		UV *= clip_pos.w;
		COLOR *= clip_pos.w;
	}
}

void fragment() {
	vec2 uv = UV;
	vec3 vertex_color = COLOR.rgb;
	if(do_affine_mapping) {
		uv /= clip_position.w;
		vertex_color /= clip_position.w;
	}
	vec3 texture_color = texture(my_texture, uv).rgb;
	vec3 albedo = texture_color * vertex_color * tint;
	ALBEDO = albedo;
}