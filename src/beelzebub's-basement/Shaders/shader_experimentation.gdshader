shader_type canvas_item;

uniform int pixel_size : hint_range(1, 64) = 8;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // Get the viewport (screen) size in pixels
    vec2 viewport_size = vec2(textureSize(SCREEN_TEXTURE, 0));

    // Compute absolute pixel coordinates
    vec2 pixel_coord = SCREEN_UV * viewport_size;

    // Snap to grid
    vec2 grid_coord = floor(pixel_coord / float(pixel_size)) * float(pixel_size);

    // Back to normalized UVs
    vec2 uv = grid_coord / viewport_size;

    // Sample the screen behind
    vec4 col = texture(SCREEN_TEXTURE, uv);

    COLOR = col;
}