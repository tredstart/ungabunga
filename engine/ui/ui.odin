package ui

import ".."

Button :: struct {
	text:     string,
	fs:       i32,
	w, h:     f64,
	x, y:     f64,
	fg:       engine.Color,
	bg:       engine.Color,
	callback: proc(),
}

on_click :: proc(button: Button) {
	if engine.mouse_button_down(.LEFT) {
		x, y := engine.get_mouse_global_position()
		if f64(x) >= button.x &&
		   button.x + button.w >= f64(x) &&
		   f64(y) >= button.y &&
		   button.y + button.h >= f64(y) {
			button.callback()
		}
	}
}

@(private)
render_button :: proc(button: Button) {
	engine.draw_rect_filled({button.x, button.y, button.w, button.h}, button.bg)
	engine.draw_text(
		engine.scaled(button.x),
		engine.scaled(button.y),
		button.text,
		button.fs,
		button.fg,
	)
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
