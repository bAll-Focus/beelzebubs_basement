shader_type spatial;
render_mode skip_vertex_transform, unshaded, blend_mix, depth_draw_opaque;

group_uniforms Basic;
uniform sampler2D my_texture : source_color, filter_nearest, repeat_disable;
uniform vec3 tint : source_color = vec3(1);
uniform bool vertex_snap = true;
group_uniforms;

global uniform vec2 resolution;

group_uniforms AffineTextureMapping;
uniform bool do_affine_mapping = false;
group_uniforms;

varying vec4 clip_position;

void vertex() {
    mat4 model_matrix = MODEL_MATRIX;
    vec4 world_space_pos = model_matrix * vec4(VERTEX, 1);
    vec4 view_pos = VIEW_MATRIX * world_space_pos;
    vec4 clip_pos = PROJECTION_MATRIX * view_pos;
    if (vertex_snap) {
        clip_pos.xy = round(clip_pos.xy / clip_pos.w * resolution) / resolution * clip_pos.w;
    }
    POSITION = clip_pos;
    clip_position = clip_pos;
    NORMAL = MODEL_NORMAL_MATRIX * NORMAL;
    if (do_affine_mapping) {
        UV *= clip_pos.w;
        COLOR *= clip_pos.w;
    }
}

void fragment() {
    vec2 uv = UV;
    vec3 vertex_color = COLOR.rgb;
    if (do_affine_mapping) {
        uv /= clip_position.w;
        vertex_color /= clip_position.w;
    }
    vec4 tex = texture(my_texture, uv);
    vec3 albedo = tex.rgb * vertex_color * tint;

    ALBEDO = albedo;
    ALPHA = tex.a;       
}