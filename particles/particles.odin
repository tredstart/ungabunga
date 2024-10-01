package particles

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

Particle :: struct {
	pos:    rl.Vector2,
	vx, vy: f32,
	color:  rl.Color,
	active: bool,
}
Velocity :: 100

move_particle :: proc(self: ^Particle, dt: f32) {
	self.vy += 100 * dt
	self.pos.x += self.vx * dt
	self.pos.y += self.vy * dt
}
