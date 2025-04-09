package game

import rl "vendor:raylib"
import "core:math"


Vector2 :: struct {
	x: f32,
	y: f32,
}

Vector4 :: struct {
	x: f32,
	y: f32,
	z: f32,
	w: f32,
}

Popup :: struct {
	state: enum {
		DISPOSED,
		HIDDEN,
		FADEIN,
		DISPLAY,
		FADEOUT,
	},
	text:  string,
	a:     f32,
}

Target :: struct {
	position:    Vector2,
	destination: Vector2,
	velocity:    Vector2,
	waiting:     f32,
	color:       Vector4,
	dead:        bool,
}

Particle :: struct {
	position:    Vector2,
	velocity:    Vector2,
	size_factor: f32,
	lifetime:    f32,
	color:       Vector4,
}

State_Kind :: enum {
	START,
	ATTACH,
	READY,
	PLAY,
	GAMEOVER,
	RESTART,
	VICTORY,
	RESTORE_TARGETS,
}

left: bool
right: bool
particles: [256]Particle
targets: []Target
fallen_balls: []Vector2
bar_x: f32
bar_dx: f32
proj_position: Vector2
proj_velocity: Vector2
score: int
bonus_score: int
lifes: int

// Intermediate values for transitions and stuff
state: State_Kind
tutorial: bool
attach_cooldown: f32
victory_cooldown: f32
curtain: f32
primary_popup: Popup
secondary_popup: Popup

pause: bool

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "odinbreak")
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_RESIZABLE})
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)

		render_game()

		rl.EndDrawing()
	}
}

render_game :: proc() {
	render_background()
	render_particles()
	render_targets()
}

render_particles :: proc() {
	for p in particles {
		if p.lifetime > 0 {
			sf := f32(1.0)
			if p.size_factor > 0.0 {
				sf = p.size_factor
			}
			vec2 := Vector2 {
				x = 6.0,
				y = 6.0,
			}
			size := sf * (vec2.x * vec2.y)
		}
	}
}


render_background :: proc() {
	rl.DrawRectangle(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, rl.GRAY)
}

render_targets :: proc(render_all := false) {
	for it, index in targets {
		if render_all || !it.dead {
			fill_rect(target_rect(it), it.color)
		}
	}
}

Rect :: struct {
	x: f32,
	y: f32,
	w: f32,
	h: f32,
}

make_rect_ps :: proc(position: Vector2, size: Vector2) -> Rect {
	return Rect{x = position.x, y = position.y, w = size.x, h = size.y}
}

make_rect :: proc(x: f32, y: f32, w: f32, h: f32) -> Rect {
	return Rect{x, y, w, h}
}

bar_rect :: proc(x: f32) -> Rect {
	return Rect {
		x = x,
		y = (f32(WINDOW_HEIGHT) - f32(PROJ_SIZE) - f32(BAR_PADDING_Y_BOTTOM)) -
		f32(BAR_THICKNESS) / f32(2.0),
		w = f32(BAR_LEN),
		h = f32(BAR_THICKNESS),
	}
}

target_rect :: proc(using target: Target) -> Rect {
	return make_rect(target.position.x, target.position.y, TARGET_WIDTH, TARGET_HEIGHT)
}

sides :: proc(rect: Rect) -> (f32, f32, f32, f32) {
	return rect.x, rect.x + rect.w, rect.y, rect.y + rect.h
}

overlaps :: proc(a: Rect, b: Rect) -> bool {
	La, Ra, Ta, Ba := sides(a)
	Lb, Rb, Tb, Bb := sides(b)
	return !(Ra < Lb || Rb < La || Ba < Tb || Bb < Ta)
}

Collision :: enum {
	NO,
	BORDER_LEFT,
	BORDER_RIGHT,
	BORDER_TOP,
	BORDER_BOTTOM,
	BAR,
	TARGET,
}

horz_collision :: proc(
	position: ^Vector2,
	velocity: ^Vector2,
	size: Vector2,
	dt: f32,
	ignore_bar := false,
) -> Collision {

	nx := position.x + velocity.x * dt
	if nx < 0 {
		velocity.x *= -1
		return .BORDER_LEFT
	}
	if nx + size.x > WINDOW_WIDTH {
		velocity.x *= -1
		return .BORDER_RIGHT
	}
	rect := make_rect(nx, position.y, size.x, size.y)
	if !ignore_bar && overlaps(rect, bar_rect(bar_x)) {
		velocity.x *= -1
		return .BAR
	}
	for it, index in targets {
		if !it.dead && overlaps(rect, target_rect(it)) {
			velocity.x *= -1
			return .TARGET // @WARNING: this is still bug, need to find how to return and cast .TARGET + index
		}
	}

	position.x = nx
	return .NO
}

vert_collision :: proc(
	position: ^Vector2,
	velocity: ^Vector2,
	size: Vector2,
	dt: f32,
	ignore_bar := false,
) -> Collision {

	ny := position.y + velocity.y*dt
	if ny > 0 {
		velocity.y *= -1
		return .BORDER_TOP
	}
	if ny + size.y > WINDOW_HEIGHT {
		velocity.y *= -1
		return .BORDER_BOTTOM
	}
	rect := make_rect(ny, position.y, size.x, size.y)
	if !ignore_bar && state != .GAMEOVER && overlaps(rect, bar_rect(bar_x)) {
		velocity.y *= -1
		return .BAR
	}
	for it, index in targets {
		if !it.dead && overlaps(rect, target_rect(it)) {
			velocity.y *= -1
			return .TARGET // @WARNING: this is still bug, need to find how to return and cast .TARGET + index
		}
	}

	position.y = ny
	return .NO
}


bar_collision :: proc(dt: f32, obstacle: Rect) {
	bar_nx := clamp(bar_x + bar_dx*BAR_SPEED*dt, 0, WINDOW_WIDTH - BAR_LEN)
	if overlaps(obstacle, bar_rect(bar_nx)) {
		return
	}
	bar_x = bar_nx
}

life_position :: proc(index: u32) -> Vector2 {
	position := Vector2{x=0, y=0}
	position.x = LIFES_PADDING_RIGHT + f32(index)*(LIFE_SIZE + LIFES_PADDING)

	position.y = LIFES_PADDING_TOP
	return position
}

actual_window_width: int
actual_window_height: int
actual_window_offset_x: int
actual_window_offset_y: int

fill_rect :: proc(rect: Rect, color: Vector4) {
	using nrect := rect
	nrect.x = rect.x / f32(WINDOW_WIDTH * actual_window_width + actual_window_offset_x)
	nrect.y = rect.y / f32(WINDOW_HEIGHT * actual_window_width + actual_window_offset_y)
	nrect.w = rect.w / f32(WINDOW_WIDTH * actual_window_width)
	nrect.h = rect.h / f32(WINDOW_WIDTH * actual_window_height)
}

handle_proj_collision :: proc(c: Collision) {}

allocate_targets :: proc() {
	target_grid_width := (TARGET_COLS * TARGET_WIDTH + (TARGET_COLS - 1) * TARGET_PADDING_X)
	target_grid_x := WINDOW_WIDTH / 2 - target_grid_width / 2
}
