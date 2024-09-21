package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "engine"
import p "particles"



main :: proc() {

	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)
	if !engine.ttf_init() {
		return
	}
	defer engine.ttf_quit()

	rand.reset(69420)

	engine.sdl_init("Unga bunga", 1080, 720)
	defer engine.sdl_quit()

	engine.set_target_fps(60)

	for !engine.window_should_close() {
		free_all(context.temp_allocator)
		dt := engine.get_frame_time()
		engine.begin()
		defer engine.end()

		if engine.key_button_down(.ESCAPE) {
			engine.make_quit()
		}

		engine.render_clear(engine.Color{35, 35, 35, 255})
		engine.draw_fps()

	}
	log.info("Quitting successfully")
}
