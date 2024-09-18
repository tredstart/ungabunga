package particles

import engine "../engine"
import "core:math"
import "core:math/rand"

Particle :: struct {
	pos:        engine.Vector2,
	vx, vy:     f64,
	r, g, b, a: u8,
	active:     bool,
}

activate_particle :: proc(self: ^Particle, angle: f64, pos: engine.Vector2) {
	self.r = u8(rand.int_max(256))
	self.g = u8(rand.int_max(256))
	self.b = u8(rand.int_max(256))
	self.a = u8(rand.int_max(256))
	self.pos = pos
	self.vx = cast(f64)rand.int_max(engine.Velocity) * math.cos(angle)
	self.vy = cast(f64)rand.int_max(engine.Velocity) * math.sin(angle)
	self.active = true
}

deactivate_particle :: proc(self: ^Particle) {
	self.active = false
}

move_particle :: proc(self: ^Particle, dt: f64) {
	self.vy += 2
	self.pos.x += self.vx * dt * engine.SCALE
	self.pos.y += self.vy * dt * engine.SCALE
}
