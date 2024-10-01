package main

import "core:math"
import ub "particles"
import rl "vendor:raylib"

VIEWPORT_WIDTH :: 0.7
VIEWPORT_HEIGHT :: 0.7

VIEWPORTX :: 0.15
VIEWPORTY :: 30

CELL_SIZE :: 10

index :: proc(row, col, w: i32) -> i32 {
	return row * w + col
}

get_viewport_size :: proc(w, h: i32) -> (f32, f32) {
	return f32(w) * VIEWPORT_WIDTH, f32(h) * VIEWPORT_HEIGHT
}
snap_to_grid :: proc(x, y: f32) -> (i32, i32) {
	col := cast(i32)math.round(x / CELL_SIZE)
	row := cast(i32)math.round(y / CELL_SIZE)
	return row, col
}

dim_to_pos :: proc(row, col: i32) -> rl.Vector2 {
	px := cast(f32)col * CELL_SIZE
	py := cast(f32)row * CELL_SIZE
	return rl.Vector2{px, py}
}

Canvas :: struct {
	panel:     rl.Rectangle,
	particles: []ub.Particle,
	camera:    rl.Camera2D,
}
Frame :: struct {}

draw_canvas :: proc(canvas: ^Canvas) {
	rl.DrawRectangleRec(canvas.panel, rl.LIGHTGRAY)
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
	if wheel != 0 {
		mouse_world := rl.GetScreenToWorld2D(
			rl.GetMousePosition(),
			canvas.camera,
		)
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

	if rl.IsMouseButtonDown(.RIGHT) {
		delta := rl.GetMouseDelta()
		delta = delta * (-1.0 / canvas.camera.zoom)
		canvas.camera.target = canvas.camera.target + delta
	}

	for particle in canvas.particles {
		rl.DrawRectangle(
			i32(particle.pos.x + canvas.panel.x),
			i32(particle.pos.y + canvas.panel.y),
			CELL_SIZE,
			CELL_SIZE,
			{particle.r, particle.g, particle.b, particle.a},
		)
	}
}

main :: proc() {

	rl.InitWindow(1920, 1000, "Unga bunga")
	defer rl.CloseWindow()
	rl.SetWindowState({.WINDOW_RESIZABLE})

	canvasw, canvash: i32 = 64, 64
	window_width := rl.GetScreenWidth()
	window_height := rl.GetScreenHeight()
	vpsw, vpsh := get_viewport_size(window_width, window_height)

	canvas := Canvas {
		panel     = {VIEWPORTX * f32(window_width), VIEWPORTY, vpsw, vpsh},
		particles = make([]ub.Particle, canvasw * canvash),
	}
	canvas.camera.zoom = 1
	canvas.camera.offset = {
		canvas.panel.x + f32(canvasw) / 2,
		canvas.panel.y + f32(canvash) / 2,
	}

	for i in 0 ..< canvash {
		for j in 0 ..< canvasw {
			canvas.particles[index(i, j, canvasw)] = {
				pos = {f32(CELL_SIZE * j), f32(CELL_SIZE * i)},
				r   = 244,
				g   = 244,
				b   = 244,
				a   = 255,
			}
		}
	}
	defer delete(canvas.particles)

	current_color: rl.Color

	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({100, 100, 100, 255})

		rl.GuiGroupBox({30, 30, 250, 900}, "Objects")
		rl.GuiGroupBox({300, 800, 1200, 200}, "Timeline")
		rl.GuiGroupBox(
			{VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 950},
			"Params",
		)
		draw_canvas(&canvas)


	}

}
