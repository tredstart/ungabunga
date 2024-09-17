package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "core:strings"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

Particle :: struct {
	pos:        Vector2,
	vx, vy:     f64,
	r, g, b, a: u8,
	active:     bool,
}

Vector2 :: struct {
	x, y: f64,
}

MAX_PARTICLES :: 5024
Velocity :: 50
SCALE :: 10

scaled :: proc(coord: f64) -> i32 {
	return i32(coord * SCALE)
}

activate_particle :: proc(self: ^Particle, angle: f64, pos: Vector2) {
	self.r = u8(rand.int_max(256))
	self.g = u8(rand.int_max(256))
	self.b = u8(rand.int_max(256))
	self.a = u8(rand.int_max(256))
	self.pos = pos
	self.vx = cast(f64)rand.int_max(Velocity) * math.cos(angle)
	self.vy = cast(f64)rand.int_max(Velocity) * math.sin(angle)
	self.active = true
}

deactivate_particle :: proc(self: ^Particle) {
	self.active = false
}

move_particle :: proc(self: ^Particle, dt: f64) {
	self.vy += 2
	self.pos.x += self.vx * dt * SCALE
	self.pos.y += self.vy * dt * SCALE
}


SdlApp :: struct {
	window:       ^sdl.Window,
	renderer:     ^sdl.Renderer,
	w, h:         i32,
	title:        cstring,
	window_flags: sdl.WindowFlags,
}

sdl_init :: proc(app: ^SdlApp) -> bool {
	if sdl.Init(sdl.INIT_VIDEO) < 0 {
		log.errorf("teapot: init failed, %f", sdl.GetError())
		return false
	}

	app.window = sdl.CreateWindow(
		app.title,
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		app.w,
		app.h,
		app.window_flags,
	)
	if app.window == nil {
		log.errorf("teapot: cannot create a window: %s", sdl.GetError())
		return false
	}
	app.renderer = sdl.CreateRenderer(app.window, -1, sdl.RENDERER_ACCELERATED)
	if app.renderer == nil {
		log.errorf("teapot: cannot create a window: %s", sdl.GetError())
		return false
	}

	return true
}
sdl_quit_event :: proc(event: ^sdl.Event) -> bool {
	if (event.type == .QUIT) {
		return true
	}
	return false
}

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


	app := SdlApp {
		w            = 1080,
		h            = 720,
		window_flags = sdl.WINDOW_SHOWN,
		title        = "Unga bunga",
	}
	sdl_init(&app)
	defer sdl.DestroyWindow(app.window)
	defer sdl.DestroyRenderer(app.renderer)
	defer sdl.Quit()
	if app.window == nil || app.renderer == nil {
		log.error("teapot")
		return
	}

	particles := [MAX_PARTICLES]Particle{}
	active_particles := 0
	id := 0

	should_quit := false

	e: sdl.Event
	sdl.RenderSetScale(app.renderer, 1.0 / SCALE, 1.0 / SCALE)


	current_time: u32 = 0
	last_time: u32 = 0
	dt := 0.0
	spawn_pos, spawn := Vector2{}, false

	frame_start := sdl.GetTicks()
	fps := 0

	font := ttf.OpenFont("./gohu/Gohu/GohuFontuni11NerdFont-Regular.ttf", 240)
	if font == nil {
		log.error("cannot load font")
	}
	defer ttf.CloseFont(font)
	// Create a color for the text
	text_color: sdl.Color
	text_color.r = 255
	text_color.g = 255
	text_color.b = 255
	text_color.a = 255


	fps_text := "0"

	for !should_quit {
		last_time = current_time
		current_time = sdl.GetTicks()
		dt = f64(current_time - last_time) / 1000.0

		if current_time - frame_start >= 1000 {
			fps_text = fmt.tprintf("%d", fps)
			fps = 0
			frame_start = current_time
		} else {
			fps += 1
		}

		fps_display := strings.clone_to_cstring(fps_text)
		defer delete(fps_display)

		text_surface := ttf.RenderText_Solid(font, fps_display, text_color)
		if text_surface == nil {
			log.errorf("Surface creation error: %s", sdl.GetError())
		}
		defer sdl.FreeSurface(text_surface)

		texture := sdl.CreateTextureFromSurface(app.renderer, text_surface)
		if texture == nil {
			log.errorf("Texture creating error: %s", sdl.GetError())
		}
		defer sdl.DestroyTexture(texture)

		fps_dest := sdl.Rect{50, 50, text_surface.w, text_surface.h}

		for sdl.PollEvent(&e) {
			#partial switch e.type {
			case .QUIT:
				should_quit = true
			case .KEYUP:
				key_event := e.key
				#partial switch key_event.keysym.scancode {
				case .ESCAPE:
					should_quit = true
				}
			case .MOUSEBUTTONDOWN:
				event := e.button
				if event.button == 1 {
					spawn = true
				}
			case .MOUSEBUTTONUP:
				event := e.button
				if event.button == 1 {
					spawn = false
				}
			}
		}

		// handle particles 
		if spawn && active_particles < MAX_PARTICLES {
			x, y: i32
			sdl.GetMouseState(&x, &y)
			spawn_pos.x = f64(x)
			spawn_pos.y = f64(y)
			rando_angle := cast(f64)rand.uint32() * math.PI / 180
			activate_particle(&particles[id], rando_angle, spawn_pos)
			id += 1
			active_particles += 1
		}
		for &particle in particles {
			if particle.active && particle.a <= 0 {
				deactivate_particle(&particle)
				active_particles -= 1
			} else if particle.active {
				particle.a -= 1
			}
		}

		if id >= MAX_PARTICLES do id = 0


		// hanlde render
		// Clear the screen
		sdl.SetRenderDrawColor(app.renderer, 25, 25, 25, 255)
		sdl.RenderClear(app.renderer)

		sdl.RenderCopy(app.renderer, texture, nil, &fps_dest)


		for &particle in particles {
			// Set draw color to red
			if particle.active {
				move_particle(&particle, dt)
				sdl.SetRenderDrawColor(
					app.renderer,
					particle.r,
					particle.g,
					particle.b,
					particle.a,
				)
				sdl.RenderFillRect(
					app.renderer,
					&sdl.Rect {
						x = scaled(particle.pos.x),
						y = scaled(particle.pos.y),
						w = 20,
						h = 20,
					},
				)
			}
		}

		sdl.RenderPresent(app.renderer)
		sdl.Delay(16)
	}
	log.info("Quitting successfully")
}
