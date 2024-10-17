package engine

import ub "../particles"
import "core:log"
import rl "vendor:raylib"

CanvasState :: enum {
	Drawing,
	Erasing,
}

Canvas :: struct {
	panel:            rl.Rectangle,
	camera:           rl.Camera2D,
	brush:            Brush,
	last_placed:      rl.Vector2,
	state:            CanvasState,
	layers:           [dynamic]Layer,
	active_layer:     i32,
	canvasw, canvash: i32,
	visible:          []ub.Particle,
	state_active:     bool,
}

Frame :: struct {}

screen_dimentions :: proc() -> (window_width, window_height: i32, vpsw, vpsh: f32) {
	window_width = rl.GetScreenWidth()
	window_height = rl.GetScreenHeight()
	vpsw, vpsh = get_viewport_size(window_width, window_height)
	return
}

init_canvas :: proc(cw, ch: i32) -> ^Canvas {
	canvas := new(Canvas)
	append(&canvas.layers, Layer{})
	assert(len(canvas.layers) == 1)

	canvas.canvasw = cw
	canvas.canvash = ch

	canvas.active_layer = 0
	init_clear_layer(&canvas.layers[0], canvas.canvasw, canvas.canvash)
	window_width, window_height, vpsw, vpsh := screen_dimentions()

	vpx := VIEWPORTX * f32(window_width)
	vpy := VIEWPORTY * f32(window_height)

	canvas.panel = {vpx, vpy, vpsw, vpsh}
	canvas.brush.color = rl.RED
	canvas.brush.size = 1

	canvas.camera.zoom = 1
	canvas.camera.target = {f32(canvas.canvasw * CELL_SIZE) / 2, f32(canvas.canvash * CELL_SIZE) / 2}
	canvas.camera.offset = {f32(window_width) / 2, f32(window_height) / 2}

	canvas.visible = make([]ub.Particle, canvas.canvash * canvas.canvasw)

	return canvas
}

delete_canvas :: proc(canvas: ^Canvas) {
	for &layer in canvas.layers {
		delete_layer(&layer)
	}
	delete(canvas.layers)
	delete(canvas.visible)
	free(canvas)
}

handle_zoom :: proc(canvas: ^Canvas, mouse_world: rl.Vector2, wheel: f32) {
	if wheel != 0 {
		canvas.camera.offset = rl.GetMousePosition()
		canvas.camera.target = mouse_world

		scale_factor := 1.0 + (0.25 * abs(wheel))
		if wheel < 0 {
			scale_factor = 1 / scale_factor
		}
		canvas.camera.zoom = clamp(canvas.camera.zoom * scale_factor, 0.125, 64.0)
	}
}


handle_draw :: proc(canvas: ^Canvas, mouse_world: rl.Vector2) {
	if rl.IsMouseButtonDown(.LEFT) {
		layer := &canvas.layers[canvas.active_layer]
		#partial switch canvas.state {
		case .Erasing:
			canvas.brush.color = {0, 0, 0, 0}
            // FIXME: the color on the colorpicker drops when erasing is chosen
		case .Drawing:
			canvas.brush.color.a = 255
		}

		if canvas.state_active {
			if abs(mouse_world.y - canvas.last_placed.y) < abs(mouse_world.x - canvas.last_placed.x) {
				if canvas.last_placed.x > mouse_world.x {
					plot_line_low(layer, mouse_world, canvas.last_placed, canvas.brush)
				} else {
					plot_line_low(layer, canvas.last_placed, mouse_world, canvas.brush)
				}
			} else {
				if canvas.last_placed.y > mouse_world.y {
					plot_line_high(layer, mouse_world, canvas.last_placed, canvas.brush)
				} else {
					plot_line_high(layer, canvas.last_placed, mouse_world, canvas.brush)
				}
			}
		} else {
			plot(layer, mouse_world, canvas.brush)
			canvas.state_active = true
		}
		col, row := snap_to_grid(mouse_world)
		canvas.last_placed = dim_to_pos(row, col)
	}
	if rl.IsMouseButtonUp(.LEFT) {
		canvas.state_active = false
	}
}

handle_canvas_drag :: proc(canvas: ^Canvas) {
	if rl.IsMouseButtonDown(.RIGHT) {
		delta := rl.GetMouseDelta()
		delta = delta * (-1.0 / canvas.camera.zoom)
		canvas.camera.target = canvas.camera.target + delta
	}
}

draw_canvas :: proc(canvas: ^Canvas) {
	rl.DrawRectangleRec(canvas.panel, rl.DARKGRAY)
	rl.BeginScissorMode(i32(canvas.panel.x), i32(canvas.panel.y), i32(canvas.panel.width), i32(canvas.panel.height))
	rl.BeginMode2D(canvas.camera)
	defer rl.EndMode2D()
	defer rl.EndScissorMode()
	defer draw_brush(canvas^, &canvas.brush)

	rl.DrawRectangle(0, 0, canvas.canvasw * CELL_SIZE, canvas.canvash * CELL_SIZE, rl.RAYWHITE)

	wheel := rl.GetMouseWheelMove()
	mouse_world := rl.GetScreenToWorld2D(rl.GetMousePosition(), canvas.camera)

	handle_zoom(canvas, mouse_world, wheel)
	handle_draw(canvas, mouse_world)
	handle_canvas_drag(canvas)

	assert(len(canvas.layers) > 0)
	for layer in canvas.layers {
		for particle, i in layer.particles {
			if particle.color.a != 0 {
				rl.DrawRectangle(i32(particle.pos.x), i32(particle.pos.y), CELL_SIZE, CELL_SIZE, particle.color)
			}
		}
	}

	when ODIN_DEBUG {
		rl.DrawLine(
			i32(canvas.camera.target.x),
			-i32(canvas.panel.height) * 10,
			i32(canvas.camera.target.x),
			i32(canvas.panel.height) * 10,
			rl.GREEN,
		)
		rl.DrawLine(
			-i32(canvas.panel.width) * 10,
			i32(canvas.camera.target.y),
			i32(canvas.panel.width) * 10,
			i32(canvas.camera.target.y),
			rl.GREEN,
		)
	}
}
