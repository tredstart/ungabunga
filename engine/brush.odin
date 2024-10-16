package engine

import rl "vendor:raylib"

Brush :: struct {
	color: rl.Color,
	size:  u32,
}

draw_brush :: proc(canvas: Canvas, brush: Brush) {
	mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), canvas.camera)
	rl.DrawCircleV(mouse_world, f32(brush.size) * CELL_SIZE, brush.color)
}
