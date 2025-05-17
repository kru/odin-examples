package game

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

Brick :: struct {
	pos:    rl.Vector2,
	active: bool,
}

Paddle :: struct {
	pos: rl.Vector2,
}

Ball :: struct {
	pos:    rl.Vector2,
	vel:    rl.Vector2,
	radius: f32,
	active: bool,
}

Game :: struct {
	bricks:    [BRICK_ROWS * BRICK_COLS]Brick,
	paddle:    Paddle,
	ball:      Ball,
	score:     int,
	game_over: bool,
}

reset_game :: proc(game: ^Game) {
	// Reset paddle 
	game.paddle.pos = {f32(WINDOW_WIDTH / 2 - PADDLE_WIDTH / 2), PADDLE_Y}
	// Reset ball 
	game.ball.pos = {f32(WINDOW_WIDTH / 2), PADDLE_Y - BALL_RADIUS}
	game.ball.radius = BALL_RADIUS
	game.ball.vel = {0,0}
	// Reset bricks 
	for row in 0 ..< BRICK_ROWS {
		for col in 0 ..< BRICK_COLS {
			idx := row * BRICK_COLS + col
			x := f32(col * (BRICK_WIDTH + BRICK_GAP) + BRICK_RL_OFFSET)
			y := f32(row * (BRICK_HEIGHT + BRICK_GAP) + BRICK_TOP_OFFSET)

			game.bricks[idx] = Brick {
				pos    = {x, y},
				active = true,
			}}}
	// Reset game state 
	game.game_over = false
	game.ball.active = false
	game.score = 0
}

main :: proc() {
	rl.InitWindow(WINDOW_WIDTH, WINDOW_HEIGHT, "odinbreak")
	rl.SetWindowState(rl.ConfigFlags{.WINDOW_RESIZABLE})
	rl.SetTargetFPS(60)

	game := Game{}
	reset_game(&game)

	for !rl.WindowShouldClose() {

		dt := rl.GetFrameTime()
		if !game.game_over {
			update_game(&game, dt)
		}

		rl.BeginDrawing()
		rl.ClearBackground(rl.BLACK)
		render_game(&game)

		rl.EndDrawing()
	}
}

render_game :: proc(game: ^Game) {
	if game.game_over {
		rl.DrawText("You Win!", WINDOW_WIDTH / 2 - 100, WINDOW_HEIGHT / 2, 40, rl.YELLOW)
		return
	}
	// Draw all active bricks 
	for brick in game.bricks {
		if brick.active {
			rl.DrawRectangleV(brick.pos, {BRICK_WIDTH, BRICK_HEIGHT}, rl.MAROON)
		}
	}
	// Draw paddle 
	rl.DrawRectangleV(game.paddle.pos, {PADDLE_WIDTH, PADDLE_HEIGHT}, rl.LIME)
	// Draw ball
	rl.DrawCircleV(game.ball.pos, game.ball.radius, rl.WHITE)
	// Draw score
	score := fmt.ctprintf("Score: %d", game.score)
	rl.DrawText(score, 10, 10, 20, rl.YELLOW)
}

update_game :: proc(game: ^Game, dt: f32) {
	// Update paddle position based on keyboard input
	if rl.IsKeyDown(.LEFT) && game.paddle.pos.x > 0 {
		game.paddle.pos.x -= PADDLE_SPEED * dt
	}
	if rl.IsKeyDown(.RIGHT) && game.paddle.pos.x < f32(WINDOW_WIDTH - PADDLE_WIDTH) {
		game.paddle.pos.x += PADDLE_SPEED * dt
	}
	// Start move the ball if space hit
	if rl.IsKeyDown(.SPACE) && !game.ball.active {
		game.ball.active = true
		game.ball.vel = {BALL_SPEED * 0.7, -BALL_SPEED * 0.7}
	}
	// Update ball position
	game.ball.pos += game.ball.vel * dt

	// Ball collision with walls
	if game.ball.pos.x - game.ball.radius < 0 {
		game.ball.pos.x = game.ball.radius
		game.ball.vel.x = -game.ball.vel.x
	}

	if game.ball.pos.x + game.ball.radius > f32(WINDOW_WIDTH) {
		game.ball.pos.x = f32(WINDOW_WIDTH) - game.ball.radius
		game.ball.vel.x = -game.ball.vel.x
	}
	if game.ball.pos.y - game.ball.radius < 0 {
		game.ball.pos.y = game.ball.radius
		game.ball.vel.y = -game.ball.vel.y
	}

	// Ball collision with paddle
	paddle_rect := rl.Rectangle{game.paddle.pos.x, game.paddle.pos.y, PADDLE_WIDTH, PADDLE_HEIGHT}
	ball_rect := rl.Rectangle {
		game.ball.pos.x - game.ball.radius,
		game.ball.pos.y - game.ball.radius,
		game.ball.radius * 2,
		game.ball.radius * 2,
	}

	if rl.CheckCollisionRecs(paddle_rect, ball_rect) {
		game.ball.vel.y = -abs(game.ball.vel.y) // Ensure upward bounce
	}

	// Ball collision with bricks
	all_inactive := true
	for &brick in game.bricks {
		if !brick.active {
			continue
		}
		all_inactive = false
		brick_rect := rl.Rectangle{brick.pos.x, brick.pos.y, BRICK_WIDTH, BRICK_HEIGHT}
		if rl.CheckCollisionRecs(brick_rect, ball_rect) {
			brick.active = false
			game.ball.vel.y = abs(game.ball.vel.y) // Ensure downward bounce
			game.score += 10
		}
	}

	if game.ball.pos.y + game.ball.radius > WINDOW_HEIGHT {
		reset_game(game)
	}

	if all_inactive {
		game.game_over = true
	}
}
