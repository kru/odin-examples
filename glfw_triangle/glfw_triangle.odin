package glfw_triangle

import "core:fmt"
import "core:os"

import gl "vendor:OpenGL"
import "vendor:glfw"


WIDTH :: 1600
HEIGHT :: 900
TITLE :: "OpenGL Triangle"

GL_MAJOR_VERSION :: 3
GL_MINOR_VERSION :: 3

Vertices :: [9]f32

create_vertices :: proc() -> Vertices {
	vertices: Vertices = {
		-0.5, -0.5, 0.0, // left
		 0.5, -0.5, 0.0, // top
		 0.0,  0.5, 0.0, // right
	}

	return vertices
}

main :: proc() {
	if !bool(glfw.Init()) {
		fmt.eprintln("GLFW has failed to load.")
		return
	}

	window_handle := glfw.CreateWindow(WIDTH, HEIGHT, TITLE, nil, nil)

	defer glfw.Terminate()
	defer glfw.DestroyWindow(window_handle)

	if window_handle == nil {
		fmt.eprintln("GLFW has failed to load the window.")
		return
	}

	// Load OpenGL context or the "state" of OpenGL
	glfw.MakeContextCurrent(window_handle)
	// Load OpenGL function pointer with the specified OpenGL major and minor version
	gl.load_up_to(GL_MAJOR_VERSION, GL_MINOR_VERSION, glfw.gl_set_proc_address)

	// NOTE: we can change compile vertex shader and fragment shader using gl.load_shaders()
	// because we are learning lets make sense the process

	// compile vertex shader
	vs_data: []u8; v_ok: bool
	vs_data, v_ok = os.read_entire_file("vert.glsl")
	if !v_ok {
		fmt.println("reading vs_data failed")
		return
	}
	defer delete(vs_data)

	fmt.printfln("vs_data: %s", vs_data)

	vertex_shader_id: u32; vs_ok: bool
	vertex_shader_id, vs_ok = gl.compile_shader_from_source(
		string(vs_data),
		gl.Shader_Type.VERTEX_SHADER,
	)
	if !vs_ok {
		fmt.println("failed to compile shader from source")
		return
	}
	defer gl.DeleteShader(vertex_shader_id)

	// compile fragment shader
	fs_data: []u8; f_ok: bool
	fs_data, f_ok = os.read_entire_file("frag.glsl")
	if !f_ok {
		fmt.println("failed to read fragment shader file frag.glsl")
		return
	}
	defer delete(fs_data)
	fmt.printfln("fs_data: %s", fs_data)

	fragment_shader_id: u32; fs_ok: bool
	fragment_shader_id, fs_ok = gl.compile_shader_from_source(
		string(fs_data),
		gl.Shader_Type.FRAGMENT_SHADER,
	)
	if !fs_ok {
		fmt.println("failed to compile fragment shader from source")
		return
	}
	defer gl.DeleteShader(fragment_shader_id)

	program_id: u32; p_ok: bool
	program_id, p_ok = gl.create_and_link_program([]u32{vertex_shader_id, fragment_shader_id}, false)
	if !p_ok {
		fmt.println("failed to create and link program")
		return
	}
	defer gl.DeleteProgram(program_id)

	fmt.println("program_id", program_id)

	vertices := create_vertices()

	vbo: u32
	vao: u32

	// create vao
	gl.GenVertexArrays(1, &vao)
	defer gl.DeleteVertexArrays(1, &vao)
	// create vbo
	gl.GenBuffers(1, &vbo)
	defer gl.DeleteBuffers(1, &vbo)
	// bind the Vertex Array Object First, then bind and set vertex buffer(s)
	// and the configure vertex attribute(s)
	gl.BindVertexArray(vao)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)

	gl.BufferData(gl.ARRAY_BUFFER, size_of(vertices), raw_data(vertices[:]), gl.STATIC_DRAW)
	gl.VertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * size_of(f32), 0)
	gl.EnableVertexAttribArray(0)

	// note that this is allowed, the call to gl.VertexAttribPointer registered vbo
	// as the vertex attribute's bound vbo so afterwards we can safely unbind
	gl.BindBuffer(gl.ARRAY_BUFFER, 0)

	// You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens.
	// VAOs requires a call to gl.BindVertexArray anyways so we generally don't unbind VAOs (nor VBOs)
	// when it's not directly neccessary.
	gl.BindVertexArray(0)

	// draw in wireframe polygons.
	// gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)

	for !glfw.WindowShouldClose(window_handle) {
		// process all incoming events like keyboard press
		glfw.PollEvents()

		gl.ClearColor(0.2, 0.3, 0.3, 1.0)
		gl.Clear(gl.COLOR_BUFFER_BIT)

		gl.UseProgram(program_id)
		gl.BindVertexArray(vao)
		gl.DrawArrays(gl.TRIANGLES, 0, 3)

		glfw.SwapBuffers(window_handle)
	}
}
