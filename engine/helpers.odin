package engine

import "core:math"
import rl "vendor:raylib"

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

VIEWPORT_WIDTH :: 0.7
VIEWPORT_HEIGHT :: 0.7

VIEWPORTX :: 0.15
VIEWPORTY :: 0.03

CELL_SIZE :: 10

index :: proc(row, col, w: i32) -> i32 {
	return row * w + col
}

get_viewport_size :: proc(w, h: i32) -> (f32, f32) {
	return f32(w) * VIEWPORT_WIDTH, f32(h) * VIEWPORT_HEIGHT
}
snap_to_grid :: proc(pos: rl.Vector2) -> (i32, i32) {
	return cast(i32)math.round(pos.x / CELL_SIZE),
		cast(i32)math.round(pos.y / CELL_SIZE)
}

dim_to_pos :: proc(row, col: i32) -> rl.Vector2 {
	px := cast(f32)col * CELL_SIZE
	py := cast(f32)row * CELL_SIZE
	return rl.Vector2{px, py}
}
