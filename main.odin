package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "engine"
import ui "engine/ui"
import p "particles"

state := false

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
	main_window_ui := ui.UI{}
	defer delete(main_window_ui.buttons)
	play_button := ui.Button {
		text = "|>",
		fs   = engine.scaled(16),
		w    = 17,
		h    = 17,
		x    = 450,
		y    = 10,
		fg   = engine.PURE_WHITE,
		bg   = engine.DEBUG_RED,
	}
	play_button.callback = proc() {
		log.info("fuck yeah")
		state = !state
		log.info(state)
	}
	append(&main_window_ui.buttons, play_button)
	particles: [dynamic]p.Particle

	for !engine.window_should_close() {
		free_all(context.temp_allocator)
		dt := engine.get_frame_time()
		engine.begin()
		defer engine.end()

		if engine.key_button_down(.ESCAPE) {
			engine.make_quit()
		}
		if state {
			for &particle in particles {
				p.move_particle(&particle, dt)
			}
		} else {
			if engine.mouse_button_pressed(.LEFT) {
				x, y := engine.get_mouse_global_position()
				append(
					&particles,
					p.Particle {
						pos = {f64(x), f64(y)},
						r = u8(rand.int_max(256)),
						g = u8(rand.int_max(256)),
						b = u8(rand.int_max(256)),
						a = u8(rand.int_max(256)),
					},
				)
			}
		}

		engine.render_clear(engine.Color{35, 35, 35, 255})
		engine.draw_fps()
		for particle in particles {
			engine.draw_rect_filled(
				{particle.pos.x, particle.pos.y, 10, 10},
				{particle.r, particle.g, particle.b, particle.a},
			)
		}
		ui.update(main_window_ui)

	}
	log.info("Quitting successfully")
}
