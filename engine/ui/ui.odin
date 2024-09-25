package ui

import rl "vendor:raylib"

Button :: struct {
	text:     cstring,
	fs:       i32,
	w, h:     f32,
	pos:      rl.Vector2,
	x, y:     i32,
	fg:       rl.Color,
	bg:       rl.Color,
	callback: proc(),
}

on_click :: proc(button: Button) {
	if rl.IsMouseButtonDown(.LEFT) {
		pos := rl.GetMousePosition()
		if pos.x >= button.pos.x &&
		   button.pos.x + button.w >= pos.x &&
		   pos.y >= button.pos.y &&
		   button.pos.y + button.h >= pos.y {
			button.callback()
		}
	}
}

@(private)
render_button :: proc(button: Button) {
	rl.DrawRectangleRec(
		{button.pos.x, button.pos.y, button.w, button.h},
		button.bg,
	)
	rl.DrawText(button.text, button.x, button.y, button.fs, button.fg)
}

UI :: struct {
	buttons: [dynamic]Button,
}

update :: proc(ui: UI) {
	for button in ui.buttons {
		on_click(button)
		render_button(button)
	}
}
