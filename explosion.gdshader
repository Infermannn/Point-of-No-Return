shader_type canvas_item;

void fragment() {
    vec4 col = texture(TEXTURE, UV);
    float brightness = col.r + col.g + col.b;
    if (brightness < 0.1) {
        col.a = 0.0;  // чёрные пиксели становятся прозрачными
    }
    COLOR = col;
}