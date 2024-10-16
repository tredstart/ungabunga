package engine

import ub "../particles"
import "core:math"
import rl "vendor:raylib"

Brush :: struct {
	color: rl.Color,
	size:  i32,
}


draw_brush :: proc(canvas: Canvas, brush: ^Brush) {
	mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), canvas.camera)
	assert(brush.size > 0)
	left := mouse_world.x - f32(brush.size / 2) * CELL_SIZE * canvas.camera.zoom
	top := mouse_world.y - f32(brush.size / 2) * CELL_SIZE * canvas.camera.zoom
	for i in 0 ..< brush.size {
		for j in 0 ..< brush.size {
			rl.DrawRectangleRec(
				{
					left + CELL_SIZE * canvas.camera.zoom * f32(j),
					top + CELL_SIZE * canvas.camera.zoom * f32(i),
					CELL_SIZE * canvas.camera.zoom,
					CELL_SIZE * canvas.camera.zoom,
				},
				brush.color,
			)
		}
	}
}
