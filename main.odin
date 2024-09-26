package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "core:mem"
import ui "engine/ui"
import p "particles"

import rl "vendor:raylib"

StateMachine :: enum {
	Draw,
	Play,
	Select,
}

state: StateMachine = .Draw


Selection :: struct {
	x: [2]f32,
	y: [2]f32,
}

transmute_selection :: proc(vtx: Selection) -> rl.Rectangle {
	start_x, end_x, start_y, end_y := vtx.x[0], vtx.x[1], vtx.y[0], vtx.y[1]
	return rl.Rectangle{start_x, start_y, end_x - start_x, end_y - start_y}
}

CELL_SIZE :: 10

index :: proc(row, col, w: i32) -> i32 {
	return row * w + col
}

snap_to_grid :: proc(x, y: f32) -> (i32, i32) {
	col := cast(i32)math.round(x / CELL_SIZE)
	row := cast(i32)math.round(y / CELL_SIZE)
	return row, col
}

dim_to_pos :: proc(row, col: i32) -> rl.Vector2 {
	px := cast(f32)col * CELL_SIZE
	py := cast(f32)row * CELL_SIZE
	return rl.Vector2{px, py}
}

free_particles :: proc(particles: []^p.Particle) {
	for particle in particles {
		free(particle)
	}
}

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)
		defer {
			if len(track.allocation_map) > 0 {
				fmt.eprintf(
					"=== %v allocations not freed: ===\n",
					len(track.allocation_map),
				)
				for _, entry in track.allocation_map {
					fmt.eprintf(
						"- %v bytes @ %v\n",
						entry.size,
						entry.location,
					)
				}
			}
			if len(track.bad_free_array) > 0 {
				fmt.eprintf(
					"=== %v incorrect frees: ===\n",
					len(track.bad_free_array),
				)
				for entry in track.bad_free_array {
					fmt.eprintf("- %p @ %v\n", entry.memory, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}

	logger := log.create_console_logger()
	context.logger = logger
	defer log.destroy_console_logger(logger)

	rand.reset(69420)

	rl.InitWindow(1080, 720, "Unga bunga")
	defer rl.CloseWindow()

	window_width := rl.GetScreenWidth()
	window_height := rl.GetScreenHeight()

	dim_x, dim_y := window_width / CELL_SIZE, window_height / CELL_SIZE

	canvas := make([]^p.Particle, dim_x * dim_y)
	defer free_particles(canvas)
	defer delete(canvas)

	main_window_ui := ui.UI{}
	defer delete(main_window_ui.buttons)
	play_button := ui.Button {
		text = "|>",
		fs   = 16,
		w    = 17,
		h    = 17,
		x    = 440,
		y    = 10,
		fg   = rl.RAYWHITE,
		bg   = rl.RED,
	}
	play_button.pos = {f32(play_button.x - 3), f32(play_button.y)}
	pause_button := ui.Button {
		text = "||",
		fs   = 16,
		w    = 17,
		h    = 17,
		x    = 460,
		y    = 10,
		fg   = rl.RAYWHITE,
		bg   = rl.RED,
	}
	pause_button.pos = {f32(pause_button.x - 3), f32(pause_button.y)}
	pause_button.callback = proc() {
		switch state {
		case .Draw:
		case .Select:
		case .Play:
			state = .Draw
		}
	}
	play_button.callback = proc() {
		switch state {
		case .Draw:
			fallthrough
		case .Select:
			state = .Play
		case .Play:
		}
	}
	draw_button := ui.Button {
		text = "D",
		fs   = 16,
		w    = 17,
		h    = 17,
		x    = 480,
		y    = 10,
		fg   = rl.RAYWHITE,
		bg   = rl.RED,
	}
	draw_button.pos = {f32(draw_button.x - 3), f32(draw_button.y)}
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
		fs   = 16,
		w    = 17,
		h    = 17,
		x    = 500,
		y    = 10,
		fg   = rl.RAYWHITE,
		bg   = rl.RED,
	}
	select_button.pos = {f32(select_button.x - 3), f32(select_button.y)}
	select_button.callback = proc() {
		switch state {
		case .Play:
		case .Select:
		case .Draw:
			state = .Select
		}
	}
	append(
		&main_window_ui.buttons,
		play_button,
		select_button,
		draw_button,
		pause_button,
	)
	selection_rect := Selection{}
	selection_active := false
	saved := false

	particles := [dynamic]^p.Particle{}
	defer delete(particles)

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)
		dt := rl.GetFrameTime()

		if state == .Play {
			if !saved {
				for particle in canvas {
					if particle != nil {
						pp := new(p.Particle)
						pp^ = particle^
						append(&particles, pp)
					}
				}
				saved = true
			}
			for particle in particles {
				p.move_particle(particle, dt)
			}
		} else if state == .Draw {
			if saved {
				for len(particles) > 0 {
					pp := pop(&particles)
					free(pp)
				}
			}
			if rl.IsMouseButtonDown(.LEFT) {
				saved = false
				pos := rl.GetMousePosition()
				row, col := snap_to_grid(pos.x, pos.y)
				id := index(row, col, dim_x)
				if id >= 0 && int(id) < len(canvas) {
					prev := canvas[id]
					if prev != nil {
						free(prev)
					}
					pp := new(p.Particle)
					pp^ = {
						pos = dim_to_pos(row, col),
						r   = u8(rand.int_max(256)),
						g   = u8(rand.int_max(256)),
						b   = u8(rand.int_max(256)),
						a   = u8(rand.int_max(256)),
					}
					canvas[id] = pp
				}
			}
		} else if state == .Select {
			if rl.IsMouseButtonDown(.LEFT) {
				pos := rl.GetMousePosition()
				if selection_active {
					selection_rect.x[1] = pos.x
					selection_rect.y[1] = pos.y
				} else {
					selection_rect.x[0] = pos.x
					selection_rect.y[0] = pos.y
					selection_active = true
				}
			} else {
				selection_active = false
				selection_rect.x = 0
				selection_rect.y = 0
			}
			rect := transmute_selection(selection_rect)
			rl.DrawRectangleRec(rect, {50, 100, 150, 100})
		}

		rl.BeginDrawing()
		defer rl.EndDrawing()
		defer rl.DrawFPS(10, 10)
		rl.ClearBackground(rl.RAYWHITE)

		if state == .Draw || state == .Select {
			for particle in canvas {
				if particle != nil {
					rl.DrawRectangleRec(
						{particle.pos.x, particle.pos.y, CELL_SIZE, CELL_SIZE},
						{particle.r, particle.g, particle.b, particle.a},
					)
				}
			}
		} else if state == .Play {
			for particle in particles {
				rl.DrawRectangleRec(
					{particle.pos.x, particle.pos.y, CELL_SIZE, CELL_SIZE},
					{particle.r, particle.g, particle.b, particle.a},
				)
			}
		}
		ui.update(main_window_ui)

	}
	log.info("Quitting successfully")
}
