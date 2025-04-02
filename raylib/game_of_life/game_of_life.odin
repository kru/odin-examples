package game_of_life

import time "core:time"
import rl "vendor:raylib"


Window :: struct {
	name: 			cstring,
	widht: 			i32,
	height: 		i32,
	fps: 			i32,
	control_flags: 	rl.ConfigFlags,
}

Game :: struct {
	tick_rate:	time.Duration,
	last_tick:	time.Time,
	pause:		bool,
	colors:		[]rl.Color,
	widht:		i32,
	height: 	i32,
}

World :: struct {
	width:	i32,
	height:	i32,
	alive:	[]u8,
}

Cell :: struct {
	width:	f32,
	heigt:	f32,
}

User_Input :: struct {
	left_mouse_clicked:		bool,
	right_mouse_clicked:	bool,
	toggle_pause:			bool,
	mouse_world_positon:	i32,
	mouse_tile_x:			i32,
	mouse_tile_y:			i32,
}

/*
	Game of life rules:
	(1) A cell with 2 alive neighbors stays alive/dead
	(2) A cell with 3 alive neighbors stays/becomes alives
	(3) Otherwise: the cell dies/stays dead

	reads from world, write into next_world
*/
update_world :: #force_inline proc(world: ^World, next_world: ^World) {
	for x: i32 = 0; x < world.width; x += 1 {
		for y: i32 = 0; y < world.height; y += 1 {
			neighbors := count_neighbors(world, x, y)
			index := y * world.width + x

			switch neighbors {
			case 2: next_world.alive[index] = world.alive[index]
			case 3: next_world.alive[index] = 1
			case:	next_world.alive[index] = 0
			}
		}
	}
}

// Just a branch-less version of addinng all neighbors together
count_neighbors :: #force_inline proc(w: ^World, x: i32, y: i32) -> u8 {
	// our world is a torus!
	left	:= (x - 1) %% w.width
	right	:= (x + 1) %% w.width
	up		:= (y - 1) %% w.height
	down	:= (y + 1) %% w.height

	total: u8 = 0
	return total
}
