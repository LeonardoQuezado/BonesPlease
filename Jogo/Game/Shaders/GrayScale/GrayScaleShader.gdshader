shader_type canvas_item;

void fragment() {
	vec4 main_tx = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = (main_tx.r + main_tx.g + main_tx.b) / 3.0;
	COLOR = vec4(avg, avg, avg, 1.0);
}