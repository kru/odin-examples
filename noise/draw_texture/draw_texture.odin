package draw_texture

import "base:runtime"

import "core:c"
import "core:fmt"
import "core:math/linalg/glsl"
import "core:math/noise"
import "core:mem"

import "vendor:glfw"
import gl "vendor:OpenGL"

WIDTH :: 800
HEIGHT :: 400
TITLE :: cstring("Open Simplex 2 Texture!")

GL_MAJOR_VERSION :: 3
GL_MAJOR_VERSION :: 3

Adjust_Noise :: struct {
	seed: i64,
	octaves: i32,
	frequency: f64,
}

Vertices :: [16]f32

create_vertices :: proc(x, y, width, height: f32) -> Vertices {
	vertices: Vertices = {
		x, y,					0.0, 1.0,
		x, y + height, 			0.0, 0.0,
		x + width, y,			1.0, 1.0,
		x + width, y + height,	1.0, 0.0,
	}

	return vertices
}

WAVELENGTH :: 120
Pixel :: [4]u8

noise_at :: proc(seed: i64, x, y: int) -> f32 {
	return (noise.noise_2d(seed, {f64(x) / 120, f64(y), 120}) + 1.0) / 2.0
}
