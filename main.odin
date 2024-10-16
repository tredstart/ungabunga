package main

import "core:fmt"
import "core:log"
import "core:math"
import engine "engine"
import ub "particles"
import rl "vendor:raylib"

import "core:mem"


main :: proc() {
	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf("=== %v incorrect frees: ===\n", len(track.bad_free_array))
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	rl.InitWindow(1920, 1000, "Unga bunga")
	defer rl.CloseWindow()
	rl.SetWindowState({.WINDOW_RESIZABLE})

	canvas := engine.init_canvas(64, 64)
	defer engine.delete_canvas(canvas)

	window_width, window_height, vpsw, vpsh := engine.screen_dimentions()
	rside := engine.Panel {
		panel   = {engine.VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 950},
		padding = {5, 5, 30, 5},
	}

	lside := engine.Panel {
		panel   = {30, 30, 250, 900},
		padding = {5, 5, 30, 5},
	}


	for !rl.WindowShouldClose() {

		if rl.IsKeyUp(.E) && rl.IsKeyPressed(.LEFT_CONTROL) {
			log.info("trying to export")
			scale: i32 = 8
			image := rl.GenImageColor(canvas.canvasw * scale, canvas.canvash * scale, {0, 0, 0, 0})
			rl.ImageFormat(&image, .UNCOMPRESSED_R8G8B8A8)
			for layer in canvas.layers {
				for particle in layer.particles {
					if particle.color.a != 0 {
						col, row := engine.snap_to_grid(particle.pos)
						rl.ImageDrawRectangle(&image, col * scale, row * scale, scale, scale, particle.color)
					}
				}
			}
			rl.ExportImage(image, "output.png")
			rl.UnloadImage(image)
		}

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		defer rl.DrawFPS(10, 10)

		engine.draw_lside_panel(canvas, lside)
		rl.GuiGroupBox({300, 800, 1200, 200}, "Timeline")
		engine.draw_rside_panel(canvas, rside)
		engine.draw_canvas(canvas)

	}

}
