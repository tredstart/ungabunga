package main

import "core:fmt"
import "core:log"
import "core:math"
import "core:math/rand"
import "core:mem"
import "engine"
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
	defer {
		for particle in canvas {
			free(particle)
		}
	}
	defer delete(canvas)


	// main_window_ui := ui.UI{}
	// defer delete(main_window_ui.buttons)
	// play_button := ui.Button {
	// 	text = "|>",
	// 	fs   = 16,
	// 	w    = 17,
	// 	h    = 17,
	// 	x    = 450,
	// 	y    = 10,
	// 	fg   = rl.RAYWHITE,
	// 	bg   = rl.RED,
	// }
	// play_button.callback = proc() {
	// 	switch state {
	// 	case .Draw:
	// 		fallthrough
	// 	case .Select:
	// 		state = .Play
	// 	case .Play:
	// 		state = .Draw
	// 	}
	// }
	// draw_button := ui.Button {
	// 	text = "D",
	// 	fs   = engine.scaled(16),
	// 	w    = 17,
	// 	h    = 17,
	// 	x    = 480,
	// 	y    = 10,
	// 	fg   = rl.RAYWHITE,
	// 	bg   = rl.RED,
	// }
	// draw_button.callback = proc() {
	// 	switch state {
	// 	case .Draw:
	// 	case .Select:
	// 		state = .Draw
	// 	case .Play:
	// 	}
	// }
	// select_button := ui.Button {
	// 	text = "S",
	// 	fs   = engine.scaled(16),
	// 	w    = 17,
	// 	h    = 17,
	// 	x    = 500,
	// 	y    = 10,
	// 	fg   = rl.RAYWHITE,
	// 	bg   = rl.RED,
	// }
	// select_button.callback = proc() {
	// 	switch state {
	// 	case .Play:
	// 	case .Select:
	// 	case .Draw:
	// 		state = .Select
	// 	}
	// }
	// append(&main_window_ui.buttons, play_button, select_button, draw_button)
	//
	// selection_rect := Selection{}
	// selection_active := false

	for !rl.WindowShouldClose() {
		free_all(context.temp_allocator)
		dt := rl.GetFrameTime()

		// if state == .Play {
		// 	for &particle in particles {
		// 		p.move_particle(&particle, dt)
		// 	}
		// } else if state == .Draw {
		// 	if engine.mouse_button_pressed(.LEFT) {
		// 		x, y := engine.get_mouse_global_position()
		// 		append(
		// 			&particles,
		// 			p.Particle {
		// 				pos = {f64(x), f64(y)},
		// 				r = u8(rand.int_max(256)),
		// 				g = u8(rand.int_max(256)),
		// 				b = u8(rand.int_max(256)),
		// 				a = u8(rand.int_max(256)),
		// 			},
		// 		)
		// 	}
		// } else if state == .Select {
		// 	if engine.mouse_button_pressed(.LEFT) {
		// 		x, y := engine.get_mouse_global_position()
		// 		if selection_active {
		// 			selection_rect.x[1] = x
		// 			selection_rect.y[1] = y
		// 		} else {
		// 			selection_rect.x[0] = x
		// 			selection_rect.y[0] = y
		// 			selection_active = true
		// 		}
		// 	} else {
		// 		selection_active = false
		// 		selection_rect.x = 0
		// 		selection_rect.y = 0
		// 	}
		// 	rect := transmute_selection(selection_rect)
		// 	// TODO: fix bs with misclicks and stuff
		// 	engine.draw_rect_filled(rect, engine.SELECTION_BLUE)
		// }
		//
		if rl.IsMouseButtonDown(.LEFT) {
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
		rl.BeginDrawing()
		defer rl.EndDrawing()
		defer rl.DrawFPS(10, 10)
		rl.ClearBackground(rl.RAYWHITE)

		for particle in canvas {
			if particle != nil {
				rl.DrawRectangleRec(
					{particle.pos.x, particle.pos.y, CELL_SIZE, CELL_SIZE},
					{particle.r, particle.g, particle.b, particle.a},
				)
			}
		}
		// ui.update(main_window_ui)

	}
	log.info("Quitting successfully")
}
