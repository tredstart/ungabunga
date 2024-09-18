package engine

import "core:fmt"
import "core:log"
import "core:mem"
import "core:strings"
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
	font:               ^ttf.Font,
	current_fps:        u32,
	target_fps:         u32,
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
/*
Events, rendering etc should go only after this proc
 */
begin :: proc() {
	APP.last_frame_time = APP.current_frame_time
	APP.current_frame_time = sdl.GetTicks()
	if APP.current_frame_time - APP.frame_start >= 1000 {
		APP.current_fps = APP.fps
		APP.fps = 0
		APP.frame_start = APP.current_frame_time
	} else {
		APP.fps += 1
	}
	poll_events()
}

end :: proc() {
	sdl.RenderPresent(APP.renderer)
	if APP.target_fps > 0 {
		sdl.Delay(1000 / APP.target_fps)
	}
	mem.zero(&INPUT.kb_down[0], sdl.NUM_SCANCODES)
	mem.zero(&INPUT.mb_down[0], 3)
}

set_target_fps :: proc(fps: u32) {
	APP.target_fps = fps
}

draw_fps :: proc() {
	if APP.font == nil {
		log.error("cannot draw text: no font selected")
		return
	}
	fps_display := strings.clone_to_cstring(fmt.tprintf("%d", APP.current_fps))
	defer delete(fps_display)
	text_surface := ttf.RenderText_Solid(APP.font, fps_display, PURE_WHITE)
	if text_surface == nil {
		log.errorf("Surface creation error: %s", sdl.GetError())
	}
	defer sdl.FreeSurface(text_surface)

	texture := sdl.CreateTextureFromSurface(APP.renderer, text_surface)
	if texture == nil {
		log.errorf("Texture creating error: %s", sdl.GetError())
	}
	defer sdl.DestroyTexture(texture)

	fps_dest := sdl.Rect{50, 50, text_surface.w, text_surface.h}
	sdl.RenderCopy(APP.renderer, texture, nil, &fps_dest)
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
key_button_down :: proc(kb: sdl.Scancode) -> bool {
	return INPUT.kb_down[kb]
}
key_button_pressed :: proc(kb: sdl.Scancode) -> bool {
	return INPUT.kb_being_pressed[kb]
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
	sdl.SetRenderDrawColor(APP.renderer, c.r, c.g, c.b, c.a)
	sdl.RenderFillRect(
		APP.renderer,
		&sdl.Rect{x = scaled(rect.x), y = scaled(rect.y), w = scaled(rect.w), h = scaled(rect.h)},
	)
}

make_quit :: proc() {
	APP.should_quit = true
}

ttf_init :: proc() -> bool {
	if ttf.Init() != 0 {
		log.error("can't init ttf")
		return false
	}
	APP.font = ttf.OpenFont("./gohu/Gohu/GohuFontuni11NerdFont-Regular.ttf", 240)
	if APP.font == nil {
		log.error("cannot load font")
		return false
	}
	return true
}
ttf_quit :: proc() {
	ttf.CloseFont(APP.font)
	ttf.Quit()
}
