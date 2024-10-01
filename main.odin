package main

import "core:log"
import "core:math"
import ub "particles"
import rl "vendor:raylib"

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

Canvas :: struct {
	panel:            rl.Rectangle,
	particles:        []ub.Particle,
	camera:           rl.Camera2D,
	canvasw, canvash: i32,
	current_color:    rl.Color,
}
Frame :: struct {}

draw_canvas :: proc(canvas: ^Canvas) {

	rl.DrawRectangleRec(canvas.panel, rl.BLACK)
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

	if rl.IsMouseButtonDown(.LEFT) {
		col, row := snap_to_grid(mouse_world * canvas.camera.zoom)
		log.info(row, col)
		id := index(col, row, canvas.canvasw)
		if id >= 0 && int(id) < len(canvas.particles) {
			prev := canvas.particles[id]
			pp_pos := dim_to_pos(row, col)
			pp := ub.Particle {
				pos   = pp_pos - canvas.camera.offset,
				color = canvas.current_color,
			}
			canvas.particles[id] = pp
		}
	}

	if rl.IsMouseButtonDown(.RIGHT) {
		delta := rl.GetMouseDelta()
		delta = delta * (-1.0 / canvas.camera.zoom)
		canvas.camera.target = canvas.camera.target + delta
	}


	for particle in canvas.particles {
		rl.DrawRectangle(
			i32(particle.pos.x),
			i32(particle.pos.y),
			CELL_SIZE,
			CELL_SIZE,
			particle.color,
		)
	}
	rl.DrawRectangleRec({width = 15, height = 15}, rl.RED)
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

main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	rl.InitWindow(1920, 1000, "Unga bunga")
	defer rl.CloseWindow()
	rl.SetWindowState({.WINDOW_RESIZABLE})

	window_width := rl.GetScreenWidth()
	window_height := rl.GetScreenHeight()
	log.info(window_width, window_height)
	vpsw, vpsh := get_viewport_size(window_width, window_height)
	log.info(vpsw, vpsh)
	vpx := VIEWPORTX * f32(window_width)
	vpy := VIEWPORTY * f32(window_height)

	canvas := Canvas {
		panel         = {vpx, vpy, vpsw, vpsh},
		canvash       = 10,
		canvasw       = 10,
		current_color = rl.RED,
	}
	canvas.particles = make([]ub.Particle, canvas.canvasw * canvas.canvash)
	defer delete(canvas.particles)

	canvas.camera.zoom = 1

	canvas.camera.target = {
		f32(canvas.canvasw * CELL_SIZE) / 2,
		f32(canvas.canvash * CELL_SIZE) / 2,
	}
	log.info(canvas.camera.target)

	canvas.camera.offset = {f32(window_width) / 2, f32(window_height) / 2}
	log.info(canvas.camera.offset)

	for i in 0 ..< canvas.canvash {
		for j in 0 ..< canvas.canvasw {
			canvas.particles[index(i, j, canvas.canvasw)] = {
				pos   = {f32(CELL_SIZE * j), f32(CELL_SIZE * i)},
				color = {244, 244, 244, 255},
			}
		}
	}


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
