package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "engine"
import ui "engine/ui"
import p "particles"

StateMachine :: enum {
	Draw,
	Play,
	Select,
}

state: StateMachine = .Draw


Selection :: struct {
	x: [2]i32,
	y: [2]i32,
}

transmute_selection :: proc(vtx: Selection) -> engine.Rect {
	start_x, end_x, start_y, end_y := vtx.x[0], vtx.x[1], vtx.y[0], vtx.y[1]
	return engine.Rect {
		f64(start_x),
		f64(start_y),
		f64(end_x - start_x),
		f64(end_y - start_y),
	}
}

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
		switch state {
		case .Draw:
			fallthrough
		case .Select:
			state = .Play
		case .Play:
			state = .Draw
		}
	}
	draw_button := ui.Button {
		text = "D",
		fs   = engine.scaled(16),
		w    = 17,
		h    = 17,
		x    = 480,
		y    = 10,
		fg   = engine.PURE_WHITE,
		bg   = engine.DEBUG_RED,
	}
	draw_button.callback = proc() {
		switch state {
		case .Draw:
		case .Select:
			state = .Draw
		case .Play:
		}
	}
	select_button := ui.Button {
		text = "S",
		fs   = engine.scaled(16),
		w    = 17,
		h    = 17,
		x    = 500,
		y    = 10,
		fg   = engine.PURE_WHITE,
		bg   = engine.DEBUG_RED,
	}
	select_button.callback = proc() {
		switch state {
		case .Play:
		case .Select:
		case .Draw:
			state = .Select
		}
	}
	append(&main_window_ui.buttons, play_button, select_button, draw_button)
	particles: [dynamic]p.Particle
	defer delete(particles)

	selection_rect := Selection{}
	selection_active := false

	for !engine.window_should_close() {
		free_all(context.temp_allocator)
		dt := engine.get_frame_time()
		engine.begin()
		defer engine.end()
		engine.render_clear(engine.Color{35, 35, 35, 255})
		engine.draw_fps()

		if engine.key_button_down(.ESCAPE) {
			engine.make_quit()
		}
		if state == .Play {
			for &particle in particles {
				p.move_particle(&particle, dt)
			}
		} else if state == .Draw {
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
		} else if state == .Select {
			if engine.mouse_button_pressed(.LEFT) {
				x, y := engine.get_mouse_global_position()
				if selection_active {
					selection_rect.x[1] = x
					selection_rect.y[1] = y
				} else {
					selection_rect.x[0] = x
					selection_rect.y[0] = y
					selection_active = true
				}
			} else {
				selection_active = false
				selection_rect.x = 0
				selection_rect.y = 0
			}
			rect := transmute_selection(selection_rect)
			// TODO: fix bs with misclicks and stuff
			engine.draw_rect_filled(rect, engine.SELECTION_BLUE)
		}

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
