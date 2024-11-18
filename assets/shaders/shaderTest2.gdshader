shader_type canvas_item;

uniform float a = 1.0;
uniform float b = 2.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	b < 0.5 ? (2.0 * a * b) : (1.0 - 2.0 * (1.0 - a) * (1.0 - b));
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
