package engine

import ub "../particles"
import "core:log"
import rl "vendor:raylib"

Canvas :: struct {
	panel:            rl.Rectangle,
	particles:        []ub.Particle,
	camera:           rl.Camera2D,
	canvasw, canvash: i32,
	current_color:    rl.Color,
}
Frame :: struct {}
handle_zoom :: proc(canvas: ^Canvas, mouse_world: rl.Vector2, wheel: f32) {
	if wheel != 0 {
		canvas.camera.offset = rl.GetMousePosition()
		canvas.camera.target = mouse_world

		scale_factor := 1.0 + (0.25 * abs(wheel))
		if wheel < 0 {
			scale_factor = 1 / scale_factor
		}
		canvas.camera.zoom = clamp(
			canvas.camera.zoom * scale_factor,
			0.125,
			64.0,
		)
	}
}

handle_draw :: proc(canvas: ^Canvas, mouse_world: rl.Vector2) {
	if rl.IsMouseButtonDown(.LEFT) {
		row, col := snap_to_grid(mouse_world)
		if row >= 0 &&
		   col >= 0 &&
		   row < canvas.canvash &&
		   col < canvas.canvasw {
			id := index(col, row, canvas.canvasw)
			prev := canvas.particles[id]
			pp_pos := dim_to_pos(col, row)
			pp := ub.Particle {
				pos   = pp_pos,
				color = canvas.current_color,
			}
			canvas.particles[id] = pp
		}
	}

}

handle_canvas_drag :: proc(canvas: ^Canvas) {
	if rl.IsMouseButtonDown(.RIGHT) {
		delta := rl.GetMouseDelta()
		delta = delta * (-1.0 / canvas.camera.zoom)
		canvas.camera.target = canvas.camera.target + delta
	}
}

draw_canvas :: proc(canvas: ^Canvas) {
	rl.DrawRectangleRec(canvas.panel, rl.DARKGRAY)
	rl.BeginScissorMode(
		i32(canvas.panel.x),
		i32(canvas.panel.y),
		i32(canvas.panel.width),
		i32(canvas.panel.height),
	)
	rl.BeginMode2D(canvas.camera)
	defer rl.EndMode2D()
	defer rl.EndScissorMode()

	wheel := rl.GetMouseWheelMove()
	mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), canvas.camera)

	handle_zoom(canvas, mouse_world, wheel)
	handle_draw(canvas, mouse_world)
	handle_canvas_drag(canvas)

	for particle in canvas.particles {
		rl.DrawRectangle(
			i32(particle.pos.x),
			i32(particle.pos.y),
			CELL_SIZE,
			CELL_SIZE,
			particle.color,
		)
	}

	// TODO: remove this after debugging is finished or set it under debug flag
	rl.DrawRectangleV(mouse_world, {10, 10}, rl.RED)
	rl.DrawLine(
		i32(canvas.camera.target.x),
		-i32(canvas.panel.height) * 10,
		i32(canvas.camera.target.x),
		i32(canvas.panel.height) * 10,
		rl.GREEN,
	)
	rl.DrawLine(
		-i32(canvas.panel.width) * 10,
		i32(canvas.camera.target.y),
		i32(canvas.panel.width) * 10,
		i32(canvas.camera.target.y),
		rl.GREEN,
	)
}
