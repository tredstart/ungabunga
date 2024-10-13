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

	canvas := engine.init_canvas(100, 100)
	defer engine.delete_canvas(canvas)

	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		defer rl.DrawFPS(10, 10)

		rl.GuiGroupBox({30, 30, 250, 900}, "Objects")
		rl.GuiGroupBox({300, 800, 1200, 200}, "Timeline")
		engine.draw_side_panel(canvas)
		engine.draw_canvas(canvas)

	}

}
