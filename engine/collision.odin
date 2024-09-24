package engine

import "core:testing"

is_colliding :: proc(a, b: Rect) -> bool {
	return(
		a.x < b.x + b.w &&
		a.x + a.w > b.x &&
		a.y < b.y + b.h &&
		a.y + a.h > b.y \
	)
}

@(test)
aabb_detection :: proc(t: ^testing.T) {
	assert(!is_colliding({0, 0, 2, 2}, {3, 3, 2, 2}))
	assert(is_colliding({0, 0, 2, 2}, {1, 1, 2, 2}))
}
