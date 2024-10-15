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
	rl.GuiColorPicker(rside_color_picker, "Current color", &canvas.current_color)
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
