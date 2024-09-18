package engine

import "core:fmt"
import "core:log"
import "core:mem"
import sdl "vendor:sdl2"
import ttf "vendor:sdl2/ttf"

WINDOW_SHOWN :: sdl.WINDOW_SHOWN
PURE_WHITE :: sdl.Color{255, 255, 255, 255}

SdlApp :: struct #packed {
	window:             ^sdl.Window,
	renderer:           ^sdl.Renderer,
	w, h:               i32,
	title:              cstring,
	window_flags:       sdl.WindowFlags,
	last_frame_time:    u32,
	current_frame_time: u32,
	frame_start:        u32,
	event:              sdl.Event,
	fps:                u32,
	should_quit:        bool,
}

@(private)
APP := SdlApp{}

sdl_init :: proc(title: cstring, w, h: i32, flags: sdl.WindowFlags = WINDOW_SHOWN) -> bool {
	APP.title = title
	APP.w = w
	APP.h = h
	if sdl.Init(sdl.INIT_VIDEO) < 0 {
		log.errorf("teapot: init failed, %f", sdl.GetError())
		return false
	}

	APP.window = sdl.CreateWindow(
		APP.title,
		sdl.WINDOWPOS_UNDEFINED,
		sdl.WINDOWPOS_UNDEFINED,
		APP.w,
		APP.h,
		APP.window_flags,
	)
	if APP.window == nil {
		log.errorf("teapot: cannot create a window: %s", sdl.GetError())
		return false
	}
	APP.renderer = sdl.CreateRenderer(APP.window, -1, sdl.RENDERER_ACCELERATED)
	if APP.renderer == nil {
		log.errorf("teapot: cannot create a window: %s", sdl.GetError())
		return false
	}

	sdl.RenderSetScale(APP.renderer, 1.0 / SCALE, 1.0 / SCALE)
	APP.frame_start = sdl.GetTicks()
	return true
}

sdl_quit :: proc() {
	defer sdl.DestroyWindow(APP.window)
	defer sdl.DestroyRenderer(APP.renderer)
	defer sdl.Quit()
}

get_frame_time :: proc() -> f64 {
	return f64(APP.current_frame_time - APP.last_frame_time) / 1000.0
}

begin :: proc() {
	APP.last_frame_time = APP.current_frame_time
	APP.current_frame_time = sdl.GetTicks()
	if APP.current_frame_time - APP.frame_start >= 1000 {
		fps_text := fmt.tprintf("%d", APP.fps)
		APP.fps = 0
		APP.frame_start = APP.current_frame_time
	} else {
		APP.fps += 1
	}
	poll_events()
}

end :: proc() {
	sdl.RenderPresent(APP.renderer)
	mem.zero(&INPUT.kb_down[0], sdl.NUM_SCANCODES)
	mem.zero(&INPUT.mb_down[0], 3)
}

draw_fps :: proc() {

}


window_should_close :: proc() -> bool {
	return APP.should_quit
}

MOUSE_BUTTONS :: enum {
	LEFT,
	MIDDLE,
	RIGHT,
}

@(private)
INPUT := struct {
	mb_down:          [3]bool,
	mb_being_pressed: [3]bool,
	kb_down:          [sdl.NUM_SCANCODES]bool,
	kb_being_pressed: [sdl.NUM_SCANCODES]bool,
}{}

mouse_button_down :: proc(mb: MOUSE_BUTTONS) -> bool {
	return INPUT.mb_down[mb]
}
mouse_button_pressed :: proc(mb: MOUSE_BUTTONS) -> bool {
	return INPUT.mb_being_pressed[mb]
}

poll_events :: proc() {
	for sdl.PollEvent(&APP.event) {
		#partial switch APP.event.type {
		case .QUIT:
			APP.should_quit = true
		case .KEYDOWN:
			key_event := APP.event.key
			#partial switch key_event.keysym.scancode {
			case .ESCAPE:
				INPUT.kb_down[sdl.SCANCODE_ESCAPE] = true
				INPUT.kb_being_pressed[sdl.SCANCODE_ESCAPE] = true
			}
		case .KEYUP:
			key_event := APP.event.key
			#partial switch key_event.keysym.scancode {
			case .ESCAPE:
				INPUT.kb_down[sdl.SCANCODE_ESCAPE] = false
				INPUT.kb_being_pressed[sdl.SCANCODE_ESCAPE] = false
			}
		case .MOUSEBUTTONDOWN:
			event := APP.event.button
			switch event.button {
			case u8(MOUSE_BUTTONS.LEFT) + 1:
				INPUT.mb_down[MOUSE_BUTTONS.LEFT] = true
				INPUT.mb_being_pressed[MOUSE_BUTTONS.LEFT] = true
			case u8(MOUSE_BUTTONS.MIDDLE) + 1:
				INPUT.mb_down[MOUSE_BUTTONS.MIDDLE] = true
				INPUT.mb_being_pressed[MOUSE_BUTTONS.MIDDLE] = true
			case u8(MOUSE_BUTTONS.RIGHT) + 1:
				INPUT.mb_down[MOUSE_BUTTONS.RIGHT] = true
				INPUT.mb_being_pressed[MOUSE_BUTTONS.RIGHT] = true
			}
		case .MOUSEBUTTONUP:
			event := APP.event.button
			switch event.button {
			case u8(MOUSE_BUTTONS.LEFT) + 1:
				INPUT.mb_down[MOUSE_BUTTONS.LEFT] = false
				INPUT.mb_being_pressed[MOUSE_BUTTONS.LEFT] = false
			case u8(MOUSE_BUTTONS.MIDDLE) + 1:
				INPUT.mb_down[MOUSE_BUTTONS.MIDDLE] = false
				INPUT.mb_being_pressed[MOUSE_BUTTONS.MIDDLE] = false
			case u8(MOUSE_BUTTONS.RIGHT) + 1:
				INPUT.mb_down[MOUSE_BUTTONS.RIGHT] = false
				INPUT.mb_being_pressed[MOUSE_BUTTONS.RIGHT] = false
			}
		}
	}
}

Color :: sdl.Color

render_clear :: proc(color: Color) {
	sdl.SetRenderDrawColor(APP.renderer, color.r, color.g, color.b, color.a)
	sdl.RenderClear(APP.renderer)
}

get_mouse_global_position :: proc() -> (i32, i32) {
	x, y: i32
	sdl.GetMouseState(&x, &y)
	return x, y
}

draw_rect_filled :: proc(rect: Rect, c: Color) {
	sdl.SetRenderDrawColor(APP.renderer, c.r, c.g, c.g, c.a)
	sdl.RenderFillRect(
		APP.renderer,
		&sdl.Rect{x = scaled(rect.x), y = scaled(rect.y), w = scaled(rect.w), h = scaled(rect.h)},
	)
}

ttf_init :: proc() {}
ttf_quit :: proc() {}
