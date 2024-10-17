package engine
import "core:fmt"
import "core:log"
import "core:strings"
import rl "vendor:raylib"


Panel :: struct {
	padding: rl.Vector4,
	panel:   rl.Rectangle,
}


draw_rside_panel :: proc(canvas: ^Canvas, panel: Panel) {
	rside_color_picker := rl.Rectangle {
		x     = panel.panel.x + panel.padding.x,
		y     = panel.panel.y + panel.padding.y,
		width = panel.panel.width - (panel.padding.x + panel.padding.z),
	}
	rside_color_picker.height = rside_color_picker.width
	rl.GuiGroupBox(panel.panel, "Params")
	rl.GuiColorPicker(rside_color_picker, "Current color", &canvas.brush.color)
	rside_draw_buttons := rl.Rectangle {
		x      = panel.panel.x + panel.padding.x,
		y      = rside_color_picker.y + rside_color_picker.height + 5,
		width  = 40,
		height = 40,
	}
	active := i32(canvas.state)
	rl.GuiToggleGroup(rside_draw_buttons, "Draw;Erase", &active)
	if active != i32(canvas.state) {
		canvas.state = CanvasState(active)
		canvas.state_active = false
	}

	vbox := rl.Rectangle {
		x      = panel.panel.x + panel.padding.x + 50,
		y      = rside_draw_buttons.y + 5 + rside_draw_buttons.height,
		height = 30,
		width  = 100,
	}

	value := f32(canvas.brush.size)

	rl.GuiSlider(vbox, "1", "12", &value, 1, 12)
	canvas.brush.size = i32(value)
	size := strings.clone_to_cstring(fmt.tprint(canvas.brush.size))
	defer delete(size)
	rl.GuiLabel({vbox.x + vbox.width / 2 - 2, vbox.y + 2, 25, 25}, size)
}

draw_lside_panel :: proc(canvas: ^Canvas, panel: Panel) {
	lside_layers_view := rl.Rectangle {
		x      = panel.panel.x + panel.padding.x,
		y      = panel.panel.y + panel.padding.y,
		width  = panel.panel.width - (panel.padding.x + panel.padding.z),
		height = 30,
	}

	rl.GuiGroupBox(panel.panel, "Objects")
	last_pos := rl.Vector2{lside_layers_view.x, 0}

	for layer, i in canvas.layers {
		layer_id := strings.clone_to_cstring(fmt.tprintf("%d", i))
		defer delete(layer_id)
		last_pos.y = lside_layers_view.y + f32(i * 30)
		toogle := canvas.active_layer == i32(i)
		rl.GuiToggle({last_pos.x, last_pos.y, lside_layers_view.width, lside_layers_view.height}, layer_id, &toogle)
		if toogle {
			canvas.active_layer = i32(i)
		}
	}

	if (rl.GuiButton({last_pos.x, last_pos.y + 30, lside_layers_view.width, lside_layers_view.height}, "New")) {
		append(&canvas.layers, Layer{})
		last_layer := len(canvas.layers) - 1
		init_clear_layer(&canvas.layers[last_layer], canvas.canvasw, canvas.canvash)
	}

}
