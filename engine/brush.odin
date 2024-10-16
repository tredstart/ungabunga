package engine

import rl "vendor:raylib"

Brush :: struct {
	color: rl.Color,
	size:  i32,
}

draw_brush :: proc(canvas: Canvas, brush: Brush) {
	mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), canvas.camera)
	assert(brush.size > 0)
	rl.DrawCircleV(mouse_world, f32(brush.size) * CELL_SIZE / 2, brush.color)
}
