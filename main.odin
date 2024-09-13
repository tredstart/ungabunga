package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Particle :: struct {
	r, g, b, a: u8,
	x, y:       f64,
	active:     bool,
	vx, vy:     f64,
}

MAX_PARTICLES :: 5024
Velocity :: 150

activate_particle :: proc(self: ^Particle, angle: f64, pos: rl.Vector2) {
	self.r = u8(rl.GetRandomValue(0, 256))
	self.g = u8(rl.GetRandomValue(0, 256))
	self.b = u8(rl.GetRandomValue(0, 256))
	self.a = u8(rl.GetRandomValue(0, 256))
	self.x = cast(f64)pos.x
	self.y = cast(f64)pos.y
	self.vx = cast(f64)rl.GetRandomValue(10, Velocity) * math.cos(angle)
	self.vy = cast(f64)rl.GetRandomValue(10, Velocity) * math.sin(angle)
	self.active = true
}

deactivate_particle :: proc(self: ^Particle) {
	self.active = false
}

move_particle :: proc(self: ^Particle, dt: f64) {
	self.vy += 2
	self.x += self.vx * dt
	self.y += self.vy * dt
}


main :: proc() {
	rl.InitWindow(1080, 720, "particles for the win")
	defer rl.CloseWindow()
	particles := [MAX_PARTICLES]Particle{}


	rl.SetRandomSeed(69420)


	rl.SetTargetFPS(60)

	timer := rl.GetTime()

	id := 0

	for !rl.WindowShouldClose() {

		if rl.IsMouseButtonDown(.LEFT) {
			mp := rl.GetMousePosition()
			particle := &particles[id]
			rando_angle := cast(f64)rl.GetRandomValue(0, 360) * rl.DEG2RAD
			activate_particle(particle, rando_angle, mp)
			id += 1
		}

		for i in 0 ..< MAX_PARTICLES {
			particle := &particles[i]
			if particle.a <= 0 && particle.active {
				deactivate_particle(particle)
			}
		}

		rl.BeginDrawing()

		rl.ClearBackground(rl.BLACK)
		rl.DrawFPS(60, 60)

		for i in 0 ..< MAX_PARTICLES {
			particle := &particles[i]
			if particle.active {
				move_particle(particle, cast(f64)rl.GetFrameTime())
				particle.a -= 1
				color := rl.Color{}
				color.rgba = {particle.r, particle.g, particle.b, particle.a}
				rl.DrawRectangleV({cast(f32)particle.x, cast(f32)particle.y}, {2, 2}, color)
				// rl.DrawPixelV({cast(f32)particle.x, cast(f32)particle.y}, color)
			}
		}


		rl.EndDrawing()

	}
}
