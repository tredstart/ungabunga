package engine
import rl "vendor:raylib"

draw_side_panel :: proc(canvas: ^Canvas) {
	window_width, window_height, vpsw, vpsh := screen_dimentions()
	rl.GuiGroupBox({VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 950}, "Params")
	rl.GuiColorPicker(
		{VIEWPORTX * f32(window_width) + vpsw + 20, 30, 200, 200},
		"Current color",
		&canvas.current_color,
	)
}
