package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "core:strings"
import "engine"
import p "particles"
import ttf "vendor:sdl2/ttf"


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

	particles := [engine.MAX_PARTICLES]p.Particle{}
	active_particles := 0
	id := 0

	spawn_pos := engine.Vector2{}
	engine.set_target_fps(60)

	for !engine.window_should_close() {
		dt := engine.get_frame_time()
		engine.begin()
		defer engine.end()

		if engine.key_button_down(.ESCAPE) {
			engine.make_quit()
		}

		engine.render_clear(engine.Color{25, 25, 25, 255})
		engine.draw_fps()

		// handle particles 
		if engine.mouse_button_pressed(.LEFT) && active_particles < engine.MAX_PARTICLES {
			x, y := engine.get_mouse_global_position()
			spawn_pos.x = f64(x)
			spawn_pos.y = f64(y)
			rando_angle := cast(f64)rand.uint32() * math.PI / 180
			p.activate_particle(&particles[id], rando_angle, spawn_pos)
			id += 1
			active_particles += 1
		}
		for &particle in particles {
			if particle.active && particle.a <= 0 {
				p.deactivate_particle(&particle)
				active_particles -= 1
			} else if particle.active {
				particle.a -= 1
			}
		}

		if id >= engine.MAX_PARTICLES do id = 0

		for &particle in particles {
			// Set draw color to red
			if particle.active {
				p.move_particle(&particle, dt)
				engine.draw_rect_filled(
					engine.Rect{particle.pos.x, particle.pos.y, 5, 5},
					engine.Color{particle.r, particle.g, particle.b, particle.a},
				)
			}
		}

	}
	log.info("Quitting successfully")
}
