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

	canvas := engine.init_canvas(100, 100)

	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		defer rl.EndDrawing()
		rl.ClearBackground({100, 100, 100, 255})
		defer rl.DrawFPS(10, 10)

		rl.GuiGroupBox({30, 30, 250, 900}, "Objects")
		rl.GuiGroupBox({300, 800, 1200, 200}, "Timeline")
		// rl.GuiGroupBox({engine.VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 950}, "Params")
		//
		// rl.GuiColorPicker(
		// 	{engine.VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 200},
		// 	"Current color",
		// 	&canvas.current_color,
		// )
		engine.draw_canvas(canvas)

	}

}
