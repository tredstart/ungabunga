package engine

import ub "../particles"
import rl "vendor:raylib"

Layer :: struct {
	canvasw, canvash: i32,
	particles:        []ub.Particle,
}

init_clear_layer :: proc(layer: ^Layer, cw, ch: i32) {
	layer.particles = make([]ub.Particle, cw * ch)
	layer.canvasw = cw
	layer.canvash = ch
	for i in 0 ..< ch {
		for j in 0 ..< cw {
			layer.particles[index(i, j, cw)] = {
				pos   = {f32(CELL_SIZE * j), f32(CELL_SIZE * i)},
				color = {244, 244, 244, 255},
			}
		}
	}
}

delete_layer :: proc(layer: ^Layer) {
	delete(layer.particles)
}


plot :: proc(layer: ^Layer, pos: rl.Vector2, color: rl.Color) {
	row, col := snap_to_grid(pos)
	if row >= 0 && col >= 0 && row < layer.canvash && col < layer.canvasw {
		id := index(col, row, layer.canvasw)
		pp_pos := dim_to_pos(col, row)
		pp := ub.Particle {
			pos   = pp_pos,
			color = color,
		}
		layer.particles[id] = pp
	}
}


plot_line_high :: proc(layer: ^Layer, pos0, pos1: rl.Vector2, color: rl.Color) {
	dx := pos1.x - pos0.x
	dy := pos1.y - pos0.y

	xi := 1

	if dx < 0 {
		xi = -1
		dx = -dx
	}

	D := (2 * dx) - dy
	x := pos0.x

	for y in pos0.y ..= pos1.y {
		plot(layer, {x, y}, color)
		if D > 0 {
			x = x + f32(xi)
			D = D + (2 * (dx - dy))
		} else {
			D = D + 2 * dx
		}
	}
}

plot_line_low :: proc(layer: ^Layer, pos0, pos1: rl.Vector2, color: rl.Color) {
	dx := pos1.x - pos0.x
	dy := pos1.y - pos0.y

	yi := 1

	if dy < 0 {
		yi = -1
		dy = -dy
	}

	D := (2 * dy) - dx
	y := pos0.y

	for x in pos0.x ..= pos1.x {
		plot(layer, {x, y}, color)
		if D > 0 {
			y = y + f32(yi)
			D = D + (2 * (dy - dx))
		} else {
			D = D + 2 * dy
		}
	}
}
