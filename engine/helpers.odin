package engine

Vector2 :: struct {
	x, y: f64,
}

Rect :: struct {
	x, y: f64,
	w, h: f64,
}

// TODO: move this to a config file
// TODO: make a parsable config file
MAX_PARTICLES :: 5024
Velocity :: 50
SCALE :: 10

scaled :: proc(coord: f64) -> i32 {
	return i32(coord * SCALE)
}
