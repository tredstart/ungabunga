package particles

import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

Particle :: struct {
	pos:        rl.Vector2,
	vx, vy:     f32,
	r, g, b, a: u8,
	active:     bool,
}
Velocity :: 100

activate_particle :: proc(self: ^Particle, angle: f64, pos: rl.Vector2) {
	self.r = u8(rand.int_max(256))
	self.g = u8(rand.int_max(256))
	self.b = u8(rand.int_max(256))
	self.a = u8(rand.int_max(256))
	self.pos = pos
	self.vx = cast(f32)rand.int_max(Velocity) * cast(f32)math.cos(angle)
	self.vy = cast(f32)rand.int_max(Velocity) * cast(f32)math.sin(angle)
	self.active = true
}

deactivate_particle :: proc(self: ^Particle) {
	self.active = false
}

move_particle :: proc(self: ^Particle, dt: f32) {
	self.vy += 100 * dt
	self.pos.x += self.vx * dt
	self.pos.y += self.vy * dt
}
