shader_type canvas_item;
render_mode unshaded;

uniform sampler2D palette : source_color;

uniform int total_rows = 4;
uniform int total_columns = 4;
uniform int color_row = 1;
uniform vec4 parent_modulation = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
    vec4 old_color = texture(TEXTURE, UV);

    // Determine column index based on red value
    float col_index = floor(old_color.r * float(total_columns));
    float x_coord = (col_index + 0.5) / float(total_columns);

    // Grayscale reference from row 0
    float y_grayscale = (0.0 + 0.5) / float(total_rows);
    vec4 gray_sample = texture(palette, vec2(x_coord, y_grayscale));

    // Swapped color from specified row
    float y_color = (float(color_row) + 0.5) / float(total_rows);
    vec4 color_sample = texture(palette, vec2(x_coord, y_color));

    if (distance(old_color.rgb, gray_sample.rgb) < 0.3) {
        color_sample.a *= old_color.a;
        COLOR = color_sample;
    } else {
        COLOR = old_color;
    }

    COLOR *= parent_modulation;
}
