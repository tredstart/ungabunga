# SDL2 Odin Cheatsheet

## Initialization and Shutdown
```odin
sdl.Init(sdl.INIT_VIDEO)  // Initialize SDL2
sdl.Quit()                // Quit SDL2
```

## Window Management
```odin
window := sdl.CreateWindow("Title", sdl.WINDOWPOS_UNDEFINED, sdl.WINDOWPOS_UNDEFINED, 
                           width, height, sdl.WINDOW_SHOWN)
sdl.DestroyWindow(window)
```

## Renderer
```odin
renderer := sdl.CreateRenderer(window, -1, sdl.RENDERER_ACCELERATED)
sdl.DestroyRenderer(renderer)
sdl.RenderClear(renderer)
sdl.RenderPresent(renderer)
```

## Drawing
```odin
// Set draw color
sdl.SetRenderDrawColor(renderer, r, g, b, a)

// Draw shapes
sdl.RenderDrawPoint(renderer, x, y)
sdl.RenderDrawLine(renderer, x1, y1, x2, y2)
sdl.RenderDrawRect(renderer, &sdl.Rect{x, y, w, h})
sdl.RenderFillRect(renderer, &sdl.Rect{x, y, w, h})

// Draw texture
sdl.RenderCopy(renderer, texture, src_rect, dst_rect)
```

## Texture Loading
```odin
surface := sdl.LoadBMP("path/to/image.bmp")
texture := sdl.CreateTextureFromSurface(renderer, surface)
sdl.FreeSurface(surface)
sdl.DestroyTexture(texture)
```

## Event Handling
```odin
e: sdl.Event
for sdl.PollEvent(&e) {
    #partial switch e.type {
    case .QUIT:
        // Handle quit
    case .KEYDOWN:
        // Handle key press
    case .MOUSEBUTTONDOWN:
        // Handle mouse button press
    }
}
```

## Keyboard State
```odin
keys := sdl.GetKeyboardState(nil)
if keys[sdl.SCANCODE_SPACE] != 0 {
    // Space is pressed
}
```

## Mouse State
```odin
x, y: i32
buttons := sdl.GetMouseState(&x, &y)
if buttons & u32(sdl.BUTTON_LEFT) != 0 {
    // Left mouse button is pressed
}
```

## Time Management
```odin
sdl.Delay(milliseconds)  // Pause execution
ticks := sdl.GetTicks()  // Get milliseconds since SDL initialization
```

## Audio
```odin
sdl.Init(sdl.INIT_AUDIO)
spec := sdl.AudioSpec{/*...*/}
device := sdl.OpenAudioDevice(nil, 0, &spec, nil, 0)
sdl.PauseAudioDevice(device, 0)  // Start playing
sdl.CloseAudioDevice(device)
```

## Useful Structs
```odin
Rect :: struct {x, y, w, h: i32}
Point :: struct {x, y: i32}
Color :: struct {r, g, b, a: u8}
```

Remember to import SDL2:
```odin
import sdl "vendor:sdl2"
```

Note: This cheatsheet covers basic SDL2 usage. SDL2 offers many more features and functions for advanced usage.
