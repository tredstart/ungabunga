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

	rand.reset(69420)

	if ttf.Init() != 0 {
		log.error("can't init ttf")
		return
	}
	defer ttf.Quit()


	engine.sdl_init("Unga bunga", 1080, 720)
	defer engine.sdl_quit()

	particles := [engine.MAX_PARTICLES]p.Particle{}
	active_particles := 0
	id := 0

	should_quit := false


	current_time: u32 = 0
	last_time: u32 = 0
	spawn_pos := engine.Vector2{}

	fps := 0

	font := ttf.OpenFont("./gohu/Gohu/GohuFontuni11NerdFont-Regular.ttf", 240)
	if font == nil {
		log.error("cannot load font")
	}
	defer ttf.CloseFont(font)

	for !engine.window_should_close() {
		dt := engine.get_frame_time()
		engine.begin()
		defer engine.end()

		engine.render_clear(engine.Color{15, 15, 15, 255})
		// fps_display := strings.clone_to_cstring(fps_text)
		// defer delete(fps_display)
		//
		// text_surface := ttf.RenderText_Solid(font, fps_display, engine.PURE_WHITE)
		// if text_surface == nil {
		// 	log.errorf("Surface creation error: %s", sdl.GetError())
		// }
		// defer sdl.FreeSurface(text_surface)
		//
		// texture := sdl.CreateTextureFromSurface(engine.APP.renderer, text_surface)
		// if texture == nil {
		// 	log.errorf("Texture creating error: %s", sdl.GetError())
		// }
		// defer sdl.DestroyTexture(texture)
		//
		// fps_dest := sdl.Rect{50, 50, text_surface.w, text_surface.h}


		// // handle particles 
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


		// hanlde render
		// Clear the screen

		// sdl.RenderCopy(engine.APP.renderer, texture, nil, &fps_dest)


		for &particle in particles {
			// Set draw color to red
			if particle.active {
				p.move_particle(&particle, dt)
				engine.draw_rect_filled(
					engine.Rect{particle.pos.x, particle.pos.y, 20, 20},
					engine.Color{particle.r, particle.g, particle.b, particle.a},
				)
			}
		}

	}
	log.info("Quitting successfully")
}
