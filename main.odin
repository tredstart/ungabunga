package main

import "core:log"
import "core:math"
import engine "engine"
import ub "particles"
import rl "vendor:raylib"


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
	vpsw, vpsh := engine.get_viewport_size(window_width, window_height)
	log.info(vpsw, vpsh)
	vpx := engine.VIEWPORTX * f32(window_width)
	vpy := engine.VIEWPORTY * f32(window_height)

	canvas := engine.Canvas {
		panel         = {vpx, vpy, vpsw, vpsh},
		canvash       = 100,
		canvasw       = 100,
		current_color = rl.RED,
	}
	canvas.particles = make([]ub.Particle, canvas.canvasw * canvas.canvash)
	defer delete(canvas.particles)

	canvas.camera.zoom = 1

	canvas.camera.target = {
		f32(canvas.canvasw * engine.CELL_SIZE) / 2,
		f32(canvas.canvash * engine.CELL_SIZE) / 2,
	}

	canvas.camera.offset = {f32(window_width) / 2, f32(window_height) / 2}

	for i in 0 ..< canvas.canvash {
		for j in 0 ..< canvas.canvasw {
			canvas.particles[engine.index(i, j, canvas.canvasw)] = {
				pos   = {f32(engine.CELL_SIZE * j), f32(engine.CELL_SIZE * i)},
				color = {244, 244, 244, 255},
			}
		}
	}


	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		defer rl.DrawFPS(10, 10)

		rl.GuiGroupBox({30, 30, 250, 900}, "Objects")
		rl.GuiGroupBox({300, 800, 1200, 200}, "Timeline")
		rl.GuiGroupBox(
			{engine.VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 950},
			"Params",
		)
		engine.draw_canvas(&canvas)

	}

}
